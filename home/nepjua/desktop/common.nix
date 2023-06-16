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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Applications
    copyq
    qbittorrent
    vlc
    discord
    slack
    obsidian
    zoom-us
    spotify
    obs-studio
    bottles
  ];

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };
}
