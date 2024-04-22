{pkgs, ...}: {
  home.packages = with pkgs; [
    nh
  ];

  home.sessionVariables = {
    FLAKE = "$HOME/nepjua/nix-config";
  };
}
