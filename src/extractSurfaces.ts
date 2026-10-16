import { type GeometryBox, type GeometryTile, type TileDefinition, tileKey } from "./tileGeometry.ts";

/** A surface rectangle as used by `IA.surfaces`: fractions of a tile, z in floor heights. */
export interface Surface {
  xmax: number;
  xmin: number;
  ymax: number;
  ymin: number;
  zmax: number;
  zmin: number;
}

/** Geometry units per tile on the x/z axes. */
const TILE_SIZE = 10000;
/** Geometry units per floor height (sqrt(6) tiles), so `z = y / Y_SCALE`. */
export const Y_SCALE = 24495;
/** Hand-tuned profiles sit this much above the plank tops, measured against IAData. */
export const Z_OFFSET = 0.008;
/** Box tops below this are floor-level bases, not shelves. */
const MIN_HEIGHT = 300;
/** Narrower boxes are back panels, posts or trim. */
const MIN_FOOTPRINT = 1500;
/** Shelves with less room above them can't hold anything. */
const MIN_CLEARANCE = 1000;
/** Tolerance for "same height" and "touching". */
const EPSILON = 50;
/** Shelves closer together in height than this count as one level (corner arms are sometimes offset). */
const LEVEL_TOLERANCE = 1000;
/** A second rectangle on a level at least this fraction of the largest one makes the tile ambiguous. */
const AMBIGUOUS_RATIO = 0.25;
/** A tile `Surface` property (in pixels, 96 per floor) at least this high means the game itself puts items on top. */
const TALL_SURFACE = 90;
/** Container types that hold items on open shelves, so ovens and the like keep the game's surface offset. */
const SHELF_CONTAINERS = new Set([
  "shelves",
  "metal_shelves",
  "clothingrack",
  "toolcabinet",
  "counter",
  "displaycasebakery",
  "dishescabinet",
  "desk",
  "filingcabinet",
  "wardrobe",
  "shelvesmag",
  "grocerstand",
]);

/**
 * Only a height, for container tiles without geometry boxes: Item Arrange fills in the rest from its default ground
 * rectangle, which keeps clear of the walls around the square.
 */
export type HeightOnlySurface = Pick<Surface, "zmin"> & Partial<Pick<Surface, "zmax">>;

/** Game `Surface` property units (pixels) per floor height. */
const SURFACE_UNITS = 96;
/** Extra lift on the game's `Surface` height per container type, the drawn top of some sits above it. */
const SURFACE_LIFT: Record<string, number> = {};

interface Rect {
  ceiling: number;
  top: number;
  x0: number;
  x1: number;
  z0: number;
  z1: number;
}

const round = (value: number): number => Math.round(value * 1000) / 1000;

const clamp = (value: number): number => Math.min(1, Math.max(0, value));

type Vec3 = [number, number, number];

type Matrix3 = [Vec3, Vec3, Vec3];

/** `rotate` is in degrees times this. */
const ROTATE_SCALE = 10000;
/** Matrix entries this close to -1, 0 or 1 count as exact, rotations are stored like -89.9802°. */
const AXIS_TOLERANCE = 0.01;

const multiply = (a: Matrix3, b: Matrix3): Matrix3 =>
  a.map((row) => [0, 1, 2].map((j) => row[0] * b[0][j]! + row[1] * b[1][j]! + row[2] * b[2][j]!)) as Matrix3;

/** The box's rotation like the game builds it, JOML's `rotateXYZ`: Rx · Ry · Rz. */
const rotationMatrix = (rotate: Vec3): Matrix3 => {
  const [x, y, z] = rotate.map((value) => ((value / ROTATE_SCALE) * Math.PI) / 180) as Vec3;
  const rx: Matrix3 = [
    [1, 0, 0],
    [0, Math.cos(x), -Math.sin(x)],
    [0, Math.sin(x), Math.cos(x)],
  ];
  const ry: Matrix3 = [
    [Math.cos(y), 0, Math.sin(y)],
    [0, 1, 0],
    [-Math.sin(y), 0, Math.cos(y)],
  ];
  const rz: Matrix3 = [
    [Math.cos(z), -Math.sin(z), 0],
    [Math.sin(z), Math.cos(z), 0],
    [0, 0, 1],
  ];

  return multiply(multiply(rx, ry), rz);
};

const isAxisAligned = (matrix: Matrix3): boolean =>
  matrix.every((row) => row.every((value) => [-1, 0, 1].some((axis) => Math.abs(value - axis) <= AXIS_TOLERANCE)));

/**
 * The box in tile space. Boxes turned by multiples of 90° (e.g. the side-facing variants of a shelf) map to an exact
 * box, any other rotation would only give a loose bounding box and is skipped.
 */
const toWorld = (box: GeometryBox): { min: Vec3; max: Vec3 } | undefined => {
  const matrix = rotationMatrix(box.rotate);

  if (!isAxisAligned(matrix)) {
    return undefined;
  }

  const min: Vec3 = [Infinity, Infinity, Infinity];
  const max: Vec3 = [-Infinity, -Infinity, -Infinity];

  for (const corner of [0, 1, 2, 3, 4, 5, 6, 7]) {
    const local = [0, 1, 2].map((axis) => (corner & (1 << axis) ? box.max[axis]! : box.min[axis]!));

    for (const axis of [0, 1, 2]) {
      const row = matrix[axis]!;
      const value = Math.round(row[0] * local[0]! + row[1] * local[1]! + row[2] * local[2]!) + box.translate[axis]!;

      min[axis] = Math.min(min[axis]!, value);
      max[axis] = Math.max(max[axis]!, value);
    }
  }

  return { min, max };
};

const overlaps = (a0: number, a1: number, b0: number, b1: number): boolean => a0 < b1 - EPSILON && b0 < a1 - EPSILON;

const near = (a: number, b: number): boolean => Math.abs(a - b) <= EPSILON;

const area = (rect: Rect): number => (rect.x1 - rect.x0) * (rect.z1 - rect.z0);

/** Merges two rects on the same level when they share a full edge. */
const tryMerge = (a: Rect, b: Rect): Rect | undefined => {
  if (!near(a.top, b.top)) {
    return undefined;
  }

  const ceiling = Math.min(a.ceiling, b.ceiling);

  if (near(a.z0, b.z0) && near(a.z1, b.z1) && (near(a.x1, b.x0) || near(b.x1, a.x0))) {
    return { ...a, ceiling, x0: Math.min(a.x0, b.x0), x1: Math.max(a.x1, b.x1) };
  }

  if (near(a.x0, b.x0) && near(a.x1, b.x1) && (near(a.z1, b.z0) || near(b.z1, a.z0))) {
    return { ...a, ceiling, z0: Math.min(a.z0, b.z0), z1: Math.max(a.z1, b.z1) };
  }

  return undefined;
};

const mergeAll = (rects: Rect[]): Rect[] => {
  const result = [...rects];

  for (let merged = true; merged;) {
    merged = false;

    for (let i = 0; i < result.length && !merged; i++) {
      for (let j = i + 1; j < result.length && !merged; j++) {
        const combined = tryMerge(result[i]!, result[j]!);

        if (combined) {
          result.splice(j, 1);
          result[i] = combined;
          merged = true;
        }
      }
    }
  }

  return result;
};

export interface TileSurfaces {
  /**
   * True when a level has several large rectangles, like the two arms of a corner shelf. Item Arrange gives every
   * surface on a square the same item orientation, and which arm matches it depends on the walls around the square,
   * so these tiles need a hand-picked profile.
   */
  ambiguous: boolean;
  surfaces: Surface[];
}

/**
 * Finds the shelf surfaces of a tile: the tops of wide boxes, capped by the lowest box above them. The next floor caps
 * them too, so tops at full height (doors, wall cabinets) have no room above them, unless `tall` says the tile is
 * furniture as high as a floor (stacked crates). Those tops get a floor of room above them.
 */
export const extractSurfaces = (tile: GeometryTile, tall = false): TileSurfaces => {
  const boxes = tile.boxes.map(toWorld).filter((box) => box !== undefined);
  const rects: Rect[] = [];

  for (const box of boxes) {
    const top = box.max[1];
    const [x0, , z0] = box.min;
    const [x1, , z1] = box.max;

    if (top < MIN_HEIGHT || x1 - x0 < MIN_FOOTPRINT || z1 - z0 < MIN_FOOTPRINT) {
      continue;
    }

    let ceiling = tall && top >= Y_SCALE - LEVEL_TOLERANCE ? top + Y_SCALE : Y_SCALE;

    for (const other of boxes) {
      const bottom = other.min[1];

      if (
        bottom >= top - EPSILON &&
        bottom < ceiling &&
        overlaps(x0, x1, other.min[0], other.max[0]) &&
        overlaps(z0, z1, other.min[2], other.max[2])
      ) {
        ceiling = bottom;
      }
    }

    if (ceiling - top < MIN_CLEARANCE) {
      continue;
    }

    rects.push({ top, ceiling, x0, x1, z0, z1 });
  }

  const levels: Rect[][] = [];

  for (const rect of mergeAll(rects).sort((a, b) => a.top - b.top)) {
    const level = levels.find((candidates) => Math.abs(candidates[0]!.top - rect.top) <= LEVEL_TOLERANCE);

    if (level) {
      level.push(rect);
    } else {
      levels.push([rect]);
    }
  }

  let ambiguous = false;
  const kept: Rect[] = [];

  for (const level of levels) {
    const [largest, second] = level.sort((a, b) => area(b) - area(a));

    if (second && area(second) >= area(largest!) * AMBIGUOUS_RATIO) {
      ambiguous = true;
    }

    kept.push(largest!);
  }

  const surfaces = kept.map((rect) => ({
    zmin: round(rect.top / Y_SCALE + Z_OFFSET),
    zmax: round(rect.ceiling / Y_SCALE),
    xmin: round(clamp((rect.x0 + TILE_SIZE / 2) / TILE_SIZE)),
    xmax: round(clamp((rect.x1 + TILE_SIZE / 2) / TILE_SIZE)),
    ymin: round(clamp((rect.z0 + TILE_SIZE / 2) / TILE_SIZE)),
    ymax: round(clamp((rect.z1 + TILE_SIZE / 2) / TILE_SIZE)),
  }));

  return { surfaces, ambiguous };
};

export interface ContainerSurfaces {
  /** Sprites skipped because they need a hand-picked profile, see {@link TileSurfaces.ambiguous}. */
  ambiguous: string[];
  surfaces: Map<string, (Surface | HeightOnlySurface)[]>;
}

/**
 * Generates surfaces for every tile with usable geometry boxes. Container tiles without boxes (most counters) get only
 * the game's own `Surface` height, see {@link HeightOnlySurface}.
 */
export const extractContainerSurfaces = (
  geometry: GeometryTile[],
  definitions: TileDefinition[],
): ContainerSurfaces => {
  const byKey = new Map(geometry.map((tile) => [tileKey(tile.tileset, tile.col, tile.row), tile]));
  const surfaces = new Map<string, (Surface | HeightOnlySurface)[]>();
  const ambiguous: string[] = [];

  for (const definition of definitions) {
    const tile = byKey.get(tileKey(definition.tileset, definition.col, definition.row));
    const container = definition.properties.container;
    const surfaceHeight = Number(definition.properties.Surface ?? tile?.properties.Surface ?? 0);

    if (!tile?.boxes.length) {
      if (container && surfaceHeight > 0) {
        const zmin = round(surfaceHeight / SURFACE_UNITS + Z_OFFSET + (SURFACE_LIFT[container] ?? 0));

        // tops of furniture as high as a floor (fridges, stacked crates) get a floor of room, like in `extractSurfaces`
        surfaces.set(definition.sprite, [surfaceHeight >= TALL_SURFACE ? { zmin, zmax: round(zmin + 1) } : { zmin }]);
      }

      continue;
    }

    const result = extractSurfaces(tile, surfaceHeight >= TALL_SURFACE);

    if (!result.surfaces.length) {
      continue;
    }

    if (result.ambiguous) {
      ambiguous.push(definition.sprite);
    } else {
      surfaces.set(definition.sprite, result.surfaces);
    }
  }

  return { surfaces, ambiguous };
};
