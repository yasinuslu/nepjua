{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [
    podman-compose
  ];

  # environment.shellAliases = {
  #   docker = "podman";
  #   "docker-compose" = "podman-compose";
  # };
}
