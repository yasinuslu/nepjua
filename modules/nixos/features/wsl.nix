{ inputs, config, ... }: {
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];

  wsl = {
    enable = true;
    defaultUser = config.myNixOS.mainUser;
    interop = {
      register = true;
    };
    docker-desktop = {
      enable = true;
    };
  };
}
