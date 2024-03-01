{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    fzf
    fd
  ];

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    defaultCommand = ''
      fd --type f --strip-cwd-prefix --hidden --follow --exclude .git
    '';

    fileWidgetCommand = ''
      fd --type f --strip-cwd-prefix --hidden --follow --exclude .git
    '';
  };
}
