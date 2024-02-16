import { Command } from "https://deno.land/x/cliffy@v1.0.0-rc.3/command/mod.ts";
import * as fs from "https://deno.land/std@0.215.0/fs/mod.ts";
import * as path from "https://deno.land/std@0.215.0/path/mod.ts";
import { pascalCase } from "https://deno.land/x/case@2.2.0/mod.ts";

export const barrel = new Command()
  .description("Generate a barrel file")
  .option("-o, --output <output:string>", "The output file path")
  .option("-r, --root <searchRoot:string>", "Root path to search for files")
  .action(async (params) => {
    console.log("Generating barrel file...");
    console.log("Output file:", params.output);

    if (!params.output) {
      return console.error("Output file is required");
    }

    const currentDirectory = Deno.cwd();
    const outputPath = path.resolve(currentDirectory, params.output);
    const outputDirectoryPath = path.dirname(outputPath);
    const searchRoot = params.searchRoot
      ? path.resolve(currentDirectory, params.searchRoot)
      : outputDirectoryPath;

    if (!(await fs.exists(searchRoot))) {
      return console.error("Search root does not exist", searchRoot);
    }

    const generateFileEntry = (filePath: string) => {
      const absolutePath = filePath;
      const relativePath = path.relative(outputDirectoryPath, absolutePath);
      let pathParts = relativePath.split("/");
      // pathParts.filter(part => );
      const moduleName = pascalCase(relativePath.replace(/\.[^/.]+$/, ""));
      const importAllName = pascalCase(relativePath.replace(/\.[^/.]+$/, ""));
      const importDefaultName = pascalCase(
        relativePath.replace(/\.[^/.]+$/, "")
      );
      const generateSections = {
        importAs: `import * as ${name} from "./${relativePath}";`,
        importDefaultAs: `import { default as } from "./${relativePath}";`,
      };

      return {
        absolutePath,
        relativePath,
        moduleName,
        importAllName,
        importDefaultName,
        generateSections,
      };
    };

    const files = fs.expandGlob("**/*[.ts,.tsx.js,.jsx]", {
      includeDirs: false,
      root: searchRoot,
      exclude: ["**/node_modules/**", outputPath],
    });

    const entries = [];

    for await (const file of files) {
      entries.push(generateFileEntry(file.path));
    }

    console.log("Import sections:", entries);
  });
