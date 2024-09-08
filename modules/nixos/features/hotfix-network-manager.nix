{pkgs, ...}: {
  systemd.services.NetworkManager-wait-online.enable = true;
}
