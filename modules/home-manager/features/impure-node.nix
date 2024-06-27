{
  pkgs,
  lib,
  ...
}: let
  dag = lib.hm.dag;
  nodeBinDir = "${pkgs.nodejs}/bin";
  npmHome = "$HOME/.npm";
  pnpmHome = "$HOME/.nix-mutable/pnpm";
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
      rm -rf "${globalNodeModules}"
      mkdir -p "${globalNodeModules}"
      mkdir -p "${pnpmHome}"
      echo "Done"
      export PATH="${pnpmHome}:${nodeBinDir}:${globalNodeModules}/bin:$PATH"
      export PNPM_HOME="${pnpmHome}"
      npm config set prefix ${globalNodeModules}
      npm uninstall -g pnpm yarn
      npm i -g corepack
      echo "Installing other global modules using pnpm..."
      corepack install -g pnpm@8 yarn
      pnpm i -g serve
    '';
  };

  myHomeManager.paths = ["${pnpmHome}" "${globalNodeModules}/bin"];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = globalNodeModules;
    PNPM_HOME = pnpmHome;
    # PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  };
}
