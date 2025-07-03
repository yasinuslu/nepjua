import { parse } from "@std/yaml/parse";
import { stringify } from "@std/yaml/stringify";
import { ensureFileContent } from "../fs.ts";
import { nepjuaResolveSecretPath } from "../nepjua.ts";
import { sopsReadAndDecrypt } from "../sops.ts";
import { SecretSchema, type SecretSchemaType } from "./schema.ts";

export async function secretRead() {
  const secretPath = await nepjuaResolveSecretPath();
  const yamlContent = await sopsReadAndDecrypt(secretPath);
  const content = parse(yamlContent);
  const parsed = await SecretSchema.parseAsync(content);
  return parsed;
}

export async function secretWrite(secret: SecretSchemaType) {
  const secretPath = await nepjuaResolveSecretPath();
  const parsed = await SecretSchema.parseAsync(secret);
  const yamlContent = stringify(parsed);
  await ensureFileContent(secretPath, yamlContent, true);
}
