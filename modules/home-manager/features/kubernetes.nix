{ pkgs, ... }:
{
  home.packages = with pkgs; [
    k3d
    kind
    kubectl
    kubectx
    k9s
  ];
}
