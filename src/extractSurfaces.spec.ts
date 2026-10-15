import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";
import { extractContainerSurfaces, extractSurfaces } from "./extractSurfaces.ts";
import { parseTileDefinitions, parseTileGeometry } from "./tileGeometry.ts";

const box = (min: string, max: string): string => `
            box
            {
                translate = 0x0x0,
                rotate = 0x0x0,
                min = ${min},
                max = ${max},
            }
`;

const GEOMETRY = `tileGeometry
{
    VERSION = 2,

    tileset
    {
        name = test_01,

        /* test_01_9 */
        tile
        {
            xy = 1x1,
${box("-4500x0x-4500", "5000x20200x-3800")}
${box("-4500x0x-3800", "5000x1500x500")}
${box("-4500x8500x-3800", "5000x9200x500")}

            properties
            {
                ItemHeight = 64,
            }
        }

        /* test_01_8 */
        tile
        {
            xy = 0x1,
${box("-3800x8000x-3800", "500x9200x5000")}
${box("500x8000x-3800", "5000x9200x500")}
${box("-3800x15000x-3800", "500x16200x5000")}
${box("500x15000x-3800", "5000x16200x500")}
        }
    }
}
`;

const DEFINITIONS = `version = 1
tileset
{
    file = test_01
    size = 8,16
    id = 1
    // test_01_8
    tile
    {
        xy = 0,1
        container = shelves
    }
    // test_01_9
    tile
    {
        xy = 1,1
        Facing = S
        container = shelves
    }
}
`;

describe("parseTileGeometry", () => {
  it("parses tiles, boxes and properties", () => {
    const [tile] = parseTileGeometry(GEOMETRY);

    expect(tile).toMatchObject({ tileset: "test_01", col: 1, row: 1, properties: { ItemHeight: "64" } });
    expect(tile?.boxes).toHaveLength(3);
    expect(tile?.boxes[1]).toEqual({
      translate: [0, 0, 0],
      rotate: [0, 0, 0],
      min: [-4500, 0, -3800],
      max: [5000, 1500, 500],
    });
  });
});

describe("parseTileDefinitions", () => {
  it("reads sprite names from comments", () => {
    expect(parseTileDefinitions(DEFINITIONS)).toEqual([
      { sprite: "test_01_8", tileset: "test_01", col: 0, row: 1, properties: { container: "shelves" } },
      { sprite: "test_01_9", tileset: "test_01", col: 1, row: 1, properties: { Facing: "S", container: "shelves" } },
    ]);
  });
});

describe("extractSurfaces", () => {
  it("finds shelf planks and ignores the back panel", () => {
    const [tile] = parseTileGeometry(GEOMETRY);
    const { surfaces, ambiguous } = extractSurfaces(tile!);

    expect(ambiguous).toBe(false);
    expect(surfaces).toEqual([
      { zmin: 0.069, zmax: 0.347, xmin: 0.05, xmax: 1, ymin: 0.12, ymax: 0.55 },
      { zmin: 0.384, zmax: 1, xmin: 0.05, xmax: 1, ymin: 0.12, ymax: 0.55 },
    ]);
  });

  it("flags L-shaped corner shelves as ambiguous", () => {
    const { surfaces, ambiguous } = extractContainerSurfaces(
      parseTileGeometry(GEOMETRY),
      parseTileDefinitions(DEFINITIONS),
    );

    expect(ambiguous).toEqual(["test_01_8"]);
    expect([...surfaces.keys()]).toEqual(["test_01_9"]);
  });
});

const media = process.env.GAME_FILES_PATH && path.join(process.env.GAME_FILES_PATH, "media");

/** Hand-tuned shelf heights from IAData.lua that were checked in game. */
const HAND_TUNED: Record<string, number[]> = {
  furniture_shelving_01_1: [0.35, 0.64],
  furniture_shelving_01_9: [0.068, 0.379, 0.68],
  furniture_shelving_01_10: [0.068, 0.382, 0.68],
  furniture_shelving_01_40: [0.055, 0.333, 0.61, 0.845],
  crafted_04_92: [0.09, 0.36, 0.62, 0.83],
};

describe.runIf(media && existsSync(path.join(media, "tileGeometry.txt")))("game files", () => {
  it("matches hand-tuned shelf heights", () => {
    const { surfaces } = extractContainerSurfaces(
      parseTileGeometry(readFileSync(path.join(media!, "tileGeometry.txt"), "utf8")),
      parseTileDefinitions(readFileSync(path.join(media!, "newtiledefinitions.tiles.txt"), "utf8")),
    );

    for (const [sprite, heights] of Object.entries(HAND_TUNED)) {
      const generated = surfaces.get(sprite)?.map((surface) => surface.zmin);

      expect(generated, sprite).toHaveLength(heights.length);
      generated?.forEach((zmin, i) => expect(zmin, `${sprite}[${i}]`).toBeCloseTo(heights[i]!, 1));
    }
  });
});
