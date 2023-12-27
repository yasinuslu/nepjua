{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  environment.shellAliases = {
    docker = "podman";
    "docker-compose" = "podman-compose";
  };
}
