import path from "node:path";

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
