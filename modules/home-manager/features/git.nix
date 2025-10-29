{ pkgs, ... }:
let
  git-rebase-tracked = pkgs.writeShellScriptBin "git-rebase-tracked" ''
    set -euo pipefail
    
    # Get the tracked branch
    tracked_branch=$(git rev-parse --abbrev-ref @{u} 2>/dev/null || true)
    
    if [ -z "$tracked_branch" ]; then
      echo "Error: No upstream branch is set for the current branch."
      echo "Set it with: git branch --set-upstream-to=<remote>/<branch>"
      exit 1
    fi
    
    # Fetch and rebase
    git fetch
    git rebase "$tracked_branch"
  '';

  git-reset-tracked = pkgs.writeShellScriptBin "git-reset-tracked" ''
    set -euo pipefail
    
    # Get the tracked branch
    tracked_branch=$(git rev-parse --abbrev-ref @{u} 2>/dev/null || true)
    
    if [ -z "$tracked_branch" ]; then
      echo "Error: No upstream branch is set for the current branch."
      echo "Set it with: git branch --set-upstream-to=<remote>/<branch>"
      exit 1
    fi
    
    # Fetch and reset with provided arguments
    git fetch
    git reset "$tracked_branch" "$@"
  '';

  git-remove-branches-except = pkgs.writeShellScriptBin "git-remove-branches-except" ''
    set -euo pipefail
    
    # Remove all git branches except the specified ones
    if [ $# -eq 0 ]; then
      git branch | grep -v main | xargs git branch -D
    else
      branch_regex=$(IFS='|'; echo "$*")
      git branch | grep -vE "main|$branch_regex" | xargs git branch -D
    fi
  '';

  git-local-upstream-exec = pkgs.writeShellScriptBin "git-local-upstream-exec" ''
    set -euo pipefail
    
    # Execute given command in an upstream that is defined via local filesystem
    current_dir=$(pwd)
    upstream=$(git config --local --get remote.origin.url | sed -e 's/.*\/\([^ ]*\/[^.]*\)\.git/\1/')
    
    if [ -z "$upstream" ]; then
      echo "Error: Could not determine upstream directory from remote.origin.url"
      exit 1
    fi
    
    cd "$upstream"
    eval "$@"
    cd "$current_dir"
  '';

  git-with-all-upstream-exec = pkgs.writeShellScriptBin "git-with-all-upstream-exec" ''
    set -euo pipefail
    
    # Execute given command both in current git and upstream
    git-local-upstream-exec "$@"
    eval "$@"
  '';
in
{
  home.packages = with pkgs; [
    transcrypt
    git-rebase-tracked
    git-reset-tracked
    git-remove-branches-except
    git-local-upstream-exec
    git-with-all-upstream-exec
  ];
}
