{pkgs, ...}: {
  home.packages = with pkgs; [
    code-cursor
    vscode
    zed-editor
  ];
}
