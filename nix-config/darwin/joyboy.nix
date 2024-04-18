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
    ./apps/homebrew-extra.nix
    ./gui-apps.nix
    ./keyboard.nix
  ];

  programs.bash.interactiveShellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    . /etc/profiles/per-user/nepjua/etc/profile.d/*
  '';

  programs.zsh.interactiveShellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    . /etc/profiles/per-user/nepjua/etc/profile.d/*
  '';

  programs.fish.interactiveShellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  users.users.nepjua.home = "/Users/nepjua";
  users.users.nepjua.shell = pkgs.fish;

  networking.hostName = "joyboy";
  networking.computerName = "Joi Boi";
}
