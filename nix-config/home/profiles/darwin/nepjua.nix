{
  config,
  lib,
  inputs,
  specialArgs,
  modulesPath,
  options,
  darwinConfig,
  osConfig,
}: {
  imports = [
    ../../src/extensions/extra-paths/__enter.nix
    ../../profiles/minimal

    # Actual darwin configuration
    ../../profiles/darwin/profiles-darwin.nix

    ../../src/extensions/extra-paths/__exit.nix
  ];

  programs.bash.initExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    . /etc/profiles/per-user/nepjua/etc/profile.d/*
  '';

  programs.zsh.initExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    . /etc/profiles/per-user/nepjua/etc/profile.d/*
  '';

  programs.fish.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
