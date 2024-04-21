{
  lib,
  config,
  inputs,
  outputs,
  myLib,
  pkgs,
  ...
}: {
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
            user.userConfig
            ({...}: {
              config.home.username = name;
              config.home.homeDirectory =
                if (myLib.isDarwinSystem pkgs.system)
                then "/Users/${name}"
                else "/home/${name}";
            })
            outputs.homeManagerModules.default
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
          shell = pkgs.fish;
          extraGroups = ["libvirtd" "networkmanager" "wheel" "docker"];
        }
        // user.userSettings
    ) (config.myNixOS.home-users);
  };
}
