{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";

  myNixOS.base-os.enable = lib.mkDefault true;
  myNixOS.xserver-nvidia.enable = lib.mkDefault true;
  myNixOS.gnome.enable = lib.mkDefault true;
}
