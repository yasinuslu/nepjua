{
  pkgs,
  inputs,
  ...
}: {
  programs.bash.shellAliases = {
    docker = "podman";
    "docker-compose" = "podman-compose";
  };

  programs.zsh.shellAliases = {
    docker = "podman";
    "docker-compose" = "podman-compose";
  };

  programs.fish.shellAliases = {
    docker = "podman";
    "docker-compose" = "podman-compose";
  };
}
