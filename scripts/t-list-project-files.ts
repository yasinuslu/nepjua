#!/usr/bin/env bun

import { FileBlob, Glob } from "bun";
import createDebug from "debug";
import yaml from "js-yaml";

const debug = createDebug("w3yz:generate-yaml");

const projectName = "w3yz";

async function generateYAML(app: string, appPath: string) {
  const glob = new Glob(`${appPath}/**/*.{js,jsx,ts,tsx,json,yaml,yml,md}`);
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
  ];

  const allowedBigFileGlobs = [new Glob("**/dev-w3yz_platform.json")];

  const blobMap = new Map<string, FileBlob>();

  for await (const path of glob.scan(".")) {
    if (ignoreGlobs.some((g) => g.match(path))) {
      continue;
    }

    const file = Bun.file(path);
    if (!allowedBigFileGlobs.some((g) => g.match(path))) {
      if (file.size > 30 * 1024) {
        console.warn(`File ${path} is too large, skipping`);
        continue;
      }
    }

    blobMap.set(path, file);
  }

  const fileContents = await Promise.all(
    Array.from(blobMap.entries()).map(async ([path, blob]) => {
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

  // await generateYAML("workflows", "./.github/workflows");
  await generateYAML("w3yz-app-api", "./apps/api");
  await generateYAML("w3yz-app-dashboard", "./apps/dashboard");
  // await generateYAML("w3yz-app-landing", "./apps/landing");
  // await generateYAML(
  //   "w3yz-app-saleor-app-iyzico-payment",
  //   "./apps/saleor-app-iyzico-payment"
  // );
  // await generateYAML("w3yz-app-storefront", "./apps/storefront");
  // await generateYAML("w3yz-app-tinacms", "./apps/tinacms");
  await generateYAML("w3yz-ops", "./ops");
  // await generateYAML("w3yz-cms", "./packages/cms");
  // await generateYAML("w3yz-ecom", "./packages/ecom");
  // await generateYAML(
  //   "w3yz-eslint-config-eslint",
  //   "./packages/eslint-config-eslint"
  // );
  // await generateYAML("w3yz-saleor-app-sdk", "./packages/saleor-app-sdk");
  // await generateYAML("w3yz-sdk", "./packages/sdk");
  // await generateYAML("w3yz-tools", "./packages/tools");
} catch (error) {
  console.error(error);
  process.exit(1);
}
