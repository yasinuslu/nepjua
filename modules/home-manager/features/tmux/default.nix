{ pkgs, ... }:

let
  oh-my-tmux = pkgs.callPackage ./package.nix { };

  # User's custom tmux configuration
  extraLocalConfig = ''
    # -- Custom user configuration -------------------------------------------------
    set-option -g default-shell ${pkgs.fish}/bin/fish

    # Add custom prefix (C-g) in addition to default
    set -g prefix2 C-s
    bind C-s send-prefix -2

    # Ensure vi mode is enabled
    setw -g mode-keys vi

    # Enable mouse mode by default
    set -g mouse on

    # Window swapping with Ctrl+[ and Ctrl+]
    bind -r C-'[' swap-window -t -1\; previous-window
    bind -r C-']' swap-window -t +1\; next-window

    # We disable this because tmux does not pick up existing environment variables in the shell when it is enabled
    tmux_conf_new_session_retain_current_path=disabled

    # -- windows & pane creation ---------------------------------------------------

    # new window retains current path, possible values are:
    #   - true
    #   - false (default)
    #   - disabled (do not modify new-window bindings)
    tmux_conf_new_window_retain_current_path=true
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
