{...}: {
  # Use either NetworkManager or Networkd
  networking.networkmanager.enable = false;
  networking.useNetworkd = true;

  # Common network settings
  networking.useDHCP = true;
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
