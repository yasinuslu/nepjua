{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tmux
  ];

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g prefix2 C-g
      bind C-g send-prefix -2
      setw -g mode-keys vi
      bind-key c new-window -c "#{pane_current_path}"
      bind-key '"' split-window -c "#{pane_current_path}"
      bind-key % split-window -h -c "#{pane_current_path}"
      bind-key -r C-'[' swap-window -t -1\; previous-window
      bind-key -r C-']' swap-window -t +1\; next-window
    '';
    shortcut = "s";
  };
}
