{inputs}: let
  inherit
    (inputs)
    nixpkgs
    alejandra
    vscode-server
    nix-index-database
    home-manager
    ;
in
  nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = {inherit inputs;}; # Pass flake inputs to our config

    modules = [
      ../utils
      {
        environment.systemPackages = [
          alejandra.defaultPackage."aarch64-linux"
        ];
      }
      ../machines/hetzner/configuration.nix
      nix-index-database.nixosModules.nix-index
      {
        programs.nix-index-database.comma.enable = true;
        programs.nix-index.enable = true;
        programs.command-not-found.enable = false;
      }
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.nepjua = import ../home/profiles/nixos-cloud;
          extraSpecialArgs = {inherit inputs;};
        };
      }
      vscode-server.nixosModules.default
      ({
        config,
        pkgs,
        ...
      }: {
        services.vscode-server.enable = true;
      })
    ];
  }
