{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./apps/alt-tab.nix
    ./apps/homebrew.nix
    ./gui-apps.nix
    ./keyboard.nix
  ];

  services.spotifyd.enable = true;

  programs.bash.interactiveShellInit = ''
    . /etc/profiles/per-user/nepjua/etc/profile.d/*
  '';

  programs.zsh.interactiveShellInit = ''
    . /etc/profiles/per-user/nepjua/etc/profile.d/*
  '';

  users.users.nepjua.home = "/Users/nepjua";
  users.users.nepjua.shell = pkgs.fish;

  networking.hostName = "raiden";
  networking.computerName = "raiden";
}
