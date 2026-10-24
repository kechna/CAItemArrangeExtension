export interface ScriptBlock {
  kind: string;
  name: string;
  /** Top-level `key = value` pairs, nested blocks (attachments, fluid definitions…) are left out. */
  properties: Record<string, string>;
  /** nested blocks of the kinds asked for, e.g. a model's `attachment world { … }` */
  children: ScriptBlock[];
}

/** Java's `lastIndexOf`, which finds nothing for a negative start unlike JavaScript's. */
const lastIndexOf = (text: string, search: string, from: number): number =>
  from < 0 ? -1 : text.lastIndexOf(search, from);

/**
 * Block comments the way `ScriptParser.stripComments` removes them: from the last `*\/` back to its `/*`, nested ones
 * included. Mods rely on that, e.g. damnlib separates models with `/*\/` lines, which the game reads as one comment each.
 */
const stripBlockComments = (text: string): string => {
  let end = text.lastIndexOf("*/");

  while (end !== -1) {
    let start = lastIndexOf(text, "/*", end - 1);

    if (start === -1) {
      break;
    }

    let inner = lastIndexOf(text, "*/", end - 1);

    while (inner > start) {
      start = lastIndexOf(text, "/*", start - 2);

      if (start === -1) {
        break;
      }

      inner = lastIndexOf(text, "*/", inner - 2);
    }

    if (start === -1) {
      break;
    }

    text = text.slice(0, start) + text.slice(end + 2);
    end = lastIndexOf(text, "*/", start);
  }

  return text;
};

const stripComments = (text: string): string => stripBlockComments(text).replace(/(^|[^:])\/\/.*$/gm, "$1");

/** Index just past the `}` that closes the `{` at `open`, or the text length when it never closes. */
const findClose = (text: string, open: number): number => {
  let depth = 0;

  for (let i = open; i < text.length; i++) {
    if (text[i] === "{") {
      depth++;
    } else if (text[i] === "}") {
      depth--;

      if (depth === 0) {
        return i + 1;
      }
    }
  }

  return text.length;
};

const removeNestedBlocks = (body: string): string => {
  let result = "";

  for (let i = 0; i < body.length; i++) {
    if (body[i] === "{") {
      i = findClose(body, i) - 1;
      // drop the nested block's name too
      result = result.replace(/[\w.]+(\s+[\w.:-]+)?\s*$/, "");
    } else {
      result += body[i];
    }
  }

  return result;
};

/**
 * Finds `<kind> <Name> { … }` blocks (e.g. `item` and `model`) in a Project Zomboid script file. Lenient on purpose,
 * since mod scripts are often loosely formatted.
 */
export const parseScriptBlocks = (text: string, kinds: string[], childKinds: string[] = []): ScriptBlock[] => {
  const clean = stripComments(text);
  const blocks: ScriptBlock[] = [];
  const pattern = new RegExp(`\\b(${kinds.join("|")})\\s+([\\w.-]+)\\s*\\{`, "gi");

  for (let match = pattern.exec(clean); match; match = pattern.exec(clean)) {
    const open = pattern.lastIndex - 1;
    const close = findClose(clean, open);
    const inner = clean.slice(open + 1, close - 1);
    const body = removeNestedBlocks(inner);
    const properties: Record<string, string> = {};

    for (const entry of body.split(/[,\n]/)) {
      const separator = entry.indexOf("=");

      if (separator > 0) {
        properties[entry.slice(0, separator).trim().toLowerCase()] = entry.slice(separator + 1).trim();
      }
    }

    blocks.push({
      kind: match[1]!.toLowerCase(),
      name: match[2]!,
      properties,
      children: childKinds.length ? parseScriptBlocks(inner, childKinds) : [],
    });
    pattern.lastIndex = close;
  }

  return blocks;
};

/** Strips the module from a script reference: `Base.Bowl` → `Bowl`. */
export const shortName = (reference: string): string => reference.slice(reference.lastIndexOf(".") + 1);
