{ pkgs, ... }:
let
  nixLdWrapper = pkgs.writeScriptBin "nix-ld" ''
    #!${pkgs.stdenv.shell}
    export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
    exec "$@"
  '';

  playwrightWrapper = pkgs.writeScriptBin "playwright" ''
    #!/usr/bin/env bash

    # Find the next playwright in PATH that isn't this wrapper
    SCRIPT_PATH="$(readlink -f "$0")"

    # Use whereis to find all playwright executables
    PLAYWRIGHT_PATHS=$(whereis -b playwright | cut -d: -f2- | tr -s ' ' '\n' | grep -v "^$")

    # Find the first one that's not our wrapper
    NEXT_PLAYWRIGHT=""
    for path in $PLAYWRIGHT_PATHS; do
      if [ -x "$path" ] && [ "$(readlink -f "$path")" != "$SCRIPT_PATH" ]; then
        NEXT_PLAYWRIGHT="$path"
        break
      fi
    done

    # If we didn't find another playwright, exit with error
    if [ -z "$NEXT_PLAYWRIGHT" ]; then
      echo "Error: Could not find playwright executable in PATH" >&2
      exit 1
    fi

    # Execute with nix-ld if available
    if command -v nix-ld &> /dev/null; then
      nix-ld "$NEXT_PLAYWRIGHT" "$@"
    else
      "$NEXT_PLAYWRIGHT" "$@"
    fi
  '';
in
{
  environment.systemPackages = [
    nixLdWrapper
    playwrightWrapper
  ];

  programs.nix-ld.enable = true;
}
