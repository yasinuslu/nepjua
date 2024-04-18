{lib, ...}: {
  myNixOS.base-system.enable = lib.mkDefault true;
  myNixOS.xserver-nvidia.enable = lib.mkDefault true;
  myNixOS.gnome.enable = lib.mkDefault true;
}
