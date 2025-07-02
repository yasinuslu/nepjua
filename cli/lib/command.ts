import $ from "@david/dax";

export interface CommandResult {
  stdoutJson: any;
  text: string;
}

export interface CommandBuilder {
  stdout(type: string): CommandBuilder;
  then<T>(callback: (result: CommandResult) => T): Promise<T>;
  text(): Promise<string>;
  exec(): Promise<void>;
}

class DaxCommandBuilder implements CommandBuilder {
  constructor(private command: any) {}

  stdout(type: string): CommandBuilder {
    return new DaxCommandBuilder(this.command.stdout(type));
  }

  async then<T>(callback: (result: CommandResult) => T): Promise<T> {
    const result = await this.command;
    return callback({
      stdoutJson: result.stdoutJson,
      text: result.stdout,
    });
  }

  async text(): Promise<string> {
    return await this.command.text();
  }

  async exec(): Promise<void> {
    await this.command;
  }
}

export function command(
  template: TemplateStringsArray,
  ...values: any[]
): CommandBuilder {
  const daxCommand = $(template, ...values);
  return new DaxCommandBuilder(daxCommand);
}

export default command;
