{pkgs, ...}: {
  imports = [
    ./fish
    ./git
    ./fzf.nix
    ./tmux.nix
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
    vim
    nodejs
    yarn
    nodePackages.pnpm
    python3Minimal
    direnv
  ];
}
