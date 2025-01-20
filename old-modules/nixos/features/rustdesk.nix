{ pkgs, ... }:
let
  version = "1.3.6";
  name = "rustdesk";
  appimage = pkgs.fetchurl {
    url = "https://github.com/rustdesk/rustdesk/releases/download/${version}/rustdesk-${version}-x86_64.AppImage";
    sha256 = "1zc4dsx4m54qqv8n98dva0fvnfs8qj9wamv6brnxch952gr1vl88";
  };

  # Create a wrapper script for manual execution
  rustdeskBin = pkgs.writeShellScriptBin "rustdesk" ''
    exec ${pkgs.appimage-run}/bin/appimage-run ${appimage} "$@"
  '';

  # Create desktop entry
  desktopItem = pkgs.makeDesktopItem {
    name = "${name}";
    exec = "${pkgs.appimage-run}/bin/appimage-run ${appimage}";
    icon = "rustdesk";
    desktopName = "RustDesk";
    genericName = "Remote Desktop";
    categories = [
      "Network"
      "RemoteAccess"
    ];
    startupNotify = true;
    terminal = false;
  };
in
{
  # Add to system packages
  environment.systemPackages = [
    desktopItem
    rustdeskBin
  ];

  # Add XDG autostart entry
  environment.pathsToLink = [ "/etc/xdg/autostart" ];
  environment.etc."xdg/autostart/rustdesk.desktop".source =
    "${desktopItem}/share/applications/${name}.desktop";
}
