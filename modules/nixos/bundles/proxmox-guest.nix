{...}: {
  myNixOS = {
    qemu-guest.enable = true;
    gaming.enable = false;

    docker.enable = true;
    podman.enable = false;

    # There seems to be an issue with the virtualbox
    virtualbox.enable = false;

    xserver-nvidia.enable = false;
    xserver-virtio.enable = true;
  };
}
