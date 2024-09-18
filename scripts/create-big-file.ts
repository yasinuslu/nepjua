import fs from "fs/promises";
import path from "path";

type CreateBigFileOptions = {
  path: string;
  size?: number;
};

async function createBigFile({ path, size = 1024 }: CreateBigFileOptions) {
  const bufferSize = 1024 * 1024; // 1MB buffer
  const buffer = new Uint8Array(bufferSize).fill(65); // Fill buffer with 'A' (ASCII 65)
  let writtenBytes = 0;

  // Open a write stream to avoid loading all data into memory
  const fileHandle = await fs.open(path, "w");

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

function parseArguments() {
  // const args = Bun.
}

async function main() {}

main();
