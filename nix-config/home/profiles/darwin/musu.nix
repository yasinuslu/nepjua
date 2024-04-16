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
  programs.bash.initExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv bash)"
    . /etc/profiles/per-user/musu/etc/profile.d/*
  '';

  programs.zsh.enable = true;
  programs.zsh.initExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv zsh)"
    . /etc/profiles/per-user/musu/etc/profile.d/*
  '';

  programs.fish.shellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv fish)"
  '';
}
