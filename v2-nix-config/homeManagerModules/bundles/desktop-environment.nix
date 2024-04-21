{
  lib,
  pkgs,
  ...
}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium-fhs;
  };

  home.packages = with pkgs; [
    zed
  ];

  home.sessionVariables = {
    EDITOR = "zed";
  };
}
