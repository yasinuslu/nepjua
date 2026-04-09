{ pkgs, ... }:
{
  # Zed is installed outside Nix (e.g. Homebrew on macOS). See `features/editor.nix` for the `e` / `zed --wait` setup.
  home.packages =
    with pkgs;
    [
      vscode
    ]
    ++ (if pkgs.stdenv.system == "x86_64-linux" then [ code-cursor ] else [ ]);
}
