{
  inputs,
  flake,
}: let
  inherit
    (inputs)
    nixpkgs
    alejandra
    nixos-wsl
    nix-index-database
    home-manager
    ;
in
  nixpkgs.lib.nixosSystem rec {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      inherit flake system;
    };

    modules = [
      ../utils
      {
        environment.systemPackages = [
          alejandra.defaultPackage.${system}
        ];
      }
      {
        environment.systemPackages = with inputs.nix-alien.packages.${system}; [
          nix-alien
        ];
        # Optional, needed for `nix-alien-ld`
        programs.nix-ld.enable = true;
      }
      ./src/nix-ld-libraries.nix
      nixos-wsl.nixosModules.wsl
      ./src/wsl/base.nix
      ./src/wsl/rancher.nix
      ./src/wsl/desktop-gui.nix
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
          users.nepjua = import ../home/profiles/nixos-wsl;
          extraSpecialArgs = {inherit inputs;};
        };
      }
    ];
  }
