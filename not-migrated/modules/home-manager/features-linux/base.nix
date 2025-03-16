{ pkgs, ... }:
{
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    with pkgs;
    [
      coreutils-full
      iputils
      htop
      tailscale
      telepresence2
      lazygit
      git-sync
    ];
}
