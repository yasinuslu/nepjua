import { Glob } from "bun";
import createDebug from "debug";
import * as yaml from "js-yaml";

import type { FileBlob } from "bun";

const debug = createDebug("nepjua:generate-yaml");

const projectName = "nepjua";

async function generateYAML(app: string, appPath: string) {
  const glob = new Glob(`${appPath}/**/*.{nix,js,jsx,ts,tsx,json,yaml,yml,md}`);
  const ignoreGlobs = [
    new Glob("**/*.d.ts"),
    new Glob("**/old-components/**"),
    new Glob("**/old-charts/**"),
    new Glob("**/gen/**"),
    new Glob("**/shadcn/**"),
    new Glob("**/assets/**"),
    new Glob("**/encrypted-secret/**"),
    new Glob("**/keys/**"),
    new Glob("**/node_modules/**"),
    new Glob("**/__generated__/**"),
    new Glob("**/generated/**"),
    new Glob("**/*.gen.*"),
    new Glob("**/.direnv/**"),
  ];

  const allowedBigFileGlobs = [new Glob("**")];

  const blobMap = new Map<string, FileBlob>();

  for await (const path of glob.scan(".")) {
    if (ignoreGlobs.some((g) => g.match(path))) {
      continue;
    }

    const file = Bun.file(path);
    if (
      !allowedBigFileGlobs.some((g) => g.match(path)) &&
      file.size > 30 * 1024
    ) {
      console.warn(`File ${path} is too large, skipping`);
      continue;
    }

    blobMap.set(path, file);
  }

  const fileContents = await Promise.all(
    [...blobMap.entries()].map(async ([path, blob]) => {
      const text = await blob.text();
      const first1K = text.slice(0, 1024);
      return [path, first1K] as const;
    })
  );

  const content = Object.fromEntries(fileContents);

  const yamlContent = yaml.dump({
    project: projectName,
    app,
    content,
  });

  const outputFile = Bun.fileURLToPath(
    import.meta.resolve(`../__generated__/${app}.yaml`)
  );

  debug("Writing to file: ", outputFile);

  await Bun.write(outputFile, yamlContent);
}

try {
  await Bun.$`rm -rf __generated__`;
  await Bun.$`mkdir -p __generated__`;

  await generateYAML("nix-config", ".");
} catch (error) {
  console.error(error);
  throw error;
}
