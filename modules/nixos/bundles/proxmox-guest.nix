{...}: {
  myNixOS = {
    qemu-guest.enable = true;
    gaming.enable = false;

    docker.enable = true;
    podman.enable = false;

    xserver-nvidia.enable = false;
  };
}
