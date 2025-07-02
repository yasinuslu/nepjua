export async function ensureLinesInFile(
  path: string,
  lines: string[],
  { mode = "append" }: { mode?: "append" | "prepend" } = {}
): Promise<void> {
  const originalContent = await Deno.readTextFile(path);
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

  await Deno.writeTextFile(path, newContent);
}
