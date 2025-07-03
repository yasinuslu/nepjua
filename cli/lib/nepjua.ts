import { exists } from "jsr:@std/fs@^1.0.18/exists";
import { dirname } from "jsr:@std/path@^1.0.8/dirname";
import { join } from "jsr:@std/path@^1.0.8/join";
import { gitFindRoot } from "./git.ts";

export async function nepjuaResolveSecretPath() {
  const rootPath = await nepjuaResolveRootPath();
  return join(rootPath, ".main.enc.yaml");
}

export async function nepjuaResolveRootPath(): Promise<string> {
  try {
    console.log("Trying to find .main.enc.yaml in git root...");
    const root = await gitFindRoot();
    const mainSecretPath = join(root, ".main.enc.yaml");
    if (!(await exists(mainSecretPath))) {
      throw new Error("No .main.enc.yaml found in git root");
    }

    return dirname(mainSecretPath);
  } catch (error) {
    console.error(error);
    console.log("No .main.enc.yaml found in git root, continuing...");
  }

  try {
    console.log("Trying to find .main.enc.yaml in usual locations...");
    const userHome = Deno.env.get("HOME");
    if (!userHome) {
      throw new Error("HOME environment variable is not set");
    }

    const mainSecretPath = join(userHome, "code/nepjua/.main.enc.yaml");
    if (!(await exists(mainSecretPath))) {
      throw new Error(`No .main.enc.yaml found at ${mainSecretPath}`);
    }

    return dirname(mainSecretPath);
  } catch (error) {
    throw error;
  }
}
