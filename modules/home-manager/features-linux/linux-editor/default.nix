{
  pkgs,
  stdenv,
  ...
}: {
  home.packages = with pkgs;
    [
      vscode
      zed-editor
    ]
    ++ (
      if stdenv.system == "x86_64-linux"
      then [code-cursor]
      else []
    );
}
