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

    HAS_WAIT_ARG=false

    for arg in "$@"; do
      if [[ "$arg" == "--wait" ]]; then
        HAS_WAIT_ARG=true
      fi
    done

    if is_remote_vscode_path "$CODE_PATH"; then
      if $HAS_WAIT_ARG; then
        code --wait "$@"
      else
        code "$@"
      fi
    elif is_remote_vscode_path "$CURSOR_PATH"; then
      if $HAS_WAIT_ARG; then
        cursor --wait "$@"
      else
        cursor "$@"
      fi
    elif [[ "$FULL_PWD" == */mastercontrol/* ]]; then
      if $HAS_WAIT_ARG; then
        code --wait "$@"
      else
        code "$@"
      fi
    elif [[ "$FULL_PWD" == */yasinuslu/* ]]; then
      if $HAS_WAIT_ARG; then
        cursor --wait "$@"
      else
        cursor "$@"
      fi
    elif is_available "$CURSOR_PATH"; then
      if $HAS_WAIT_ARG; then
        cursor --wait "$@"
      else
        cursor "$@"
      fi
    elif is_available "$VIM_PATH"; then
      vim "$@"
    fi
  '';
in
{
  home.packages = [ editorPackage ];

  home.sessionVariables = {
    EDITOR = "e --wait";
    CODE_EDITOR = "e --wait";
    REACT_EDITOR = "e --wait";
  };
}
