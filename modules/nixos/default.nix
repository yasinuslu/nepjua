{
  inputs,
  myLib,
  ...
}:
let
  # Taking all modules in ./features and adding enables to them
  features = myLib.wrapModules {
    available = true;
    prefix = "myNixOS";
    files = myLib.filesIn ./features;
  };

  # Taking all module bundles in ./bundles and adding bundle.enables to them
  bundles = myLib.wrapModules {
    available = true;
    prefix = "myNixOS.bundles";
    files = myLib.filesIn ./bundles;
  };

  # Taking all module services in ./services and adding services.enables to them
  services = myLib.wrapModules {
    available = true;
    prefix = "myNixOS.services";
    files = myLib.filesIn ./services;
  };
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
