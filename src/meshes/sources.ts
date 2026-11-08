import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import path from "node:path";

/** Project Zomboid's Steam app id, the workshop content folder is named after it. */
const APP_ID = "108600";

export interface MediaSource {
  /** `vanilla`, or the mod id from its `mod.info`, as `getActivatedMods()` lists it */
  id: string;
  /** media folders in load order, later ones override earlier ones */
  mediaDirs: string[];
  /** ids of mods its mod.info says can't be active with it */
  incompatible: string[];
}

const isDirectory = (dir: string): boolean => existsSync(dir) && statSync(dir).isDirectory();

const listDirs = (dir: string): string[] =>
  isDirectory(dir) ? readdirSync(dir).filter((name) => isDirectory(path.join(dir, name))) : [];

const compareVersions = (a: string, b: string): number => {
  const pa = a.split(".").map(Number);
  const pb = b.split(".").map(Number);

  for (let i = 0; i < Math.max(pa.length, pb.length); i++) {
    const diff = (pa[i] ?? 0) - (pb[i] ?? 0);

    if (diff !== 0) {
      return diff;
    }
  }

  return 0;
};

const getLatestVersion = (modDir: string): string | undefined =>
  listDirs(modDir)
    .filter((name) => /^\d+(\.\d+)*$/.test(name))
    .sort(compareVersions)
    .pop();

/** The mod.info the game reads, whose `id` can differ from the folder name. */
const readModInfo = (modDir: string, fallbackId: string): { id: string; incompatible: string[] } => {
  const latest = getLatestVersion(modDir);
  let text = "";

  try {
    text = readFileSync(path.join(latest ? path.join(modDir, latest) : modDir, "mod.info"), "utf8");
  } catch {
    // no mod.info, the folder name is all there is
  }

  const get = (key: string): string | undefined => new RegExp(`^\\s*${key}\\s*=\\s*(.+?)\\s*$`, "m").exec(text)?.[1];

  return {
    id: get("id") ?? fallbackId,
    incompatible: (get("incompatible") ?? "")
      .split(",")
      .map((id) => id.trim().replace(/^\\/, ""))
      .filter(Boolean),
  };
};

/**
 * Media folders of one mod as Build 42 loads them: `common/media`, then the highest version folder. The installed game
 * is assumed to be recent enough for every folder, since its version can't be read from the install. Mods without
 * version folders are Build 41 style and use `media` directly.
 */
const getModMediaDirs = (modDir: string): string[] => {
  const latest = getLatestVersion(modDir);

  if (!latest) {
    return [path.join(modDir, "media")].filter(isDirectory);
  }

  return [path.join(modDir, "common", "media"), path.join(modDir, latest, "media")].filter(isDirectory);
};

/** `<steam library>/steamapps/workshop/content/108600`, derived from the game install path. */
export const getWorkshopContentPath = (gameFilesPath: string): string | undefined => {
  const index = gameFilesPath.indexOf(`${path.sep}steamapps${path.sep}`);

  if (index < 0) {
    return undefined;
  }

  return path.join(gameFilesPath.slice(0, index), "steamapps", "workshop", "content", APP_ID);
};

export interface SourceOptions {
  gameFilesPath: string;
  /** workshop content folder, defaults to the one next to the game install */
  workshopContentPath?: string;
  /** `~/Zomboid/mods` */
  localModsPath?: string;
}

/** Vanilla first, then every installed workshop mod and every local mod, sorted by id. */
export const findMediaSources = (options: SourceOptions): MediaSource[] => {
  const sources: MediaSource[] = [
    { id: "vanilla", mediaDirs: [path.join(options.gameFilesPath, "media")], incompatible: [] },
  ];
  const mods = new Map<string, string>();
  const workshop = options.workshopContentPath ?? getWorkshopContentPath(options.gameFilesPath);

  for (const workshopId of workshop ? listDirs(workshop) : []) {
    const modsDir = path.join(workshop!, workshopId, "mods");

    for (const name of listDirs(modsDir)) {
      mods.set(name, path.join(modsDir, name));
    }
  }

  // local copies win over workshop ones, like in game
  for (const name of options.localModsPath ? listDirs(options.localModsPath) : []) {
    mods.set(name, path.join(options.localModsPath!, name));
  }

  for (const [name, dir] of [...mods].sort(([a], [b]) => a.localeCompare(b))) {
    const mediaDirs = getModMediaDirs(dir);

    if (mediaDirs.length) {
      sources.push({ ...readModInfo(dir, name), mediaDirs });
    }
  }

  return sources;
};
