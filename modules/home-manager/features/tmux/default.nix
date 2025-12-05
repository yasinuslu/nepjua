{ pkgs, ... }:

let
  oh-my-tmux = pkgs.callPackage ./package.nix { };

  # User's custom tmux configuration
  extraLocalConfig = ''
    # -- Custom user configuration -------------------------------------------------
    set-option -g default-shell ${pkgs.fish}/bin/fish
    set-option -g default-command "exec ${pkgs.fish}/bin/fish"

    # Update environment variables from shell when creating new sessions/windows
    # This ensures tmux picks up environment variables that change in the shell
    set-option -g update-environment "PATH DISPLAY SSH_AUTH_SOCK SSH_CONNECTION SSH_CLIENT TERM TERM_PROGRAM TERM_PROGRAM_VERSION NODE_OPTIONS"

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
    tmux_conf_new_window_retain_current_path=disabled

    # Unbind the default 'c' binding (which creates a new window)
    unbind c

    # Rebind 'c' so new windows start in the same working directory as the current pane
    bind c new-window -c "#{pane_current_path}"

    bind -r C-u swap-window -t -1 \; select-window -t -1  # swap current window with the previous one
    bind -r C-i swap-window -t +1 \; select-window -t +1  # swap current window with the next one
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
