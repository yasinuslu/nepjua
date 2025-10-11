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
in
{
  home.packages = with pkgs; [
    nodejs
  ];

  home.activation = {
    mutableNodeModules = dag.entryAfter [ "writeBoundary" ] ''
      execute_with_retries() {
        local command="$1"
        local message="$2"
        echo ""
        for i in {1..10}; do
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
      fi

      npm config set prefix ${globalNodeModules}
      execute_with_retries "npm uninstall -g pnpm yarn" "Uninstalling existing global pnpm and yarn modules"
      execute_with_retries "npm i -g corepack" "Installing corepack..."
      execute_with_retries "corepack install -g pnpm@10 yarn" "Installing pnpm and yarn..."
    '';
  };

  myHomeManager.paths = [
    "${pnpmHome}"
    "${globalNodeModules}/bin"
  ];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = globalNodeModules;
    PNPM_HOME = pnpmHome;
  }
  // (if builtins.pathExists caFileAbsolute then { NODE_EXTRA_CA_CERTS = caFileEnv; } else { });
}
