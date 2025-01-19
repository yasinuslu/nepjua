{
  config,
  lib,
  myLib,
  inputs,
  ...
}:
let
  cfg = config.myDarwin;

  # Taking all modules in ./features and adding enables to them
  features = myLib.wrapModules {
    available = true;
    files = myLib.filesIn ./features;
    prefix = "myDarwin";
  };

  # Taking all module bundles in ./bundles and adding bundle.enables to them
  bundles = myLib.wrapModules {
    available = true;
    prefix = "myDarwin.bundles";
    files = myLib.filesIn ./bundles;
  };

  # Taking all module services in ./services and adding services.enables to them
  services = myLib.wrapModules {
    available = true;
    prefix = "myDarwin.services";
    files = myLib.filesIn ./services;
  };
in
{
  imports = [ inputs.home-manager.darwinModules.home-manager ] ++ features ++ bundles ++ services;

  config = {
    system.stateVersion = 4;

    nix.settings = {
      experimental-features = "nix-command flakes auto-allocate-uids";
      extra-experimental-features = "nix-command flakes auto-allocate-uids";
      accept-flake-config = true;
      auto-allocate-uids = true;
      extra-nix-path = "nixpkgs=flake:nixpkgs";
      bash-prompt-prefix = "(nix:$name)\040";
      build-users-group = "nixbld";
      extra-platforms = "aarch64-darwin x86_64-darwin";
      keep-outputs = true;
      keep-derivations = true;
    };

    # Add optimise configuration
    nix.optimise.automatic = true;

    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
  };
}
