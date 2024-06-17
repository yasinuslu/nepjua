{pkgs, ...}: {
  home.packages = with pkgs; [
    colima
    docker
    docker-compose
  ];
}
