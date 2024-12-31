{...}: {
  myNixOS = {
    qemu-guest.enable = false;
    gaming.enable = false;

    docker.enable = true;
    podman.enable = false;

    xserver-nvidia.enable = true;
    xserver-virtio.enable = false;
  };
}
