export interface GitRemote {
  name: string;
  url: string;
  type: "fetch" | "push";
}

export interface GitNamespace {
  owner: string;
  repo: string;
  full: string; // owner/repo
}

interface CommandResult {
  stdout: string;
  stderr: string;
  code: number;
}

async function shellRunCommand(cmd: string[]): Promise<CommandResult> {
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

/**
 * Find the git repository root directory
 */
export async function gitFindRoot(): Promise<string> {
  try {
    const result = await shellRunCommand([
      "git",
      "rev-parse",
      "--show-toplevel",
    ]);
    if (result.code !== 0) {
      throw new Error("Not in a git repository");
    }
    return result.stdout.trim();
  } catch (error) {
    throw new Error(
      `Failed to find git root: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

/**
 * Get all git remotes
 */
export async function gitGetRemotes(): Promise<GitRemote[]> {
  try {
    const result = await shellRunCommand(["git", "remote", "-v"]);
    if (result.code !== 0) {
      throw new Error("Failed to get git remotes");
    }

    const remotes: GitRemote[] = [];
    const lines = result.stdout
      .trim()
      .split("\n")
      .filter((line: string) => line.trim());

    for (const line of lines) {
      const match = line.match(/^(\S+)\s+(\S+)\s+\((\w+)\)$/);
      if (match) {
        remotes.push({
          name: match[1],
          url: match[2],
          type: match[3] as "fetch" | "push",
        });
      }
    }

    return remotes;
  } catch (error) {
    throw new Error(
      `Failed to get git remotes: ${
        error instanceof Error ? error.message : String(error)
      }`
    );
  }
}

/**
 * Parse GitHub URL to extract owner/repo
 */
function gitParseGitHubUrl(url: string): GitNamespace | null {
  // Handle different GitHub URL formats:
  // - https://github.com/owner/repo.git
  // - https://github.com/owner/repo
  // - git@github.com:owner/repo.git
  // - git@github.com:owner/repo
  // - git@github.com-profile:owner/repo.git (SSH profiles)
  // - git@github.com-profile:owner/repo

  const patterns = [
    // HTTPS format
    /^https:\/\/github\.com\/([^\/]+)\/([^\/]+?)(?:\.git)?(?:\/)?$/,
    // SSH format with optional profiles: git@github.com(-profile):owner/repo.git
    /^git@github\.com(?:-[^:]+)?:([^\/]+)\/([^\/]+?)(?:\.git)?$/,
  ];

  for (const pattern of patterns) {
    const match = url.match(pattern);
    if (match) {
      const owner = match[1];
      const repo = match[2];
      return {
        owner,
        repo,
        full: `${owner}/${repo}`,
      };
    }
  }

  return null;
}

/**
 * Get the primary GitHub namespace for the current repository
 * Prioritizes 'origin' remote, falls back to first available
 */
export async function gitGetGitHubNamespace(): Promise<GitNamespace> {
  const remotes = await gitGetRemotes();

  if (remotes.length === 0) {
    throw new Error("No git remotes found");
  }

  // Filter to only fetch remotes and GitHub URLs
  const githubRemotes = remotes
    .filter((remote) => remote.type === "fetch")
    .map((remote) => ({
      ...remote,
      namespace: gitParseGitHubUrl(remote.url),
    }))
    .filter((remote) => remote.namespace !== null);

  if (githubRemotes.length === 0) {
    throw new Error("No GitHub remotes found");
  }

  // Prefer 'origin' remote
  const originRemote = githubRemotes.find((remote) => remote.name === "origin");
  if (originRemote) {
    return originRemote.namespace!;
  }

  // Fall back to first GitHub remote
  return githubRemotes[0].namespace!;
}

/**
 * Get repository name from current directory or git remote
 */
async function gitGetRepoName(): Promise<string> {
  try {
    const namespace = await gitGetGitHubNamespace();
    return namespace.repo;
  } catch {
    // Fallback to directory name
    const cwd = Deno.cwd();
    return cwd.split("/").pop() || "unknown";
  }
}

/**
 * Check if current directory is a git repository
 */
export async function gitIsRepository(): Promise<boolean> {
  try {
    await gitFindRoot();
    return true;
  } catch {
    return false;
  }
}
