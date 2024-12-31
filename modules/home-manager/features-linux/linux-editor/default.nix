{
  pkgs,
  system,
  ...
}: {
  home.packages = with pkgs;
    [
      vscode
      zed-editor
    ]
    ++ (
      if system == "x86_64-linux"
      then [code-cursor]
      else []
    );
}
