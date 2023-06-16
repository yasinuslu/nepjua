{
  inputs,
  lib,
  config,
  pkgs,
  colors,
  ...
}: {
  imports = [
  ];

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };
}
