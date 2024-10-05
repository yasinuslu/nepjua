{...}: {
  myNixOS = {
    qemu-guest.enable = false;
    gaming.enable = false;

    docker.enable = true;
    podman.enable = false;

    # There seems to be an issue with the virtualbox
    virtualbox.enable = false;
  };
}
