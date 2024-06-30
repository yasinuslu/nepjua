{pkgs, ...}: {
  home.packages = with pkgs; [
    docker
    docker-compose
    docker-buildx
  ];
}
