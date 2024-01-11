{
  inputs,
  pkgs,
  config,
  ...
}: {
  home.extraPaths = ["$HOME/.rd/bin"];
  xsession.enable = true;
}
