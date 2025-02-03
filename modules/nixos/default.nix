{
  config,
  lib,
  inputs,
  myLib,
  ...
}:
let
  cfg = config.myNixOS;

  # Taking all modules in ./features and adding enables to them
  features = myLib.extendModules (name: {
    extraOptions = {
      myNixOS.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
    };

    extraConfig = {
      myNixOS.${name}.enable = lib.mkDefault true;
    };

    configExtension = config: (lib.mkIf cfg.${name}.enable config);
  }) (myLib.filesIn ./features);

  # Taking all module bundles in ./bundles and adding bundle.enables to them
  bundles = myLib.extendModules (name: {
    extraOptions = {
      myNixOS.bundles.${name}.enable = lib.mkEnableOption "enable ${name} module bundle";
    };

    extraConfig = {
      myNixOS.bundles.${name}.enable = lib.mkDefault false;
    };

    configExtension = config: (lib.mkIf cfg.bundles.${name}.enable config);
  }) (myLib.filesIn ./bundles);

  # Taking all module services in ./services and adding services.enables to them
  services = myLib.extendModules (name: {
    extraOptions = {
      myNixOS.services.${name}.enable = lib.mkEnableOption "enable ${name} service";
    };
    configExtension = config: (lib.mkIf cfg.services.${name}.enable config);
  }) (myLib.filesIn ./services);
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ] ++ features ++ bundles ++ services;

  config = {
    nix.settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes auto-allocate-uids";
      accept-flake-config = true;
      auto-allocate-uids = true;
    };

    nix.optimise = {
      automatic = true;
      dates = [ "03:45" ]; # Runs daily at 3:45 AM
    };

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.allowUnsupportedSystem = true;

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "24.11";
  };
}
