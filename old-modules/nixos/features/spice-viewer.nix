{ pkgs, ... }:
{
  # Required packages for SPICE viewer functionality
  environment.systemPackages = with pkgs; [
    spice
    spice-gtk
    spice-protocol
    virt-viewer
    virtio-win
  ];

  # Firewall configuration for SPICE viewer
  networking.firewall = {
    allowedTCPPorts = [
      3128
      5900
      5901
    ]; # SPICE proxy and standard VNC ports
    allowedUDPPorts = [
      3128
      5900
      5901
    ];
  };

  # Add users to spice group for access
  users.groups.spice = { };
}
