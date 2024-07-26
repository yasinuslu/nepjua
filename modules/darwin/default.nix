{
  config,
  lib,
  myLib,
  inputs,
  ...
}: let
  cfg = config.myDarwin;

  # Taking all modules in ./features and adding enables to them
  features =
    myLib.extendModules
    (name: {
      extraOptions = {
        myDarwin.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
      };

      extraConfig = {
        myDarwin.${name}.enable = lib.mkDefault true;
      };

      configExtension = config: (lib.mkIf cfg.${name}.enable config);
    })
    (myLib.filesIn ./features);

  # Taking all module bundles in ./bundles and adding bundle.enables to them
  bundles =
    myLib.extendModules
    (name: {
      extraOptions = {
        myDarwin.bundles.${name}.enable = lib.mkEnableOption "enable ${name} module bundle";
      };

      configExtension = config: (lib.mkIf cfg.bundles.${name}.enable config);
    })
    (myLib.filesIn ./bundles);

  # Taking all module services in ./services and adding services.enables to them
  services =
    myLib.extendModules
    (name: {
      extraOptions = {
        myDarwin.services.${name}.enable = lib.mkEnableOption "enable ${name} service";
      };
      configExtension = config: (lib.mkIf cfg.services.${name}.enable config);
    })
    (myLib.filesIn ./services);
in {
  imports =
    [inputs.home-manager.darwinModules.home-manager]
    ++ features
    ++ bundles
    ++ services;

  config = {
    system.stateVersion = 4;

    nix.settings = {
      experimental-features = "nix-command flakes auto-allocate-uids";
      extra-experimental-features = "nix-command flakes auto-allocate-uids";
      accept-flake-config = true;
      auto-optimise-store = true;
      auto-allocate-uids = true;
      extra-nix-path = "nixpkgs=flake:nixpkgs";
      bash-prompt-prefix = "(nix:$name)\040";
      build-users-group = "nixbld";
      extra-platforms = "aarch64-darwin x86_64-darwin";
      keep-outputs = true;
      keep-derivations = true;
    };

    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
  };
}
