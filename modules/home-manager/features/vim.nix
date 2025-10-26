{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.khanelivim.packages.${pkgs.system}.default
  ];

  home.shellAliases = {
    vim = "nvim";
  };
}
