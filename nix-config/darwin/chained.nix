{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./common.nix
    ./apps/alt-tab.nix
    ./apps/homebrew-minimal.nix
    ./gui-apps.nix
    ./keyboard.nix
  ];

  programs.bash.interactiveShellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    . /etc/profiles/per-user/yahmet/etc/profile.d/*
  '';

  programs.zsh.interactiveShellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    . /etc/profiles/per-user/yahmet/etc/profile.d/*
  '';

  programs.fish.interactiveShellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  users.users.yahmet.home = "/Users/yahmet";
  users.users.yahmet.shell = pkgs.fish;

  networking.hostName = "chained";
  networking.computerName = "Yasin MC";
}
