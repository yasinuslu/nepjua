{
  pkgs,
  lib,
  ...
}:
let
  editorPackage = pkgs.writeShellScriptBin "e" ''
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
    VIM_PATH="$(command -v vim)"
    FULL_PWD="$( realpath "$PWD" )"

    if is_remote_vscode_path "$CODE_PATH"; then
      code "$@"
    elif is_remote_vscode_path "$CURSOR_PATH"; then
      cursor "$@"
    elif [[ "$FULL_PWD" == */mastercontrol/* ]]; then
      code "$@"
    elif [[ "$FULL_PWD" == */yasinuslu/* ]]; then
      cursor "$@"
    elif is_available "$CURSOR_PATH"; then
      cursor "$@"
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
  editorBetaPackage = pkgs.writeShellScriptBin "eb" ''
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
    VIM_PATH="$(command -v vim)"
    FULL_PWD="$( realpath "$PWD" )"

    if is_remote_vscode_path "$CODE_PATH"; then
      code-insiders "$@"
    elif is_remote_vscode_path "$CURSOR_PATH"; then
      cursor "$@"
    elif [[ "$FULL_PWD" == */mastercontrol/* ]]; then
      code-insiders "$@"
    elif [[ "$FULL_PWD" == */yasinuslu/* ]]; then
      cursor "$@"
    elif is_available "$CURSOR_PATH"; then
      cursor "$@"
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

  editorRealPath = pkgs.writeShellScriptBin "er" ''
    ${editorPackage}/bin/e $(realpath "$1")
  '';
in
{
  home.packages = [
    editorPackage
    editorBetaPackage
    editorRealPath
  ];

  home.sessionVariables = {
    EDITOR = "e --wait";
    CODE_EDITOR = "e --wait";
    REACT_EDITOR = "e --wait";
  };
}
