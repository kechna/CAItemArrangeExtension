import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";
import { meshFileKey } from "./collectWorldMeshes.ts";
import { getMeshExtents, readMeshFile, type Vec3 } from "./meshBounds.ts";
import { toMeshSize } from "./meshSize.ts";
import { parseScriptBlocks, shortName } from "./scripts.ts";

describe("parseScriptBlocks", () => {
  it("reads top-level properties of items and models, skipping nested blocks", () => {
    const text = `
module Base
{
    /* comment { with braces } */
    model Bowl
    {
        mesh = WorldItems/Bowl,
        scale = 0.4,
        attachment world
        {
            offset = 0.0 0.1 0.0,
        }
    }

    item Bowl
    {
        DisplayName = Bowl, // trailing comment
        WorldStaticModel = Base.Bowl,
        fluidContainer
        {
            capacity = 1,
        }
    }
}`;

    expect(parseScriptBlocks(text, ["item", "model"])).toEqual([
      { kind: "model", name: "Bowl", properties: { mesh: "WorldItems/Bowl", scale: "0.4" }, children: [] },
      { kind: "item", name: "Bowl", properties: { displayname: "Bowl", worldstaticmodel: "Base.Bowl" }, children: [] },
    ]);

    expect(parseScriptBlocks(text, ["model"], ["attachment"])[0]!.children).toEqual([
      { kind: "attachment", name: "world", properties: { offset: "0.0 0.1 0.0" }, children: [] },
    ]);
  });

  it("strips block comments like the game, where `/*/` closes itself and comments nest", () => {
    const text = `
    model A { mesh = A, }
    /*/
    model B { mesh = B, }
    /*/
    model C { mesh = C, }
    /* outer /* inner */ model D { mesh = D, } */
    model E { mesh = E, }`;

    expect(parseScriptBlocks(text, ["model"]).map((block) => block.name)).toEqual(["A", "B", "C", "E"]);
  });

  it("strips modules from references", () => {
    expect(shortName("Base.Bowl")).toBe("Bowl");
    expect(shortName("Bowl")).toBe("Bowl");
  });
});

describe("meshFileKey", () => {
  it("normalizes like the game's case-insensitive lookup", () => {
    expect(meshFileKey("WorldItems\\Bowl.FBX|Part")).toBe("worlditems/bowl");
  });
});

describe("readMeshExtents", () => {
  const xFile = `xof 0303txt 0032
template Mesh {
 <3d82ab44-62da-11cf-ab39-0020af71e433>
 DWORD nVertices;
}

Frame Root {
 FrameTransformMatrix {
  2.0,0.0,0.0,0.0,0.0,2.0,0.0,0.0,0.0,0.0,2.0,0.0,0.0,0.0,0.0,1.0;;
 }

 Frame Child {
  Mesh Cube {
   2;
   0.0;0.0;0.0;,
   1.0;3.0;2.0;;
   1;
   3;0,1,1;;
   MeshNormals {
    1;
    100.0;100.0;100.0;;
   }
  }
 }
}`;

  it("applies .X frame matrices", () => {
    expect(getMeshExtents(readMeshFile("cube.x", Buffer.from(xFile))!)).toEqual({
      format: "x",
      min: [0, 0, 0],
      max: [2, 6, 4],
      translation: [0, 0, 0],
    });
  });

  const fbxFile = (rotation: string) => `; FBX 7.4.0 project file
Objects:  {
	Geometry: 1, "Geometry::Box", "Mesh" {
		Vertices: *6 {
			a: 0,0,0,1,2,3
		}
	}
	Model: 2, "Model::Box", "Mesh" {
		Properties70:  {
			P: "Lcl Translation", "Lcl Translation", "", "A",0,0.5,0
			P: "Lcl Rotation", "Lcl Rotation", "", "A",${rotation}
			P: "Lcl Scaling", "Lcl Scaling", "", "A",2,2,2
		}
	}
}
Connections:  {
	C: "OO",1,2
	C: "OO",2,0
}`;

  const rounded = (values: number[]) => values.map((value) => Number(value.toFixed(6)) || 0);

  it("applies FBX node transforms, keeping the translation apart", () => {
    expect(getMeshExtents(readMeshFile("box.fbx", Buffer.from(fbxFile("0,0,0")))!)).toEqual({
      format: "fbx",
      min: [0, 0, 0],
      max: [2, 4, 6],
      translation: [0, 0.5, 0],
    });
  });

  it("stands z-up FBX meshes up through their node rotation", () => {
    const extents = getMeshExtents(readMeshFile("box.fbx", Buffer.from(fbxFile("-90,0,0")))!);

    expect(rounded(extents.min)).toEqual([0, 0, -4]);
    expect(rounded(extents.max)).toEqual([2, 6, 0]);
  });
});

describe("toMeshSize", () => {
  const box = { format: "x" as const, min: [0, 0, 0] as Vec3, max: [0.1, 0.4898, 0.2] as Vec3 };
  const plain = { scale: 1, weapon: false };

  it("converts to tiles and floors, with the footprint's centre relative to the origin", () => {
    expect(toMeshSize({ ...box, translation: [0, 0, 0] }, plain)).toEqual({
      dx: 0.17,
      dy: 0.34,
      dz: 0.34,
      oz: 0,
      cx: 0.085,
      cy: -0.17,
    });
  });

  it("gives the part below the origin as the bottom offset", () => {
    expect(toMeshSize({ ...box, translation: [0, -0.2449, 0] }, plain).oz).toBe(0.17);
  });

  it("scales the mesh before its node translation, like the game", () => {
    const size = toMeshSize({ ...box, translation: [1, 0, 0] }, { scale: 2, weapon: false });

    expect([size.dx, size.cx]).toEqual([0.34, 1.87]);
  });

  it("draws models by the inverse of their world attachment", () => {
    const attachment = { offset: [0, 0.4898, 0] as Vec3, rotate: [0, 0, 0] as Vec3, scale: 1 };

    expect(toMeshSize({ ...box, translation: [0, 0, 0] }, { ...plain, attachment }).oz).toBe(0.34);
  });

  it("lays weapons down like the weapon path does", () => {
    const size = toMeshSize(
      { format: "x", min: [-0.5, 0, 0], max: [0.5, 0.1, 0.2], translation: [0, 0, 0] },
      {
        scale: 1,
        weapon: true,
      },
    );

    expect(size).toEqual({ dx: 0.17, dy: 0.34, dz: 0.6942, oz: 0.3471, cx: 0.085, cy: 0.17 });
  });
});

const gameFiles = process.env.GAME_FILES_PATH;

/** Item Arrange's hand-made profiles for these meshes, at the scales their model scripts use. */
const HAND_MADE: [mesh: string, scale: number, dx: number, dy: number, dz: number][] = [
  ["WorldItems/Bowl.fbx", 0.4, 0.19, 0.19, 0.04],
  ["WorldItems/Clothing/Cooler_Ground.fbx", 0.4, 0.25, 0.44, 0.17],
  ["WorldItems/MacAndCheese.fbx", 0.4, 0.18, 0.1, 0.095],
  ["WorldItems/ToiletPaper.fbx", 0.4, 0.16, 0.16, 0.06],
];

describe.runIf(gameFiles && existsSync(path.join(gameFiles, "media", "models_X")))("game meshes", () => {
  it.each(HAND_MADE)("%s matches the hand-made footprint", (mesh, scale, dx, dy) => {
    const file = path.join(gameFiles!, "media", "models_X", mesh);
    const size = toMeshSize(getMeshExtents(readMeshFile(file, readFileSync(file))!), { scale: 1, weapon: false });

    // within 20%: hand-made profiles are rounded and sometimes a bit loose
    expect(size.dx * scale).toBeGreaterThan(dx * 0.8);
    expect(size.dx * scale).toBeLessThan(dx * 1.2);
    expect(size.dy * scale).toBeGreaterThan(dy * 0.8);
    expect(size.dy * scale).toBeLessThan(dy * 1.2);
  });
});
