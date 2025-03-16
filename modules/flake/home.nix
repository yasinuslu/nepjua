{ root, ... }:
let
  defaultHomeModules = root + /modules/home;
in
{
  flake.my.home = {
    mkOption =
      { lib, pkgs, ... }:
      {
        my.home = {
          enable = lib.mkEnableOption "home";
          users = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule {
                options = {
                  extraConfig = lib.mkOption {
                    default = null;
                    example = "";
                  };

                  extraSettings = lib.mkOption {
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
                user.extraConfig
                defaultHomeModules
                {
                  my.home.username = lib.mkDefault name;
                  my.home.shell = lib.mkDefault user.shell;
                }
              ];
            }
          ) cfg.users;
        };

        users.users = builtins.mapAttrs (
          name: user:
          {
            isNormalUser = lib.mkDefault true;
            home = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${name}";
            shell = lib.mkDefault user.shell;
          }
          // user.extraSettings
        ) cfg.users;

        nix.settings.trusted-users = [ "root" ] ++ (builtins.attrNames cfg.users);
      };
  };
}
