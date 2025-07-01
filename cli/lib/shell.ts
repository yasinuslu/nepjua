/**
 * Shell command execution utilities
 */

export interface CommandResult {
  stdout: string;
  stderr: string;
  code: number;
}

export async function runCommand(cmd: string[]): Promise<CommandResult> {
  const process = new Deno.Command(cmd[0], {
    args: cmd.slice(1),
    stdout: "piped",
    stderr: "piped",
  });

  const { code, stdout, stderr } = await process.output();

  return {
    stdout: new TextDecoder().decode(stdout),
    stderr: new TextDecoder().decode(stderr),
    code,
  };
}
