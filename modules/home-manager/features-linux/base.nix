{ pkgs, ... }:
{
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    coreutils-full
    iputils
    htop
    cloudflared
    telepresence2
    nixpkgs-review
    lazygit
    git-sync
  ];

}
