{
  inputs,
  lib,
  config,
  pkgs,
  colors,
  ...
}: {
  home.packages = with pkgs; [
    flat-remix-icon-theme
    flat-remix-gtk
    flat-remix-gnome
  ];
}
