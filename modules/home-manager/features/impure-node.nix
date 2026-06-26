# This is where we setup our impure (but very flexible) nodejs environment
{
  pkgs,
  lib,
  config,
  ...
}:
let
  dag = lib.hm.dag;
  nodeBinDir = "${pkgs.nodejs}/bin";
  npmHome = "$HOME/.npm";
  pnpmHome = "$HOME/.nix-mutable/node/pnpm";
  globalNodeModules = "$HOME/.nix-mutable/node/npm/node_modules";
  caFileRelative = "code/nepjua/.generated/cert/ca-bundle.pem";
  caFileEnv = "$HOME/${caFileRelative}";
  caFileAbsolute = "${config.home.homeDirectory}/${caFileRelative}";
  # corepack's `enable` defaults to installing shims next to the node binary,
  # which lives in the read-only nix store. Force it to a writable dir.
  corepackWrapper = pkgs.writeShellScriptBin "corepack" ''
    if [ "''${1:-}" = "enable" ]; then
      shift
      exec ${pkgs.nodejs}/bin/corepack enable --install-directory "${globalNodeModules}/bin" "$@"
    fi
    exec ${pkgs.nodejs}/bin/corepack "$@"
  '';
in
{
  home.packages = [
    pkgs.nodejs
    (lib.hiPrio corepackWrapper)
  ];

  home.activation = {
    mutableNodeModules = dag.entryAfter [ "writeBoundary" ] ''
      execute_with_retries() {
        local command="$1"
        local message="$2"
        echo ""
        for i in {1..5}; do
          echo "=================="
          echo "Executing: $command"
          echo "Message: $message"
          echo "Attempt $i of 5"
          echo "=================="
          if eval "time $command"; then
            echo ""
            echo "== Command succeeded =="
            return 0
          else
            echo "Failed: $message, retrying..."
            sleep 1
          fi
        done
      }

      echo "Cleaning up existing global node_modules..."
      rm -rf "${npmHome}"
      # Optional, when needed
      # rm -rf "${pnpmHome}"
      rm -rf "${globalNodeModules}"
      mkdir -p "${globalNodeModules}"
      mkdir -p "${pnpmHome}"
      echo "Done"

      export PATH="${pnpmHome}:${nodeBinDir}:${globalNodeModules}/bin:$PATH"
      export PNPM_HOME="${pnpmHome}"

      if [ -f "${caFileEnv}" ]; then
        export NODE_EXTRA_CA_CERTS="${caFileEnv}"
        npm config set cafile "${caFileEnv}"
      else
        npm config delete cafile
      fi

      npm config set prefix ${globalNodeModules}
      execute_with_retries "npm uninstall -g pnpm yarn" "Uninstalling existing global pnpm and yarn modules"
      execute_with_retries "npm i -g corepack" "Installing corepack..."
      execute_with_retries "corepack install -g pnpm yarn" "Installing pnpm and yarn..."
    '';
  };

  myHomeManager.paths = [
    "${corepackWrapper}/bin"
    "${pnpmHome}"
    "${globalNodeModules}/bin"
    "$HOME/.bun/bin"
  ];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = globalNodeModules;
    PNPM_HOME = pnpmHome;
    BUN_INSTALL = "$HOME/.bun";
  }
  // (if builtins.pathExists caFileAbsolute then { NODE_EXTRA_CA_CERTS = caFileEnv; } else { });
}
