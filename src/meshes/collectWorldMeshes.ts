import { readdirSync, readFileSync } from "node:fs";
import path from "node:path";
import { getMeshExtents, type MeshExtents, type MeshFile, readMeshFile, type Vec3 } from "./meshBounds.ts";
import type { Attachment, ModelTransform } from "./meshSize.ts";
import { parseScriptBlocks, type ScriptBlock, shortName } from "./scripts.ts";
import type { MediaSource } from "./sources.ts";

const MESH_EXTENSIONS = /\.(fbx|x|glb)$/i;

export interface ModelDefinition {
  name: string;
  mesh: string;
  properties: Record<string, string>;
  /** the model's `attachment world`, which the game draws the item by */
  attachment?: Attachment;
  source: string;
}

/** A model the way some item draws it on the ground. */
export interface WorldModel {
  /** lookup key: the model name in lowercase, with `@weapon` when drawn through the weapon path */
  key: string;
  /** the mesh as written in the model script, which is what `ModelScript:getMeshName()` returns */
  mesh: string;
  /** id of the source the mesh file came from */
  source: string;
  extents: MeshExtents;
  transform: ModelTransform;
}

export interface CollectedMeshes {
  models: WorldModel[];
  /** meshes used by items whose file wasn't found or couldn't be read */
  skipped: string[];
}

/** Lowercase key of a world model, see `WorldModel.key`. */
export const worldModelKey = (model: string, weapon: boolean): string =>
  shortName(model).toLowerCase() + (weapon ? "@weapon" : "");

const parseVector = (value: string | undefined, fallback: number): Vec3 => {
  const numbers = (value ?? "").trim().split(/\s+/).map(Number);

  return [0, 1, 2].map((i) => (Number.isFinite(numbers[i]) ? numbers[i]! : fallback)) as Vec3;
};

const parseAttachment = (block: ScriptBlock): Attachment | undefined => {
  const world = block.children.find((child) => child.name.toLowerCase() === "world");

  return (
    world && {
      offset: parseVector(world.properties.offset, 0),
      rotate: parseVector(world.properties.rotate, 0),
      scale: Number(world.properties.scale ?? 1) || 1,
    }
  );
};

/** The model's `scale`, like the runtime reads it. */
const getModelScale = (properties: Record<string, string>): number =>
  (Number(properties.scale ?? 1) || 1) * (properties.undocorescale?.toLowerCase() === "true" ? 2 / 3 : 1);

const isWeapon = ({ type, itemtype }: Record<string, string>): boolean =>
  type?.toLowerCase() === "weapon" || itemtype?.toLowerCase() === "base:weapon";

const walk = (dir: string, filter: RegExp, out: string[] = []): string[] => {
  let entries;

  try {
    entries = readdirSync(dir, { withFileTypes: true });
  } catch {
    return out;
  }

  for (const entry of entries) {
    const full = path.join(dir, entry.name);

    if (entry.isDirectory()) {
      walk(full, filter, out);
    } else if (filter.test(entry.name)) {
      out.push(full);
    }
  }

  return out;
};

/** The child folder matching `name` case-insensitively, mods aren't consistent about `models_X` and `scripts`. */
const findChildDir = (dir: string, name: string): string | undefined => {
  try {
    const match = readdirSync(dir, { withFileTypes: true }).find(
      (entry) => entry.isDirectory() && entry.name.toLowerCase() === name.toLowerCase(),
    );

    return match && path.join(dir, match.name);
  } catch {
    return undefined;
  }
};

/** `WorldItems\Bowl.fbx|Part` → `worlditems/bowl`, how the game looks up mesh files (case-insensitive). */
export const meshFileKey = (mesh: string): string =>
  mesh.split("|")[0]!.replace(/\\/g, "/").replace(MESH_EXTENSIONS, "").replace(/^\/+/, "").toLowerCase();

/** The models an item is drawn with on the ground, see `collectWorldMeshes`. */
const getItemModels = (properties: Record<string, string>): { name: string; weapon: boolean }[] => {
  const { worldstaticmodel, staticmodel, weaponsprite, weaponspritesbyindex } = properties;
  const weapon = !worldstaticmodel?.length && isWeapon(properties);
  // non-weapons without a WorldStaticModel have no 3D model in game, their StaticModel is the best guess. weapons
  // patched by several mods can end up with any of these (e.g. `WeaponSpritesByIndex = Hammer;HammerForged`, the
  // item instance picks one), so all of them are measured and the runtime looks up the one the game uses
  const names = worldstaticmodel?.length
    ? [worldstaticmodel]
    : weapon
      ? [staticmodel, weaponsprite, ...(weaponspritesbyindex?.split(";") ?? [])].filter((value) => value?.trim())
      : [staticmodel].filter((value) => value?.length);

  return names.map((name) => ({ name: shortName(name!.trim()), weapon }));
};

/**
 * Collects the world model of every item across all sources, resolved like `ItemModelRenderer` does: the
 * `WorldStaticModel`, or for weapons without one their `StaticModel`, `WeaponSprite` and every model in
 * `WeaponSpritesByIndex`, laid down by the weapon path. Properties are merged across an item's declarations first. Like the game, later sources override models and mesh files of earlier ones.
 */
export const collectWorldMeshes = (sources: MediaSource[]): CollectedMeshes => {
  const models = new Map<string, ModelDefinition>();
  /** item full type → its properties, merged across every declaration */
  const items = new Map<string, Record<string, string>>();
  const meshFiles = new Map<string, { file: string; source: string }>();

  for (const source of sources) {
    for (const media of source.mediaDirs) {
      const scriptsDir = findChildDir(media, "scripts");

      for (const file of scriptsDir ? walk(scriptsDir, /\.txt$/i) : []) {
        const text = readFileSync(file, "utf8");
        const module = /\bmodule\s+(\w+)/.exec(text)?.[1] ?? "Base";

        for (const block of parseScriptBlocks(text, ["item", "model"], ["attachment"])) {
          if (block.kind === "model" && block.properties.mesh) {
            models.set(block.name.toLowerCase(), {
              name: block.name,
              mesh: block.properties.mesh,
              properties: block.properties,
              attachment: parseAttachment(block),
              source: source.id,
            });
          } else if (block.kind === "item") {
            const fullType = `${module}.${block.name}`;

            // mods re-declare items to patch a few properties (e.g. CarriableItems only sets StaticModel), the game
            // merges those into the existing item, so the model is resolved once every declaration is read
            items.set(fullType, { ...items.get(fullType), ...block.properties });
          }
        }
      }

      const modelsDir = findChildDir(media, "models_X");

      for (const file of modelsDir ? walk(modelsDir, MESH_EXTENSIONS) : []) {
        meshFiles.set(meshFileKey(path.relative(modelsDir, file)), { file, source: source.id });
      }
    }
  }

  const result = new Map<string, WorldModel>();
  const skipped = new Set<string>();
  /** parsed files, many models use different parts of the same file */
  const parsed = new Map<string, MeshFile | undefined>();

  const parse = (file: string): MeshFile | undefined => {
    if (!parsed.has(file)) {
      try {
        parsed.set(file, readMeshFile(file, readFileSync(file)));
      } catch {
        parsed.set(file, undefined);
      }
    }

    return parsed.get(file);
  };

  const itemModels = [...items.values()].flatMap(getItemModels);

  for (const { name: modelName, weapon } of itemModels) {
    const key = worldModelKey(modelName, weapon);
    const model = models.get(modelName.toLowerCase());

    if (!model || result.has(key) || skipped.has(model.mesh)) {
      continue;
    }

    const meshFile = meshFiles.get(meshFileKey(model.mesh));
    const parsedFile = meshFile && parse(meshFile.file);

    if (meshFile && parsedFile) {
      result.set(key, {
        key,
        mesh: model.mesh,
        source: meshFile.source,
        extents: getMeshExtents(parsedFile, model.mesh.split("|")[1]),
        transform: { scale: getModelScale(model.properties), weapon, attachment: model.attachment },
      });
    } else {
      skipped.add(model.mesh);
    }
  }

  return { models: [...result.values()], skipped: [...skipped] };
};
