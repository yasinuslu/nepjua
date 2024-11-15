{...}: {
  # Use NetworkManager
  networking.networkmanager.enable = true;

  # Use Networkd
  # networking.useNetworkd = true;
  # networking.useDHCP = true;

  # Common network settings
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  # NetworkManager settings
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.networkmanager.wifi.powersave = false;

  # networkd settings
}
