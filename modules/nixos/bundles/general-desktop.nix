{...}: {
  myNixOS = {
    qemu-guest.enable = false;
    spice-guest.enable = false;
    gaming.enable = false;
    podman.enable = false;
  };
}
