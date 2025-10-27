{ ... }:
{
  # Ghostty is installed via homebrew on macOS (see homebrew-minimal.nix)
  # We only manage the configuration here
  xdg.configFile."ghostty/config".text = ''
    # Theme
    theme = "Monokai Remastered"

    # Font
    font-family = "JetBrainsMono Nerd Font Mono"
    font-size = 15

    # Keybindings
    keybind = global:alt+§=toggle_quick_terminal
    keybind = global:alt+backquote=toggle_quick_terminal

    shell-integration = fish

    command = "/run/current-system/sw/bin/fish -l"

    quick-terminal-autohide = false
    quick-terminal-animation-duration = 0.15

    background-blur = true
    background-opacity = 0.7
  '';

  myHomeManager.paths = [
    "$GHOSTTY_BIN_DIR"
  ];
}
