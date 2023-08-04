{
  pkgs,
  lib,
  ...
}: let
  dag = lib.hm.dag;
  npm = "${pkgs.nodejs}/bin/npm";
in {
  home.packages = with pkgs; [
    nodejs
  ];

  home.activation = {
    mutableNodeModules = dag.entryAfter ["writeBoundary"] ''
      ${npm} config set prefix $HOME/.mutable_node_modules
      ${npm} i -g yarn pnpm
    '';
  };

  home.extraPaths = ["$HOME/.mutable_node_modules/bin"];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.mutable_node_modules";
  };
}
