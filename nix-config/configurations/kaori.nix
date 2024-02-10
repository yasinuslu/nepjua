{ inputs }:
let
  inherit
    (inputs)
    nixpkgs
    alejandra
    nix-index-database
    home-manager
    ;
in
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; }; # Pass flake inputs to our config

  modules = [
    {
      environment.systemPackages = [
        alejandra.defaultPackage."x86_64-linux"
      ];
    }
    ../machines/linux/configuration.nix
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
        users.nepjua = import ../home/profiles/nixos-linux-desktop;
        extraSpecialArgs = { inherit inputs; };
      };
    }
  ];
}
