import { exists } from "jsr:@std/fs@1/exists";
import { basename } from "jsr:@std/path@1/basename";
import { extname } from "jsr:@std/path@1/extname";
import { dirname } from "jsr:@std/path@^1.0.8/dirname";
import { join } from "jsr:@std/path@^1.0.8/join";
import path from "node:path";
import { $ } from "zx";
import { sopsDecrypt } from "./sops.ts";

export async function ensureLinesInFile(
  filePath: string,
  lines: string[],
  { mode = "append" }: { mode?: "append" | "prepend" } = {}
): Promise<void> {
  if (!(await Deno.stat(filePath).catch(() => false))) {
    await Deno.mkdir(path.dirname(filePath), { recursive: true });
    await Deno.writeTextFile(filePath, "");
  }

  const originalContent = await Deno.readTextFile(filePath);
  const existingLines = lines.filter((line) => originalContent.includes(line));
  if (existingLines.length === lines.length) {
    return;
  }

  let newContent = originalContent;

  if (existingLines.length > 0) {
    for (const line of existingLines) {
      newContent = newContent.replace(line, "");
    }
  }

  if (mode === "append") {
    newContent = newContent + "\n" + lines.join("\n");
  } else {
    newContent = lines.join("\n") + "\n" + newContent;
  }

  await Deno.writeTextFile(filePath, newContent);
}

/**
 * Recursively removes files that are not in the expected set of file paths
 */
async function removeUnexpectedFiles(
  dir: string,
  expectedFilePaths: Set<string>
) {
  for await (const entry of Deno.readDir(dir)) {
    const path = join(dir, entry.name);
    if (entry.isDirectory) {
      await removeUnexpectedFiles(path, expectedFilePaths);
      // Check if directory is now empty and remove it if it is
      const dirEntries = [...Deno.readDirSync(path)];
      if (dirEntries.length === 0) {
        await Deno.remove(path);
      }
    } else if (!expectedFilePaths.has(path)) {
      await Deno.remove(path);
    }
  }
}

export type FileDescription = {
  content: string;
  isEncrypted?: boolean;
};

export type FileDescriptionMap = Record<string, FileDescription>;

type EnsureDirectoryContentOptions = {
  prune?: boolean;
};

export async function ensureDirectoryContent(
  directory: string,
  files: FileDescriptionMap,
  { prune = true }: EnsureDirectoryContentOptions = {}
) {
  if (!(await exists(directory))) {
    await Deno.mkdir(directory, { recursive: true });
  }

  for (const [key, value] of Object.entries(files)) {
    await ensureFileContent(
      join(directory, key),
      value.content,
      value.isEncrypted ?? false
    );
  }

  if (prune) {
    // Then recursively check for any files that shouldn't be there
    const expectedFilePaths = new Set(
      Object.keys(files).map((key) => join(directory, key))
    );
    await removeUnexpectedFiles(directory, expectedFilePaths);
  }
}

export async function ensureFileContent(
  fullPath: string,
  rawDesiredContent: string,
  isEncrypted: boolean
) {
  const directory = dirname(fullPath);

  if (!(await exists(directory))) {
    await Deno.mkdir(directory, { recursive: true });
  }

  if (await exists(fullPath)) {
    const currentRawContent = await Deno.readTextFile(fullPath);
    if (isEncrypted) {
      const currentEncryptedContent = await sopsDecrypt(fullPath);
      if (currentEncryptedContent === rawDesiredContent) {
        return;
      }
    } else {
      if (currentRawContent === rawDesiredContent) {
        return;
      }
    }
  }

  if (isEncrypted) {
    const extension = extname(fullPath);
    const filenameWithExtension = basename(fullPath);
    const filename = filenameWithExtension.replace(extension, "");
    const tmpDecryptedFile = join(directory, `${filename}.tmp${extension}`);
    await Deno.writeTextFile(tmpDecryptedFile, rawDesiredContent);
    const encryptedFile = join(directory, `${filename}${extension}`);
    await $`sops encrypt --filename-override ${encryptedFile} ${tmpDecryptedFile} | tee ${encryptedFile}`.text();
    await Deno.remove(tmpDecryptedFile);
  } else {
    await Deno.writeTextFile(fullPath, rawDesiredContent);
  }
}
