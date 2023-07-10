{pkgs, ...}: {
  imports = [
    ./common.nix
  ];

  home.sessionVariables = {
    PATH = "$PATH:$HOME/.rd/bin";
  };
}
