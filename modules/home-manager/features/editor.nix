{
  pkgs,
  lib,
  ...
}:
{
  home.sessionVariables = {
    EDITOR = "code --wait";
    CODE_EDITOR = "code";
    REACT_EDITOR = "code";
  };

  programs.zsh.initExtraFirst = ''
    # alias code="cursor"
    ${lib.optionalString pkgs.stdenv.isDarwin ''
      alias mscode="/opt/homebrew/bin/code"
    ''}
    ${lib.optionalString pkgs.stdenv.isLinux ''
      alias mscode="${pkgs.vscode}/bin/code"
    ''}
  '';

  programs.bash.profileExtra = ''
    # alias code="cursor"
    ${lib.optionalString pkgs.stdenv.isDarwin ''
      alias mscode="/opt/homebrew/bin/code"
    ''}
    ${lib.optionalString pkgs.stdenv.isLinux ''
      alias mscode="${pkgs.vscode}/bin/code"
    ''}
  '';

  programs.fish.loginShellInit = ''
    # alias code="cursor"
    ${lib.optionalString pkgs.stdenv.isDarwin ''
      alias mscode="/opt/homebrew/bin/code"
    ''}
    ${lib.optionalString pkgs.stdenv.isLinux ''
      alias mscode="${pkgs.vscode}/bin/code"
    ''}
  '';
}
