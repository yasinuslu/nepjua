{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      vscode
      # zed-editor
    ]
    ++ (if pkgs.stdenv.system == "x86_64-linux" then [ code-cursor ] else [ ]);
}
