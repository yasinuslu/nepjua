{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    fzf
    fd
  ];

  programs.mcfly = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    fzf = {
      enable = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow";
    fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --follow";
  };
}
