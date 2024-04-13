{...}: {
  imports = [
    ./gui-programs
    ./cli-programs
    ./services
  ];

  config.nepjua.home-manager.cli-programs.enable = true;
}
