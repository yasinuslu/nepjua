{ pkgs, ... }:
let
  name = "zoom-us";
  appimage = pkgs.fetchurl {
    url = "https://github.com/probonopd/Zoom.AppImage/releases/download/stable/Zoom_Workplace-6.3.5.6065.glibc2.27-x86_64.AppImage";
    sha256 = "0ldf175zdg444nc0imssiylg2x5rkwn34rsxg68cgfm0sm0h758x";
  };

  # Create a wrapper script for manual execution
  zoom-usBin = pkgs.writeShellScriptBin "zoom-us" ''
    exec ${pkgs.appimage-run}/bin/appimage-run ${appimage} "$@"
  '';

  # Create desktop entry
  desktopItem = pkgs.makeDesktopItem {
    name = "${name}";
    exec = "${zoom-usBin}/bin/zoom-us %U";
    icon = "zoom-us";
    desktopName = "Zoom";
    genericName = "Video Conferencing";
    categories = [
      "Network"
      "VideoConference"
      "InstantMessaging"
    ];
    mimeTypes = [
      "x-scheme-handler/zoommtg"
      "x-scheme-handler/zoomus"
      "x-scheme-handler/tel"
      "x-scheme-handler/callto"
      "x-scheme-handler/zoomphonecall"
      "application/x-zoom"
    ];
  };
in
{
  # Add to system packages
  environment.systemPackages = [
    desktopItem
    zoom-usBin
  ];

  # Add XDG autostart entry
  environment.pathsToLink = [ "/etc/xdg/autostart" ];
  environment.etc."xdg/autostart/zoom-us.desktop".source =
    "${desktopItem}/share/applications/${name}.desktop";
}
