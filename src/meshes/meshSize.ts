import type { MeshExtents, MeshFormat, Vec3 } from "./meshBounds.ts";

/** Floor height in tiles, IA measures `dz` in floors. */
const FLOOR_HEIGHT = 2.449;

/**
 * Tiles per mesh unit at model scale 1, fitted against Item Arrange's hand-made profiles: FBX (after node scaling)
 * from 107 models, `.X` from 9. glTF is in metres like `.X`, assumed to match without samples.
 */
const TILES_PER_UNIT: Record<MeshFormat, number> = {
  fbx: 1.575,
  x: 1.7,
  glb: 1.7,
};

/** A model script's `attachment world { … }`, which the game draws the item by. */
export interface Attachment {
  offset: Vec3;
  /** degrees */
  rotate: Vec3;
  scale: number;
}

export interface ModelTransform {
  /** the model script's `scale` */
  scale: number;
  /** drawn through the weapon path (no `WorldStaticModel`), which lays the model down */
  weapon: boolean;
  attachment?: Attachment;
}

/** Footprint and height of a model as the game draws it on the ground, before Item Arrange turns it. */
export interface MeshSize {
  /** tiles */
  dx: number;
  /** tiles */
  dy: number;
  /** floors */
  dz: number;
  /** how far the mesh reaches below its origin in floors, positive when it would clip into the surface */
  oz: number;
  /** centre of the footprint relative to the item's origin in tiles, along IA's x */
  cx: number;
  /** centre of the footprint relative to the item's origin in tiles, along IA's y */
  cy: number;
}

const round = (value: number): number => Number(value.toPrecision(4));

const radians = (degrees: number): number => (degrees * Math.PI) / 180;

/** Counter-clockwise rotations around one axis, like JOML's. */
const rotateX = ([x, y, z]: Vec3, degrees: number): Vec3 => {
  const [cos, sin] = [Math.cos(radians(degrees)), Math.sin(radians(degrees))];

  return [x, y * cos - z * sin, y * sin + z * cos];
};

const rotateY = ([x, y, z]: Vec3, degrees: number): Vec3 => {
  const [cos, sin] = [Math.cos(radians(degrees)), Math.sin(radians(degrees))];

  return [x * cos + z * sin, y, -x * sin + z * cos];
};

const rotateZ = ([x, y, z]: Vec3, degrees: number): Vec3 => {
  const [cos, sin] = [Math.cos(radians(degrees)), Math.sin(radians(degrees))];

  return [x * cos - y * sin, x * sin + y * cos, z];
};

/**
 * A point of the scaled mesh as the game draws it (`ItemModelRenderer.init`): the inverse of the world attachment,
 * then for weapons `rotateXYZ(0, 180°, 90°)`.
 */
const toWorld = (point: Vec3, transform: ModelTransform): Vec3 => {
  let result = point;
  const { attachment } = transform;

  if (attachment) {
    const [ox, oy, oz] = attachment.offset;
    const [rx, ry, rz] = attachment.rotate;

    result = [result[0] - ox, result[1] - oy, result[2] - oz];
    result = rotateZ(rotateY(rotateX(result, -rx), -ry), -rz);
    result = result.map((value) => value / (attachment.scale || 1)) as Vec3;
  }

  if (transform.weapon) {
    result = rotateY(rotateZ(result, 90), 180);
  }

  return result;
};

/**
 * Size and position of a model on the ground, as the game draws it at item rotation 0. The game's model space is
 * y-up, with IA's x along +x and IA's y along -z.
 */
export const toMeshSize = (extents: MeshExtents, transform: ModelTransform): MeshSize => {
  const factor = TILES_PER_UNIT[extents.format];
  const min: Vec3 = [Infinity, Infinity, Infinity];
  const max: Vec3 = [-Infinity, -Infinity, -Infinity];

  // the box's corners, so turns of a quarter are exact and others a bit loose, like the game's own bounds
  for (let corner = 0; corner < 8; corner++) {
    const point = [0, 1, 2].map(
      (axis) =>
        ((corner >> axis) & 1 ? extents.max[axis]! : extents.min[axis]!) * transform.scale + extents.translation[axis]!,
    ) as Vec3;
    const world = toWorld(point, transform);

    for (let axis = 0; axis < 3; axis++) {
      min[axis] = Math.min(min[axis]!, world[axis]!);
      max[axis] = Math.max(max[axis]!, world[axis]!);
    }
  }

  return {
    dx: round((max[0] - min[0]) * factor),
    dy: round((max[2] - min[2]) * factor),
    dz: round(((max[1] - min[1]) * factor) / FLOOR_HEIGHT),
    oz: round((-min[1] * factor) / FLOOR_HEIGHT),
    cx: round(((min[0] + max[0]) / 2) * factor),
    cy: round((-(min[2] + max[2]) / 2) * factor),
  };
};
