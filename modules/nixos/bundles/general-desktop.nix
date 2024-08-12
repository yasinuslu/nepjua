{...}: {
  myNixOS = {
    qemu-guest.enable = false;
    gaming.enable = false;

    docker.enable = false;
    podman.enable = true;
  };
}
