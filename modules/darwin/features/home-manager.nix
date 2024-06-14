{
  lib,
  config,
  inputs,
  outputs,
  myLib,
  pkgs,
  myArgs,
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

    nix.settings.trusted-users = ["root"] ++ (builtins.attrNames config.myNixOS.users);
    nix.settings.trusted-substituters = [
      "https://nix-community.cachix.org/"
      "https://cache.nixos.org/"
      "https://devenv.cachix.org/"
      "https://nixpkgs-update.cachix.org/"
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "before-my-home-manager";

      extraSpecialArgs = {
        inherit inputs;
        inherit myLib;
        inherit myArgs;
        outputs = inputs.self.outputs;
      };

      users =
        builtins.mapAttrs (name: user: {...}: {
          imports = [
            user.userConfig
            ({...}: {
              home.username = name;
              home.homeDirectory = "/Users/${name}";
            })
            outputs.homeManagerModules.default
          ];
        })
        (config.myNixOS.users);
    };

    users.users = builtins.mapAttrs (
      name: user:
        {
          home = "/Users/${name}";
          shell = pkgs.fish;
        }
        // user.userSettings
    ) (config.myNixOS.users);
  };
}
