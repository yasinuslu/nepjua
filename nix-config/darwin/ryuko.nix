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

  users.users.musu.home = "/Users/musu";
  users.users.musu.shell = pkgs.fish;

  networking.hostName = "ryuko";
  networking.computerName = "Musu's Mac";
}
