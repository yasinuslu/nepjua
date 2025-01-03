{pkgs, ...}: let
  version = "1.3.6";
  name = "rustdesk";
  appimage = pkgs.fetchurl {
    url = "https://github.com/rustdesk/rustdesk/releases/download/${version}/rustdesk-${version}-x86_64.AppImage";
    sha256 = "1zc4dsx4m54qqv8n98dva0fvnfs8qj9wamv6brnxch952gr1vl88";
  };

  # Create a wrapper script that ensures proper environment
  startScript = pkgs.writeShellScriptBin "rustdesk-start" ''
    # Wait for DISPLAY and other X11 essentials
    sleep 2

    # Start RustDesk in the background
    ${pkgs.appimage-run}/bin/appimage-run ${appimage} --silent &
    RUSTDESK_PID=$!

    # Small delay to ensure process is fully started
    sleep 1

    # Store the PID for systemd
    echo $RUSTDESK_PID > $XDG_RUNTIME_DIR/rustdesk.pid
  '';

  # Create a wrapper script for manual execution
  rustdeskBin = pkgs.writeShellScriptBin "rustdesk" ''
    exec ${pkgs.appimage-run}/bin/appimage-run ${appimage} "$@"
  '';
in {
  # Create a wrapped AppImage with proper environment
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "${name}";
      exec = "${pkgs.appimage-run}/bin/appimage-run ${appimage}";
      icon = "rustdesk"; # Default icon name
      desktopName = "RustDesk";
      genericName = "Remote Desktop";
      categories = ["Network" "RemoteAccess"];
    })
    startScript
    rustdeskBin # Add the wrapper script to system packages
  ];

  # Configure systemd user service
  systemd.user.services.rustdesk = {
    description = "RustDesk Remote Desktop";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];

    serviceConfig = {
      Type = "forking";
      Environment = [
        "PATH=${pkgs.xdg-utils}/bin:${pkgs.dbus}/bin:$PATH"
        "XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"
      ];
      ExecStart = "${startScript}/bin/rustdesk-start";
      ExecStop = "${pkgs.coreutils}/bin/kill -TERM $MAINPID";
      PIDFile = "%t/rustdesk.pid";
      Restart = "on-failure";
      RestartSec = "3";
    };

    # Ensure proper environment for the GUI application
    environment = {
      DISPLAY = ":0";
      WAYLAND_DISPLAY = "wayland-0";
    };

    # Start after all required services
    after = [
      "graphical-session-pre.target"
      "xdg-desktop-autostart.target"
      "dbus.socket"
    ];
    wants = ["dbus.socket"];
  };
}
