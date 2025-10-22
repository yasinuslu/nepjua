{ ... }:
{
  # Ghostty is installed via homebrew on macOS (see homebrew-minimal.nix)
  # We only manage the configuration here
  xdg.configFile."ghostty/config".text = ''
    # Font
    font-size = 14

    # Keybindings
    keybind = global:alt+backquote=toggle_quick_terminal
  '';
}
