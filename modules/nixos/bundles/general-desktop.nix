{...}: {
  myNixOS = {
    qemu-guest.enable = false;
    spice-guest.enable = false;
    spice-viewer.enable = true;
    gaming.enable = false;

    docker.enable = true;
    podman.enable = false;

    xserver-nvidia.enable = true;
  };
}
