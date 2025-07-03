import { z } from "zod";

export const SecretSchema = z.strictObject({
  "reserved-for-future-use": z.coerce.string(),
});

export type SecretSchemaType = z.infer<typeof SecretSchema>;
