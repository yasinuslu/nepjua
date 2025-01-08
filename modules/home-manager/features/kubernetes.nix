{ pkgs, ... }:
{
  home.packages = with pkgs; [
    k3d
    kind
  ];
}
