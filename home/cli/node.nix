{pkgs, ...}: {

  home.packages = with pkgs; [
    nodejs
    yarn
    nodePackages.pnpm
  ];

  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;
}
