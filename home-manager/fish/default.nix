
{ inputs, lib, config, pkgs, colors, ... }: {
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

    fileWidgetCommand = ''
      fd --type f --strip-cwd-prefix --hidden --follow --exclude .git
    '';
  };
}
