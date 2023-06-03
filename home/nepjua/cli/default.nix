{ inputs, lib, config, pkgs, colors, ... }: {
  imports = [
    ./fish
    ./git
    ./fzf.nix
  ];

  home.packages = with pkgs; [
    nil
    nixpkgs-fmt

    wget
    tldr
    parsec-bin
    jq
    lsd
    bat
    starship
    tmux
    vim
    nodejs
    yarn
    nodePackages.pnpm
    python3Minimal
    direnv
  ];
}
