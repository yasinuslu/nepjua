{
  pkgs,
  lib,
  ...
}:
let
  # Shared launcher: remote VS Code / Cursor CLIs first (SSH/WSL remote), then Zed (Homebrew `zed` on macOS), then vim.
  # Zed CLI: flags before paths — `zed --wait` / `zed -w` blocks until opened buffers close (git commit, etc.).
  # https://zed.dev/docs/reference/cli.html — forward `"$@"` so `EDITOR=e --wait` passes `--wait` through to `zed`.
  editorScriptBody = ''
    is_remote_vscode_path() {
      if [[ "$1" == */remote-cli/* ]]; then
        return 0
      fi

      return 1
    }

    is_available() {
      if [ -z "$1" ]; then
        return 1
      fi

      return 0
    }

    CODE_PATH="$(command -v code)"
    CURSOR_PATH="$(command -v cursor)"
    ZED_PATH="$(command -v zed)"
    VIM_PATH="$(command -v vim)"
    FULL_PWD="$( realpath "$PWD" )"

    if is_remote_vscode_path "$CODE_PATH"; then
      __REMOTE_CODE__ "$@"
    elif is_remote_vscode_path "$CURSOR_PATH"; then
      cursor "$@"
    elif [[ "$FULL_PWD" == */*astercont*/* ]]; then
      zed-mc "$@"
    elif [[ "$FULL_PWD" == */yasinuslu/* ]]; then
      zed "$@"
    elif is_available "$ZED_PATH"; then
      zed "$@"
    elif is_available "$VIM_PATH"; then
      ARGS_WITHOUT_WAIT=()

      for arg in "$@"; do
        if [[ "$arg" != "--wait" ]]; then
          ARGS_WITHOUT_WAIT+=("$arg")
        fi
      done

      vim "''${ARGS_WITHOUT_WAIT[@]}"
    fi
  '';

  editorPackage = pkgs.writeShellScriptBin "e" (
    lib.replaceStrings [ "__REMOTE_CODE__" ] [ "code" ] editorScriptBody
  );

  editorBetaPackage = pkgs.writeShellScriptBin "eb" (
    lib.replaceStrings [ "__REMOTE_CODE__" ] [ "code-insiders" ] editorScriptBody
  );

  editorRealPath = pkgs.writeShellScriptBin "er" ''
    ${editorPackage}/bin/e $(realpath "$1")
  '';

  zedMcPackage = pkgs.writeShellScriptBin "zed-mc" ''
    zed "$@"
  '';

  # zed-sops shim. The meesk/zed-sops extension's `sops-lsp` invokes the `sops`
  # binary at its configured `sopsPath` to decrypt / re-encrypt the file under the
  # cursor — e.g. `sops decrypt --input-type T --output-type T <file>` and
  # `sops <file>`. Zed's process doesn't inherit the per-repo SOPS_AGE_KEY_FILE
  # that direnv sets in each project's shell, so this shim discovers the right key
  # per call: it walks up from the file being operated on (the last path argument)
  # to find that repo's own <repo>/.sops/age-key.txt, exports SOPS_AGE_KEY_FILE,
  # then execs the real sops. Installed at the stable home-manager profile path
  # /etc/profiles/per-user/nepjua/bin/sops-zed, wired up from config/zed-settings.jsonc.
  sopsZedPackage = pkgs.writeShellScriptBin "sops-zed" ''
    set -euo pipefail

    # The file sops operates on is the last path-like argument (decrypt puts it
    # last; re-encrypt passes it alone). Fall back to $PWD when there is none.
    start_dir="$PWD"
    for arg in "$@"; do
      if [ -f "$arg" ]; then
        start_dir="$(cd "$(dirname "$arg")" && pwd)"
      fi
    done

    # Walk up from there to the repo's age key and point sops at it.
    dir="$start_dir"
    while [ "$dir" != "/" ]; do
      if [ -f "$dir/.sops/age-key.txt" ]; then
        export SOPS_AGE_KEY_FILE="$dir/.sops/age-key.txt"
        break
      fi
      dir="$(dirname "$dir")"
    done

    exec ${pkgs.sops}/bin/sops "$@"
  '';
in
{
  home.packages = [
    editorPackage
    editorBetaPackage
    editorRealPath
    zedMcPackage
    sopsZedPackage
  ];

  # Same idea as `zed --wait` / `GIT_EDITOR="zed --wait"`; `e` adds path/remote routing then delegates to `zed`.
  home.sessionVariables = {
    EDITOR = "e --wait";
    VISUAL = "e --wait";
    CODE_EDITOR = "e --wait";
    REACT_EDITOR = "e --wait";
  };
}
