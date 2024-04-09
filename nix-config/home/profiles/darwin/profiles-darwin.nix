{
  inputs,
  pkgs,
  config,
  ...
}: let
  brew = "sudo -Hu nixrunner brew";
in {
  home.extraPaths = [];

  programs.bash.initExtra = ''
    eval "$(${brew} shellenv)"
    . /etc/profiles/per-user/nepjua/etc/profile.d/*
  '';

  programs.zsh.initExtra = ''
    eval "$(${brew} shellenv)"
    . /etc/profiles/per-user/nepjua/etc/profile.d/*
  '';

  programs.fish.shellInit = ''
    eval "$(${brew} shellenv)"
  '';

  programs.fish.shellAbbrs = {
    "brew" = "${brew}";
    "nix" = "sudo -Hu nixrunner nix";
    "nix-env" = "sudo -Hu nixrunner nix-env";
    "nix-shell" = "sudo -Hu nixrunner nix-shell";
    "nix-collect-garbage" = "sudo -Hu nixrunner nix-collect-garbage";
    "nix-store" = "sudo -Hu nixrunner nix-store";
    "nix-build" = "sudo -Hu nixrunner nix-build";
    "nix-instantiate" = "sudo -Hu nixrunner nix-instantiate";
    "nix-prefetch-url" = "sudo -Hu nixrunner nix-prefetch-url";
    "nix-channel" = "sudo -Hu nixrunner nix-channel";
    "darwin-rebuild" = "sudo -Hu nixrunner darwin-rebuild";
  };
}
