import { z } from "zod";

export const SecretSchema = z.strictObject({
  "chained-combined-cert": z.coerce.string(),
  "joyboy-combined-cert": z.coerce.string(),
});

export type SecretSchemaType = z.infer<typeof SecretSchema>;
