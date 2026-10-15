import { FBXReader, parseBinary, parseText } from "fbx-parser";

export type MeshFormat = "fbx" | "x" | "glb";

export type Vec3 = [number, number, number];

/**
 * Bounds of a mesh as the game loads it, y-up in the file's own units: `min` and `max` after the rotation and scaling
 * of the mesh's node, `translation` is the node's translation on top. They're apart because the game scales the
 * mesh by the model script's `scale` before the node transform, so the translation isn't scaled.
 */
export interface MeshExtents {
  format: MeshFormat;
  min: Vec3;
  max: Vec3;
  translation: Vec3;
}

/** A parsed mesh file: bounds per named part, so files with many parts are only parsed once. */
export interface MeshFile {
  format: MeshFormat;
  all: Bounds;
  parts: Map<string, Bounds>;
}

export class Bounds {
  public min: Vec3 = [Infinity, Infinity, Infinity];
  public max: Vec3 = [-Infinity, -Infinity, -Infinity];
  /** added to every point, see `MeshExtents` */
  public translation: Vec3 = [0, 0, 0];

  public get isEmpty(): boolean {
    return this.min[0] > this.max[0];
  }

  public add(x: number, y: number, z: number): void {
    const point = [x, y, z];

    for (let i = 0; i < 3; i++) {
      this.min[i] = Math.min(this.min[i]!, point[i]!);
      this.max[i] = Math.max(this.max[i]!, point[i]!);
    }
  }
}

const partName = (name: string | undefined): string =>
  (name ?? "")
    .replace(/^(geometry|model)::/i, "")
    .replace(/\0.*$/, "")
    .toLowerCase();

const createMeshFile = (format: MeshFormat): MeshFile => ({
  format,
  all: new Bounds(),
  parts: new Map(),
});

/** Bounds of a named part, created on first use and merged into the file's total bounds when done. */
const getPart = (meshFile: MeshFile, name: string | undefined): Bounds => {
  const key = partName(name);
  let bounds = meshFile.parts.get(key);

  if (!bounds) {
    bounds = new Bounds();
    meshFile.parts.set(key, bounds);
  }

  return bounds;
};

const finish = (meshFile: MeshFile): MeshFile | undefined => {
  const parts = [...meshFile.parts.values()].filter((bounds) => !bounds.isEmpty);

  // relative to the first part's translation, which is exact for the usual file with one mesh
  meshFile.all.translation = parts[0]?.translation ?? [0, 0, 0];

  for (const bounds of parts) {
    const [x, y, z] = bounds.translation.map((value, i) => value - meshFile.all.translation[i]!) as Vec3;

    meshFile.all.add(bounds.min[0] + x, bounds.min[1] + y, bounds.min[2] + z);
    meshFile.all.add(bounds.max[0] + x, bounds.max[1] + y, bounds.max[2] + z);
  }

  return meshFile.all.isEmpty ? undefined : meshFile;
};

type Matrix = number[];

const IDENTITY: Matrix = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];

/** Row-vector 4x4 multiply (DirectX convention): `a` then `b`. */
const multiply = (a: Matrix, b: Matrix): Matrix => {
  const result: Matrix = [];

  for (let row = 0; row < 4; row++) {
    for (let col = 0; col < 4; col++) {
      let sum = 0;

      for (let k = 0; k < 4; k++) {
        sum += a[row * 4 + k]! * b[k * 4 + col]!;
      }

      result.push(sum);
    }
  }

  return result;
};

const translation = ([x, y, z]: Vec3): Matrix => [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, x, y, z, 1];

const scaling = ([x, y, z]: Vec3): Matrix => [x, 0, 0, 0, 0, y, 0, 0, 0, 0, z, 0, 0, 0, 0, 1];

/** Rotation around one axis (0 = x, 1 = y, 2 = z) in degrees, counter-clockwise like FBX. */
const rotation = (axis: number, degrees: number): Matrix => {
  const radians = (degrees * Math.PI) / 180;
  const [cos, sin] = [Math.cos(radians), Math.sin(radians)];
  const [a, b] = [(axis + 1) % 3, (axis + 2) % 3];
  const matrix = [...IDENTITY];

  matrix[a * 4 + a] = cos;
  matrix[a * 4 + b] = sin;
  matrix[b * 4 + a] = -sin;
  matrix[b * 4 + b] = cos;

  return matrix;
};

/** FBX euler angles in the default XYZ order: x first. */
const eulerRotation = ([x, y, z]: Vec3): Matrix => multiply(multiply(rotation(0, x), rotation(1, y)), rotation(2, z));

/** Inverse of a rotation without translation. */
const transpose = (matrix: Matrix): Matrix => matrix.map((_, i) => matrix[(i % 4) * 4 + Math.floor(i / 4)]!);

const negate = (vector: Vec3): Vec3 => vector.map((value) => -value) as Vec3;

/** Applies matrices in order. */
const chain = (...matrices: Matrix[]): Matrix => matrices.reduce(multiply, IDENTITY);

/**
 * FBX: vertices of every geometry, named after the model node that owns it and moved by that node's full transform
 * (and its parents'), like the game does when it imports a static mesh. That leaves them y-up with the ground at 0,
 * whatever axes the file was exported with. `UnitScaleFactor` is ignored, like the game does.
 */
const readFbx = (buffer: Buffer): MeshFile | undefined => {
  const isBinary = buffer.subarray(0, 18).toString("latin1") === "Kaydara FBX Binary";
  const fbx = new FBXReader(isBinary ? parseBinary(buffer) : parseText(buffer.toString("utf8")));
  const meshFile = createMeshFile("fbx");
  const objects = fbx.node("Objects");
  const modelNames = new Map<number, string>();
  /** node transform relative to its parent */
  const localTransforms = new Map<number, Matrix>();
  /** transform of the node's own geometry only, not inherited by children */
  const geometryTransforms = new Map<number, Matrix>();
  /** child id → parent id */
  const owners = new Map<number, number>();

  for (const model of objects?.nodes("Model") ?? []) {
    const properties = model.node("Properties70")?.nodes("P") ?? [];

    const get = (name: string, fallback = 0): Vec3 => {
      const property = properties.find((p) => p.prop(0) === name);

      return [4, 5, 6].map((i) => Number(property?.prop(i) ?? fallback)) as Vec3;
    };

    const id = Number(model.prop(0));
    const [rotationPivot, scalingPivot] = [get("RotationPivot"), get("ScalingPivot")];

    modelNames.set(id, String(model.prop(1) ?? ""));
    localTransforms.set(
      id,
      chain(
        translation(negate(scalingPivot)),
        scaling(get("Lcl Scaling", 1)),
        translation(scalingPivot),
        translation(get("ScalingOffset")),
        translation(negate(rotationPivot)),
        transpose(eulerRotation(get("PostRotation"))),
        eulerRotation(get("Lcl Rotation")),
        eulerRotation(get("PreRotation")),
        translation(rotationPivot),
        translation(get("RotationOffset")),
        translation(get("Lcl Translation")),
      ),
    );
    geometryTransforms.set(
      id,
      chain(
        scaling(get("GeometricScaling", 1)),
        eulerRotation(get("GeometricRotation")),
        translation(get("GeometricTranslation")),
      ),
    );
  }

  for (const connection of fbx.node("Connections")?.nodes("C") ?? []) {
    if (connection.prop(0) === "OO") {
      owners.set(Number(connection.prop(1)), Number(connection.prop(2)));
    }
  }

  /** geometry of a node → world */
  const getTransform = (id: number | undefined): Matrix => {
    let transform = (id === undefined ? undefined : geometryTransforms.get(id)) ?? IDENTITY;

    for (let node = id; node !== undefined && localTransforms.has(node); node = owners.get(node)) {
      transform = multiply(transform, localTransforms.get(node)!);
    }

    return transform;
  };

  for (const geometry of objects?.nodes("Geometry") ?? []) {
    const vertices = geometry.node("Vertices")?.prop(0, "number[]") ?? [];
    const owner = owners.get(Number(geometry.prop(0)));
    const ownerName = owner === undefined ? "" : (modelNames.get(owner) ?? "");
    const name = ownerName.length ? ownerName : String(geometry.prop(1) ?? "");
    const isNew = !meshFile.parts.has(partName(name));
    const bounds = getPart(meshFile, name);
    const m = getTransform(owner);

    if (isNew) {
      bounds.translation = [m[12]!, m[13]!, m[14]!];
    }

    // relative to the part's translation, in case several geometries share a name
    const [tx, ty, tz] = [
      m[12]! - bounds.translation[0],
      m[13]! - bounds.translation[1],
      m[14]! - bounds.translation[2],
    ];

    for (let i = 0; i + 2 < vertices.length; i += 3) {
      const [x, y, z] = [vertices[i]!, vertices[i + 1]!, vertices[i + 2]!];

      bounds.add(
        x * m[0]! + y * m[4]! + z * m[8]! + tx,
        x * m[1]! + y * m[5]! + z * m[9]! + ty,
        x * m[2]! + y * m[6]! + z * m[10]! + tz,
      );
    }
  }

  return finish(meshFile);
};

const NUMBER = /-?\d+(?:\.\d+)?(?:e[-+]?\d+)?/gi;

/** Reads `count` numbers starting at `from`, returning them and the index after the last one. */
const readNumbers = (text: string, from: number, count: number): [number[], number] => {
  const numbers: number[] = [];
  let end = from;

  NUMBER.lastIndex = from;

  while (numbers.length < count) {
    const match = NUMBER.exec(text);

    // a failed exec resets lastIndex to 0, so track the end separately
    if (!match) {
      break;
    }

    numbers.push(Number(match[0]));
    end = NUMBER.lastIndex;
  }

  return [numbers, end];
};

/** DirectX text `.X`: meshes inside nested frames, each frame applying its `FrameTransformMatrix`. Y-up. */
const readX = (text: string): MeshFile | undefined => {
  if (!text.startsWith("xof ") || !text.slice(8, 11).startsWith("txt")) {
    return undefined;
  }

  const meshFile = createMeshFile("x");
  const token = /\btemplate\b|\bFrameTransformMatrix\s*\{|\b(Frame|Mesh)\b(?:\s+([\w.-]+))?\s*\{|\{|\}/g;
  /** world matrix per open block; frames push their own, other blocks repeat the parent's */
  const stack: { matrix: Matrix; name?: string }[] = [{ matrix: IDENTITY }];

  for (let match = token.exec(text); match; match = token.exec(text)) {
    const [value, kind, name] = match;

    if (value === "template") {
      // templates hold `[...]` and guids but no data
      const close = text.indexOf("}", text.indexOf("{", token.lastIndex));

      if (close < 0) {
        break;
      }

      token.lastIndex = close + 1;
      continue;
    }

    const parent = stack[stack.length - 1]!;

    if (value.startsWith("FrameTransformMatrix")) {
      const [numbers, end] = readNumbers(text, token.lastIndex, 16);
      // the matrix belongs to the enclosing frame and applies to everything inside it
      parent.matrix = multiply(numbers, stack[stack.length - 2]?.matrix ?? IDENTITY);
      const close = text.indexOf("}", end);

      if (close < 0) {
        break;
      }

      token.lastIndex = close + 1;
      continue;
    }

    if (kind === "Mesh") {
      const [[count = 0], afterCount] = readNumbers(text, token.lastIndex, 1);
      const [numbers, end] = readNumbers(text, afterCount, count * 3);

      // unnamed meshes go by their frame's name
      const bounds = getPart(meshFile, name ?? parent.name);
      const m = parent.matrix;

      for (let i = 0; i + 2 < numbers.length; i += 3) {
        const [x, y, z] = [numbers[i]!, numbers[i + 1]!, numbers[i + 2]!];
        bounds.add(
          x * m[0]! + y * m[4]! + z * m[8]! + m[12]!,
          x * m[1]! + y * m[5]! + z * m[9]! + m[13]!,
          x * m[2]! + y * m[6]! + z * m[10]! + m[14]!,
        );
      }

      stack.push({ matrix: parent.matrix });
      token.lastIndex = end;
      continue;
    }

    if (kind === "Frame") {
      stack.push({ matrix: parent.matrix, name });
      continue;
    }

    if (value === "{") {
      stack.push({ matrix: parent.matrix });
    } else if (value === "}" && stack.length > 1) {
      stack.pop();
    }
  }

  return finish(meshFile);
};

interface Gltf {
  meshes?: { name?: string; primitives: { attributes: { POSITION?: number } }[] }[];
  accessors?: { min?: number[]; max?: number[] }[];
}

/** Binary glTF: the min/max every POSITION accessor already stores. Y-up. */
const readGlb = (buffer: Buffer): MeshFile | undefined => {
  if (buffer.toString("latin1", 0, 4) !== "glTF") {
    return undefined;
  }

  const jsonLength = buffer.readUInt32LE(12);
  const gltf = JSON.parse(buffer.toString("utf8", 20, 20 + jsonLength)) as Gltf;
  const meshFile = createMeshFile("glb");

  for (const mesh of gltf.meshes ?? []) {
    const bounds = getPart(meshFile, mesh.name);

    for (const primitive of mesh.primitives) {
      const accessor = gltf.accessors?.[primitive.attributes.POSITION ?? -1];

      if (accessor?.min && accessor.max) {
        bounds.add(accessor.min[0]!, accessor.min[1]!, accessor.min[2]!);
        bounds.add(accessor.max[0]!, accessor.max[1]!, accessor.max[2]!);
      }
    }
  }

  return finish(meshFile);
};

/** Parses a mesh file by extension. Returns undefined for unsupported, binary `.X` or empty files. */
export const readMeshFile = (file: string, buffer: Buffer): MeshFile | undefined => {
  switch (file.slice(file.lastIndexOf(".") + 1).toLowerCase()) {
    case "fbx":
      return readFbx(buffer);

    case "x":
      return readX(buffer.toString("latin1"));

    case "glb":
      return readGlb(buffer);

    default:
      return undefined;
  }
};

/**
 * Extents of a mesh, or of one part of it: `subMesh` is the part after `|` in a model script's `mesh = file|part`.
 * Falls back to the whole file when no part has that name.
 */
export const getMeshExtents = (meshFile: MeshFile, subMesh?: string): MeshExtents => {
  const part = subMesh ? meshFile.parts.get(partName(subMesh)) : undefined;
  const bounds = part && !part.isEmpty ? part : meshFile.all;

  return {
    format: meshFile.format,
    min: [...bounds.min],
    max: [...bounds.max],
    translation: [...bounds.translation],
  };
};
