export async function ensureLinesInFile(
  path: string,
  lines: string[]
): Promise<void> {
  const fileContent = await Deno.readTextFile(path);
  const linesToAdd = lines.filter((line) => !fileContent.includes(line));
  if (linesToAdd.length > 0) {
    await Deno.writeTextFile(path, linesToAdd.join("\n"), { append: true });
  }
}
