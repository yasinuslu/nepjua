{
  inputs,
  pkgs,
  config,
  ...
}: {
  home.extraPaths = [];

  programs.bash.interactiveShellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    . /etc/profiles/per-user/${home.username}/etc/profile.d/*
  '';

  programs.zsh.interactiveShellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
    . /etc/profiles/per-user/${home.username}/etc/profile.d/*
  '';

  programs.fish.interactiveShellInit = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
