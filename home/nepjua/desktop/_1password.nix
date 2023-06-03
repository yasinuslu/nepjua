{
  inputs,
  lib,
  config,
  pkgs,
  colors,
  ...
}: {
  home.file = {
    ".config/autostart/1password.desktop".source = with pkgs; "${_1password-gui.outPath}/share/applications/1password.desktop";
  };
}
