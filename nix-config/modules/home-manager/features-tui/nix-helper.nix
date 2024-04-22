{pkgs, ...}: {
  home.packages = with pkgs; [
    nh
  ];

  home.sessionVariables = {
    FLAKE = "$HOME/code/nepjua/nix-config";
  };
}
