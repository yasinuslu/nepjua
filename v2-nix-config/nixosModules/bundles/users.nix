{
  lib,
  config,
  inputs,
  outputs,
  myLib,
  pkgs,
  ...
}: let
  cfg = config.myNixOS;
in {
  options.myNixOS.home-users = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
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
          default = {};
          example = "{}";
        };
      };
    });

    default = {};
  };

  config = {
    programs.fish.enable = true;
    programs.java.enable = true;

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {
        inherit inputs;
        inherit myLib;
        outputs = inputs.self.outputs;
      };

      users =
        builtins.mapAttrs (name: user: {...}: {
          imports = [
            outputs.homeManagerModules.default
          ] ++ lib.mkIf user.userConfig [
            (import user.userConfig)
          ];
        })
        (config.myNixOS.home-users);
    };

    users.users = builtins.mapAttrs (
      name: user:
        {
          isNormalUser = true;
          initialPassword = "123456";
          description = "";
          shell = pkgs.zsh;
          extraGroups = ["libvirtd" "networkmanager" "wheel" "docker"];
        }
        // user.userSettings
    ) (config.myNixOS.home-users);
  };
}
