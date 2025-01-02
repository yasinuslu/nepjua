{...}: {
  myNixOS = {
    gaming.enable = false;
    podman.enable = false;
    xserver-nvidia.enable = false;
  };
}
