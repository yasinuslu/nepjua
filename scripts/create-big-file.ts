import fs from "fs/promises";
import path from "path";

type CreateBigFileOptions = {
  file: string;
  size: number;
};

async function createBigFile(options: CreateBigFileOptions) {
  const bufferSize = 1024 * 1024; // 1MB buffer
  const buffer = new Uint8Array(bufferSize).fill(65); // Fill buffer with 'A' (ASCII 65)
  let writtenBytes = 0;

  const size = options.size * 1024; // options.size is in KB
  const filePath = path.resolve(process.cwd(), options.file);

  // Open a write stream to avoid loading all data into memory
  const fileHandle = await fs.open(filePath, "w");

  try {
    while (writtenBytes < size) {
      const remainingSize = size - writtenBytes;
      const chunkSize = Math.min(bufferSize, remainingSize);

      // Write the buffer chunk to the file
      await fileHandle.write(buffer.slice(0, chunkSize));
      writtenBytes += chunkSize;
    }
  } finally {
    // Close the file handle
    await fileHandle.close();
  }
}

function getStringIfNotEmpty(value: string | undefined): string | undefined {
  if (value === undefined) {
    return undefined;
  }

  return value === "" ? undefined : value;
}

function parseArguments() {
  const args = Bun.argv.slice(2);
  const fileNameArg = getStringIfNotEmpty(args[0]);
  const sizeArg = getStringIfNotEmpty(args[1]) ?? "1"; // Default to 1KB

  if (fileNameArg === undefined || sizeArg === undefined) {
    console.error("Usage: ts-node create-big-file.ts <file> <size>");
    throw new Error("Invalid arguments");
  }

  if (!Number.isInteger(Number.parseInt(sizeArg, 10))) {
    console.error("Size must be an integer");
    throw new Error("Invalid arguments");
  }

  const options: CreateBigFileOptions = {
    file: fileNameArg,
    size: Number.parseInt(sizeArg, 10),
  };

  return options;
}

async function main() {
  const options = parseArguments();
  await createBigFile(options);
}

main();
