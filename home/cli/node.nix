{
  pkgs,
  lib,
  ...
}: let
  dag = lib.hm.dag;
  nodeBinDir = "${pkgs.nodejs}/bin";
  nodeHome = "$HOME/.npm";
  pnpmHome = "$HOME/.nix-mutable/pnpm";
  bunHome = "$HOME/.bun";
  globalNodeModules = "$HOME/.nix-mutable/npm/node_modules";
in {
  home.packages = with pkgs; [
    nodejs
    bun
  ];

  home.activation = {
    mutableNodeModules = dag.entryAfter ["writeBoundary"] ''
      echo "Cleaning up existing global node_modules..."
      rm -rf ${nodeHome}
      rm -rf ${globalNodeModules}
      mkdir -p ${globalNodeModules}
      mkdir -p ${pnpmHome}
      export PATH="${pnpmHome}:${nodeBinDir}:${globalNodeModules}/bin:$PATH"
      export PNPM_HOME="${pnpmHome}"
      npm config set prefix ${globalNodeModules}
      echo "Installing pnpm..."
      npm i -g pnpm
      echo "Installing other global modules using pnpm..."
      pnpm i -g pnpm yarn serve
      npm remove -g pnpm
    '';
  };

  home.extraPaths = ["${pnpmHome}" "${globalNodeModules}/bin" "${bunHome}/bin"];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = globalNodeModules;
    PNPM_HOME = pnpmHome;
  };
}
