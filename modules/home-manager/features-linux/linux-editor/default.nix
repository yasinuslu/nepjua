{pkgs, ...}: {
  home.packages = with pkgs; [
    (
      if pkgs.stdenv.system == "x86_64"
      then code-cursor
      else []
    )
    vscode
    zed-editor
  ];
}
