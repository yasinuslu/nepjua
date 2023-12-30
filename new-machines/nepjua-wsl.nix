{
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
}
