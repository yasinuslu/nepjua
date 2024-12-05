{...}: {
  home.sessionVariables = {
    EDITOR = "cursor --wait";
    CODE_EDITOR = "cursor";
    REACT_EDITOR = "cursor";
  };

  programs.zsh.initExtraFirst = ''
    alias code="cursor"
    alias mscode="/opt/homebrew/bin/code"
  '';

  programs.bash.profileExtra = ''
    alias code="cursor"
    alias mscode="/opt/homebrew/bin/code"
  '';

  programs.fish.loginShellInit = ''
    alias code="cursor"
    alias mscode="/opt/homebrew/bin/code"
  '';
}
