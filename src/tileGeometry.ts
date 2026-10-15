export type Vec3 = [number, number, number];

export interface GeometryBox {
  translate: Vec3;
  rotate: Vec3;
  min: Vec3;
  max: Vec3;
}

export interface GeometryTile {
  tileset: string;
  col: number;
  row: number;
  boxes: GeometryBox[];
  /** Number of shapes other than boxes (cylinders, polygons), which are ignored. */
  otherShapes: number;
  properties: Record<string, string>;
}

export interface TileDefinition {
  sprite: string;
  tileset: string;
  col: number;
  row: number;
  properties: Record<string, string>;
}

const parseVec3 = (value: string): Vec3 => {
  const parts = value.split("x").map(Number);

  return [parts[0] ?? 0, parts[1] ?? 0, parts[2] ?? 0];
};

const stripComments = (text: string): string => text.replace(/\/\*[\s\S]*?\*\//g, "");

/**
 * Parses `media/tileGeometry.txt`: nested `name { key = value, }` blocks, one `tile` per sprite with its collision
 * shapes in tile units (x/z -5000..5000, y up from the floor).
 */
export const parseTileGeometry = (text: string): GeometryTile[] => {
  const lines = stripComments(text).split(/\r?\n/);
  const tiles: GeometryTile[] = [];
  const stack: string[] = [];

  let pendingBlock: string | undefined;
  let tileset = "";
  let tile: GeometryTile | undefined;
  let shape: Record<string, string> | undefined;

  for (const raw of lines) {
    const line = raw.trim();

    if (!line) {
      continue;
    }

    if (line === "{") {
      const name = pendingBlock ?? "";
      stack.push(name);
      pendingBlock = undefined;

      if (name === "tile") {
        tile = { tileset, col: 0, row: 0, boxes: [], otherShapes: 0, properties: {} };
      } else if (name === "box" || name === "cylinder" || name === "polygon") {
        shape = {};
      }

      continue;
    }

    if (line === "}") {
      const name = stack.pop();

      if (name === "tile" && tile) {
        tiles.push(tile);
        tile = undefined;
      } else if (name === "box" && tile && shape) {
        tile.boxes.push({
          translate: parseVec3(shape.translate ?? "0x0x0"),
          rotate: parseVec3(shape.rotate ?? "0x0x0"),
          min: parseVec3(shape.min ?? "0x0x0"),
          max: parseVec3(shape.max ?? "0x0x0"),
        });
        shape = undefined;
      } else if ((name === "cylinder" || name === "polygon") && tile) {
        tile.otherShapes++;
        shape = undefined;
      }

      continue;
    }

    const match = /^(\w+)\s*=\s*(.*?),?$/.exec(line);

    if (!match) {
      pendingBlock = line;
      continue;
    }

    const [, key, value] = match as unknown as [string, string, string];
    const block = stack[stack.length - 1];

    if (block === "tileset" && key === "name") {
      tileset = value;
    } else if (block === "tile" && tile && key === "xy") {
      const [col, row] = value.split("x").map(Number);
      tile.col = col ?? 0;
      tile.row = row ?? 0;
    } else if (block === "properties" && tile) {
      tile.properties[key] = value;
    } else if (shape) {
      shape[key] = value;
    }
  }

  return tiles;
};

/**
 * Parses `media/newtiledefinitions.tiles.txt` (and other `*.tiles.txt` files). Every tile is preceded by a
 * `// <sprite name>` comment and has `Key = value` properties without trailing commas.
 */
export const parseTileDefinitions = (text: string): TileDefinition[] => {
  const lines = text.split(/\r?\n/);
  const definitions: TileDefinition[] = [];

  let tileset = "";
  let sprite = "";
  let depth = 0;
  let current: TileDefinition | undefined;

  for (const raw of lines) {
    const line = raw.trim();

    if (line === "{") {
      depth++;
      continue;
    }

    if (line === "}") {
      depth--;

      if (current && depth === 1) {
        definitions.push(current);
        current = undefined;
      }

      continue;
    }

    if (line.startsWith("//")) {
      sprite = line.slice(2).trim();
      continue;
    }

    if (line === "tile" && depth === 1) {
      current = { sprite, tileset, col: 0, row: 0, properties: {} };
      continue;
    }

    const match = /^(\w+)\s*=\s*(.*)$/.exec(line);

    if (!match) {
      continue;
    }

    const [, key, value] = match as unknown as [string, string, string];

    if (depth === 1 && key === "file") {
      tileset = value.trim();
    } else if (current && key === "xy") {
      const [col, row] = value.split(",").map(Number);
      current.col = col ?? 0;
      current.row = row ?? 0;
    } else if (current) {
      current.properties[key] = value.trim();
    }
  }

  return definitions;
};

export const tileKey = (tileset: string, col: number, row: number): string => `${tileset}:${col},${row}`;
