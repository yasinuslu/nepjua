{ pkgs, ... }:
{
  home.packages = with pkgs; [
    microsandbox
  ];
}
