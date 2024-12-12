{
  pkgs,
  lib,
  ...
}: {
  home.sessionVariables = {
    EDITOR = "cursor --wait";
    CODE_EDITOR = "cursor";
    REACT_EDITOR = "cursor";
  };

  programs.zsh.initExtraFirst = ''
    alias code="cursor"
    ${lib.optionalString pkgs.stdenv.isDarwin ''
      alias mscode="/opt/homebrew/bin/code"
    ''}
    ${lib.optionalString pkgs.stdenv.isLinux ''
      alias mscode="${pkgs.vscode}/bin/code"
    ''}
  '';

  programs.bash.profileExtra = ''
    alias code="cursor"
    ${lib.optionalString pkgs.stdenv.isDarwin ''
      alias mscode="/opt/homebrew/bin/code"
    ''}
    ${lib.optionalString pkgs.stdenv.isLinux ''
      alias mscode="${pkgs.vscode}/bin/code"
    ''}
  '';

  programs.fish.loginShellInit = ''
    alias code="cursor"
    ${lib.optionalString pkgs.stdenv.isDarwin ''
      alias mscode="/opt/homebrew/bin/code"
    ''}
    ${lib.optionalString pkgs.stdenv.isLinux ''
      alias mscode="${pkgs.vscode}/bin/code"
    ''}
  '';
}
