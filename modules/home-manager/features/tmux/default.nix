{ pkgs, ... }:

let
  oh-my-tmux = pkgs.callPackage ./package.nix { };

  # User's custom tmux configuration
  extraLocalConfig = ''
    # -- Custom user configuration -------------------------------------------------
    set option -g default-shell ${pkgs.fish}/bin/fish

    # Add custom prefix (C-g) in addition to default
    set -g prefix2 C-s
    bind C-s send-prefix -2

    # Ensure vi mode is enabled
    setw -g mode-keys vi

    # New window/pane opens in current directory
    bind-key c new-window -c "#{pane_current_path}"
    bind-key '"' split-window -c "#{pane_current_path}"
    bind-key % split-window -h -c "#{pane_current_path}"

    # Window swapping with Ctrl+[ and Ctrl+]
    bind-key -r C-'[' swap-window -t -1\; previous-window
    bind-key -r C-']' swap-window -t +1\; next-window
  '';
in
{
  home.packages = with pkgs; [
    tmux
  ];

  # Place oh-my-tmux configuration files in ~/.config/tmux/
  xdg.configFile."tmux/tmux.conf".source = "${oh-my-tmux}/tmux.conf";

  # Use oh-my-tmux's example local config as base, append our customizations
  xdg.configFile."tmux/tmux.conf.local".text =
    builtins.readFile "${oh-my-tmux}/tmux.conf.local" + "\n\n" + extraLocalConfig;
}
