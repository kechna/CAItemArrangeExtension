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

const isUnrotated = (box: GeometryBox): boolean => box.rotate.every((value) => value === 0);

const toWorld = (box: GeometryBox): { min: [number, number, number]; max: [number, number, number] } => ({
  min: [box.min[0] + box.translate[0], box.min[1] + box.translate[1], box.min[2] + box.translate[2]],
  max: [box.max[0] + box.translate[0], box.max[1] + box.translate[1], box.max[2] + box.translate[2]],
});

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

/** Finds the shelf surfaces of a tile: the tops of wide boxes, capped by the lowest box above them. */
export const extractSurfaces = (tile: GeometryTile): TileSurfaces => {
  const boxes = tile.boxes.filter(isUnrotated).map(toWorld);
  const rects: Rect[] = [];

  for (const box of boxes) {
    const top = box.max[1];
    const [x0, , z0] = box.min;
    const [x1, , z1] = box.max;

    if (top < MIN_HEIGHT || x1 - x0 < MIN_FOOTPRINT || z1 - z0 < MIN_FOOTPRINT) {
      continue;
    }

    let ceiling = Infinity;

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
    zmax: rect.ceiling === Infinity ? 1 : round(Math.min(1, rect.ceiling / Y_SCALE)),
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
  surfaces: Map<string, Surface[]>;
}

/**
 * Generates surfaces for every shelf container tile with at least two shelf levels. Single-surface containers (counters,
 * crates) are left to the game's own surface offset.
 */
export const extractContainerSurfaces = (
  geometry: GeometryTile[],
  definitions: TileDefinition[],
): ContainerSurfaces => {
  const byKey = new Map(
    definitions.map((definition) => [tileKey(definition.tileset, definition.col, definition.row), definition]),
  );
  const surfaces = new Map<string, Surface[]>();
  const ambiguous: string[] = [];

  for (const tile of geometry) {
    const definition = byKey.get(tileKey(tile.tileset, tile.col, tile.row));

    // if (definition?.properties.container) {
    //   console.log(definition.sprite, definition?.properties.container);
    // }

    if (!definition /* || !SHELF_CONTAINERS.has(definition.properties.container ?? "") */) {
      continue;
    }

    const result = extractSurfaces(tile);

    if (!result.surfaces.length) {
      continue;
    }

    if (result.ambiguous) {
      console.log("Ambiguous:", definition.sprite, definition.properties);
      ambiguous.push(definition.sprite);
    } else {
      surfaces.set(definition.sprite, result.surfaces);
    }
  }

  return { surfaces, ambiguous };
};
