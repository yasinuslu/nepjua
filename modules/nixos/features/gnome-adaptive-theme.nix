{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Enable geoclue for location services
  services.geoclue2.enable = true;

  # Install required packages
  environment.systemPackages = with pkgs; [
    gnome.gnome-shell
    geoclue2
    (pkgs.writeShellScriptBin "gnome-adaptive-theme" ''
      #!/usr/bin/env bash

      # Get current location
      location=$(${pkgs.geoclue2}/libexec/geoclue-2.0/demos/where-am-i)

      # Extract latitude and longitude
      latitude=$(echo "$location" | grep Latitude | awk '{print $2}')
      longitude=$(echo "$location" | grep Longitude | awk '{print $2}')

      # Calculate sunrise and sunset times
      sunrise=$(${pkgs.python3}/bin/python3 -c "import datetime, ephem; o = ephem.Observer(); o.lat = '$latitude'; o.lon = '$longitude'; sunrise = o.next_rising(ephem.Sun()).datetime(); print(sunrise.strftime('%H:%M'))")
      sunset=$(${pkgs.python3}/bin/python3 -c "import datetime, ephem; o = ephem.Observer(); o.lat = '$latitude'; o.lon = '$longitude'; sunset = o.next_setting(ephem.Sun()).datetime(); print(sunset.strftime('%H:%M'))")

      # Get current time
      current_time=$(date +%H:%M)

      # Determine theme based on time
      if [[ "$current_time" > "$sunrise" && "$current_time" < "$sunset" ]]; then
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'default'"
      else
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      fi
    '')
  ];

  # Set up a systemd timer to run the theme switching script periodically
  systemd.user.services.gnome-adaptive-theme = {
    description = "Adaptive GNOME Theme Based on Sun Position";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.gnome-adaptive-theme}/bin/gnome-adaptive-theme";
    };
  };

  systemd.user.timers.gnome-adaptive-theme = {
    description = "Timer for Adaptive GNOME Theme";
    timerConfig = {
      OnCalendar = "*:0/15"; # Run every 15 minutes
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}
