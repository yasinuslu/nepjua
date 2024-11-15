{...}: {
  home.sessionVariables = {
    EDITOR = "code --wait";
    CODE_EDITOR = "code";
  };

  programs.zsh.initExtraFirst = ''
    alias code="cursor"
  '';

  programs.bash.profileExtra = ''
    alias code="cursor"
  '';

  programs.fish.loginShellInit = ''
    alias code="cursor"
  '';
}
