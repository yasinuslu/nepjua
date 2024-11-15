{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    # package = pkgs.vscode-fhs;
  };

  home.packages = with pkgs; [
    zed-editor
    code-cursor
  ];

  home.sessionVariables = {
    EDITOR = "${pkgs.vscode}/bin/code";
  };
}
