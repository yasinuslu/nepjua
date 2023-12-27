# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];

  environment.sessionVariables = {
    DOCKER_HOST = "unix:///mnt/wsl/rancher-desktop/run";
  };
}
