{
  lib,
  pkgs,
  ...
}: {
  programs.vscode = {
    enable = true;
    pkg = pkgs.vscodium-fhs;
  };

  home.packages = with pkgs; [
    zed
  ];

  home.sessionVariables = {
    EDITOR = "zed";
  };
}
