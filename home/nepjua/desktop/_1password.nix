{
  inputs,
  lib,
  config,
  pkgs,
  colors,
  ...
}: {
  home.file = {
    ".config/autostart/1password.desktop".source = "${pkgs._1password-gui.outPath}/share/applications/1password.desktop";
    ".config/autostart/copyq.desktop".source = "${pkgs.copyq.outPath}/share/applications/com.github.hluk.copyq.desktop";
    ".config/autostart/guake.desktop".source = "${pkgs.guake.outPath}/share/applications/guake.desktop";
  };
}
