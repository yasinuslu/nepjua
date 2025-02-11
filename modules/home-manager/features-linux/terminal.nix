{ ... }:
{
  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
  };

  environment.sessionVariables = {
    TERMINAL = "kitty";
  };
}
