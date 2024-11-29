{...}: {
  home.sessionVariables = {
    EDITOR = "cursor --wait";
    CODE_EDITOR = "cursor";
    REACT_EDITOR = "cursor";
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
