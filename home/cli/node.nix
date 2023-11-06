{
  pkgs,
  lib,
  ...
}: let
  dag = lib.hm.dag;
  nodeBinDir = "${pkgs.nodejs}/bin";
  npmHome = "$HOME/.npm";
  pnpmHome = "$HOME/.nix-mutable/pnpm";
  bunHome = "$HOME/.nix-mutable/bun";
  globalNodeModules = "$HOME/.nix-mutable/npm/node_modules";
in {
  home.packages = with pkgs; [
    nodejs
  ];

  home.activation = {
    mutableNodeModules = dag.entryAfter ["writeBoundary"] ''
      echo "Cleaning up existing global node_modules..."
      rm -rf "${npmHome}"
      # Optional, when needed
      # rm -rf "${pnpmHome}"
      # rm -rf "${bunHome}"
      rm -rf "${globalNodeModules}"
      mkdir -p "${globalNodeModules}"
      mkdir -p "${pnpmHome}"
      mkdir -p "${bunHome}"
      echo "Done"
      export PATH="${bunHome}/bin:${pnpmHome}:${nodeBinDir}:${globalNodeModules}/bin:$PATH"
      export PNPM_HOME="${pnpmHome}"
      export BUN_INSTALL="${bunHome}"
      npm config set prefix ${globalNodeModules}
      echo "Installing bun..."
      npm i -g bun
      echo "Installing other global modules using bun..."
      bun i -g bun pnpm yarn serve
    '';
  };

  home.extraPaths = ["${bunHome}/bin" "${pnpmHome}" "${globalNodeModules}/bin"];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = globalNodeModules;
    PNPM_HOME = pnpmHome;
    BUN_INSTALL = bunHome;
  };
}
