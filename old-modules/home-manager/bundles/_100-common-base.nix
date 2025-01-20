{ lib, ... }:
{
  myHomeManager = {
    bash.enable = lib.mkOverride 100 true;
    bat.enable = lib.mkOverride 100 true;
    common-base.enable = lib.mkOverride 100 true;
    deno.enable = lib.mkOverride 100 true;
    devenv.enable = lib.mkOverride 100 true;
    editor.enable = lib.mkOverride 100 true;
    fish.enable = lib.mkOverride 100 true;
    fonts.enable = lib.mkOverride 100 true;
    git.enable = lib.mkOverride 100 true;
    impure-node.enable = lib.mkOverride 100 true;
    kubernetes.enable = lib.mkOverride 100 true;
    lima.enable = lib.mkOverride 100 true;
    nix-helper.enable = lib.mkOverride 100 true;
    nixfmt.enable = lib.mkOverride 100 true;
    nushell.enable = lib.mkOverride 100 true;
    starship.enable = lib.mkOverride 100 true;
    tmux.enable = lib.mkOverride 100 true;
    zsh.enable = lib.mkOverride 100 true;
  };
}
