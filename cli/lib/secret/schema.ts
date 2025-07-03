import { z } from "zod";

const MultilineStringSchema = z.coerce.string().transform((val) =>
  val
    .split("\n")
    .map((line) => line.trim())
    .join("\\n")
);

const HostSchema = z.strictObject({
  username: z.string(),
  certificates: z.array(MultilineStringSchema),
});

export const SecretSchema = z.strictObject({
  hosts: z.strictObject({
    chained: HostSchema,
    joyboy: HostSchema,
  }),
});

export type SecretSchemaType = z.infer<typeof SecretSchema>;
