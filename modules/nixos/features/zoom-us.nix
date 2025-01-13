{ pkgs, lib, ... }:
let
  name = "zoom-us";
  version = "6.3.5.6065";

  appimage = pkgs.fetchurl {
    url = "https://github.com/probonopd/Zoom.AppImage/releases/download/stable/Zoom_Workplace-${version}.glibc2.27-x86_64.AppImage";
    sha256 = "0ldf175zdg444nc0imssiylg2x5rkwn34rsxg68cgfm0sm0h758x";
    executable = true;
  };

  # Extract icon from AppImage
  icon = pkgs.runCommand "zoom-us-icon" { } ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    ${pkgs.appimage-run}/bin/appimage-run "${appimage}" --appimage-extract usr/share/icons/hicolor/256x256/apps/Zoom.png
    cp squashfs-root/usr/share/icons/hicolor/256x256/apps/Zoom.png \
      $out/share/icons/hicolor/256x256/apps/zoom-us.png
  '';

  # Create wrapper script
  zoom-usBin = pkgs.writeShellScriptBin "zoom-us" ''
    exec ${pkgs.appimage-run}/bin/appimage-run "${appimage}" "$@"
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
  environment.systemPackages = [
    icon
    desktopItem
    zoom-usBin
  ];

  # Add XDG autostart entry
  environment.pathsToLink = [ "/etc/xdg/autostart" ];
  environment.etc."xdg/autostart/zoom-us.desktop".source =
    "${desktopItem}/share/applications/${name}.desktop";
}
