{...}: {
  myNixOS = {
    qemu-guest.enable = false;
    gaming.enable = false;

    docker.enable = false;
    podman.enable = true;

    # There seems to be an issue with the virtualbox
    virtualbox.enable = false;
  };
}
