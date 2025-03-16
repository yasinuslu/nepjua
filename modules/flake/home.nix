{
  flake.my.home = {
    mkOption =
      { lib, pkgs, ... }:
      {
        enable = lib.mkEnableOption "home";
        users = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                userName = lib.mkOption {
                  default = "nepjua";
                  description = ''
                    username
                  '';
                };

                userConfig = lib.mkOption {
                  default = null;
                  example = "";
                };

                userSettings = lib.mkOption {
                  default = { };
                  example = "{}";
                };

                shell = lib.mkOption {
                  default = pkgs.fish;
                  example = "pkgs.zsh";
                };
              };
            }
          );

          default = { };
        };
      };

    mkConfig =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      let
        cfg = config.my.home;
      in
      lib.mkIf cfg.enable {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "before-my-home-manager";

          users = builtins.mapAttrs (
            name: user:
            { ... }:
            {
              imports = [
                user.userConfig
                (
                  { ... }:
                  {
                    home.username = name;
                    home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${name}";
                    home.stateVersion = "24.11";
                  }
                )
              ];
            }
          ) cfg.users;
        };

        nix.settings.trusted-users = [ "root" ] ++ (builtins.attrNames cfg.users);
      };
  };
}
