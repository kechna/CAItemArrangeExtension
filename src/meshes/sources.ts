import { existsSync, readdirSync, statSync } from "node:fs";
import path from "node:path";

/** Project Zomboid's Steam app id, the workshop content folder is named after it. */
const APP_ID = "108600";

export interface MediaSource {
  /** `vanilla`, or the mod id */
  id: string;
  /** media folders in load order, later ones override earlier ones */
  mediaDirs: string[];
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

/**
 * Media folders of one mod as Build 42 loads them: `common/media`, then the highest version folder. The installed game
 * is assumed to be recent enough for every folder, since its version can't be read from the install. Mods without
 * version folders are Build 41 style and use `media` directly.
 */
const getModMediaDirs = (modDir: string): string[] => {
  const versions = listDirs(modDir)
    .filter((name) => /^\d+(\.\d+)*$/.test(name))
    .sort(compareVersions);
  const latest = versions[versions.length - 1];

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
  const sources: MediaSource[] = [{ id: "vanilla", mediaDirs: [path.join(options.gameFilesPath, "media")] }];
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

  for (const [id, dir] of [...mods].sort(([a], [b]) => a.localeCompare(b))) {
    const mediaDirs = getModMediaDirs(dir);

    if (mediaDirs.length) {
      sources.push({ id, mediaDirs });
    }
  }

  return sources;
};
