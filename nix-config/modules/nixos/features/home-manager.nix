{
  lib,
  config,
  inputs,
  outputs,
  myLib,
  pkgs,
  ...
}: {
  options.myNixOS.users = lib.mkOption {
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

    nix.settings.trusted-users = ["root"] ++ (builtins.attrNames config.myNixOS.users);

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
            user.userConfig
            ({...}: {
              home.username = name;
              home.homeDirectory = "/home/${name}";
            })
            (outputs.homeManagerModules.default {
              inherit inputs;
              inherit myLib;
              system = pkgs.system;
              isLinux = myLib.isLinuxSystem pkgs.system;
            })
          ];
        })
        (config.myNixOS.users);
    };

    users.users = builtins.mapAttrs (
      name: user:
        {
          isNormalUser = true;
          initialPassword = "123456";
          description = "";
          shell = pkgs.fish;
          extraGroups = ["libvirtd" "networkmanager" "wheel" "docker"];
        }
        // user.userSettings
    ) (config.myNixOS.users);
  };
}
