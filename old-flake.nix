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

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    nixos-wsl.url = "https://github.com/nix-community/NixOS-WSL/archive/refs/heads/main.tar.gz";

    nix-ld.url = "github:Mic92/nix-ld";
    # this line assume that you also have nixpkgs as an input
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    nix-alien.url = "github:thiagokokada/nix-alien";
  };

  outputs = {
    nixpkgs,
    home-manager,
    darwin,
    alejandra,
    self,
    nix-index-database,
    vscode-server,
    nixos-wsl,
    nix-ld,
    ...
  } @ inputs: {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      kaori = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;}; # Pass flake inputs to our config

        modules = [
          {
            environment.systemPackages = [
              alejandra.defaultPackage."x86_64-linux"
            ];
          }
          ./machines/linux/configuration.nix
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
              users.nepjua = import ./home/profiles/nixos.nix;
              extraSpecialArgs = {inherit inputs;};
            };
          }
        ];
      };

      hetzner = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs;}; # Pass flake inputs to our config

        modules = [
          {
            environment.systemPackages = [
              alejandra.defaultPackage."aarch64-linux"
            ];
          }
          ./machines/hetzner/configuration.nix
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
              users.nepjua = import ./home/profiles/nixos-cloud.nix;
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
      };

      wsl = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          inherit self system;
        }; # Pass flake inputs to our config

        modules = [
          {
            environment.systemPackages = [
              alejandra.defaultPackage."x86_64-linux"
            ];
          }
          nixos-wsl.nixosModules.wsl
          {
            environment.systemPackages = with self.inputs.nix-alien.packages.${system}; [
              nix-alien
            ];
            # Optional, needed for `nix-alien-ld`
            programs.nix-ld.enable = true;
          }
          ./machines/wsl/configuration.nix
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
              users.nepjua = import ./home/profiles/nixos-wsl.nix;
              extraSpecialArgs = {inherit inputs;};
            };
          }
        ];
      };
    };

    darwinConfigurations = {
      raiden = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          {
            environment.systemPackages = [
              alejandra.defaultPackage."aarch64-darwin"
            ];
          }
          ./darwin/raiden.nix
          nix-index-database.nixosModules.nix-index
          {programs.nix-index-database.comma.enable = true;}
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nepjua = import ./home/profiles/darwin.nix;
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
              users.musu = import ./home/profiles/musu-darwin.nix;
              extraSpecialArgs = {inherit inputs;};
            };
          }
        ];
      };
    };
  };
}
