{
  pkgs,
  lib,
  ...
}: let
  dag = lib.hm.dag;
  nodeBinDir = "${pkgs.nodejs}/bin";
  pnpmHome = "$HOME/.nix-mutable/pnpm";
  globalNodeModules = "$HOME/.nix-mutable/npm/node_modules";
in {
  home.packages = with pkgs; [
    nodejs
  ];

  home.activation = {
    mutableNodeModules = dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${globalNodeModules}
      mkdir -p ${pnpmHome}
      export PATH="${pnpmHome}:${nodeBinDir}:${globalNodeModules}/bin:$PATH"
      export PNPM_HOME="${pnpmHome}"
      npm config set prefix ${globalNodeModules}
      npm i -g pnpm
      pnpm i -g pnpm yarn serve
    '';
  };

  home.extraPaths = ["${pnpmHome}" "${globalNodeModules}/bin"];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = globalNodeModules;
    PNPM_HOME = pnpmHome;
  };
}
