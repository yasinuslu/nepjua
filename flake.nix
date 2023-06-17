{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    nix-colors.url = "github:misterio77/nix-colors";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    home-manager,
    darwin,
    alejandra,
    self,
    nix-index-database,
    ...
  } @ inputs: {
    # formatter."x86_64-linux" = alejandra.defaultPackage."x86_64-linux";
    formatter."aarch64-darwin" = alejandra.defaultPackage."aarch64-darwin";
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    # nixosConfigurations = {
    #   kaori = nixpkgs.lib.nixosSystem {
    #     specialArgs = {inherit inputs;}; # Pass flake inputs to our config

    #     modules = [
    #       {
    #         environment.systemPackages = [
    #           alejandra.defaultPackage."x86_64-linux"
    #         ];
    #       }±±
    #       ./nixos/configuration.nix
    #       nix-index-database.nixosModules.nix-index
    #       {programs.nix-index-database.comma.enable = true;}
    #     ];
    #   };
    # };

    darwinConfigurations = {
      over-9000 = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          {
            environment.systemPackages = [
              alejandra.defaultPackage."aarch64-darwin"
            ];
          }
          ./darwin/over-9000.nix
          nix-index-database.nixosModules.nix-index
          {programs.nix-index-database.comma.enable = true;}
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nepjua = import ./home/darwin.nix;
              extraSpecialArgs = {inherit inputs;};
            };
          }
        ];
      };

      ryuko = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          {
            environment.systemPackages = [
              alejandra.defaultPackage."aarch64-darwin"
            ];
          }
          ./darwin/ryuko.nix
          nix-index-database.nixosModules.nix-index
          {programs.nix-index-database.comma.enable = true;}
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.musu = import ./home/musu-darwin.nix;
              extraSpecialArgs = {inherit inputs;};
            };
          }
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "nepjua@kaori" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs;}; # Pass flake inputs to our config
        # > Our main home-manager configuration file <
        modules = [
          ./home/nixos.nix
          nix-index-database.hmModules.nix-index
          {programs.nix-index-database.comma.enable = true;}
        ];
      };
    };
  };
}
