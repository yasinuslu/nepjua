{ pkgs, ... }:
{
  programs.ghostty = {
    enable = true;
    theme = "catppuccin-mocha";
    font-size = 14;
    settings = {
      keybind = [
        "global:alt+backquote=toggle_quick_terminal"
      ];
    };
  };
}
