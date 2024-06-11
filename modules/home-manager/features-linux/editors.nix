{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    # package = pkgs.vscode-fhs;
  };

  home.packages = with pkgs; [
    zed-editor
  ];

  home.sessionVariables = {
    EDITOR = "${pkgs.vscode-fhs}/bin/code";
  };
}
