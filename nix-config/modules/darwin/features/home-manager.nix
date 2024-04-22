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

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "before-my-home-manager";

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
              home.homeDirectory = "/Users/${name}";

              # programs.bash.interactiveShellInit = ''
              #   eval "$(/opt/homebrew/bin/brew shellenv)"
              #   . /etc/profiles/per-user/${name}/etc/profile.d/*
              # '';

              # programs.zsh.interactiveShellInit = ''
              #   eval "$(/opt/homebrew/bin/brew shellenv)"
              #   . /etc/profiles/per-user/${name}/etc/profile.d/*
              # '';

              programs.fish.interactiveShellInit = ''
                eval "$(/opt/homebrew/bin/brew shellenv)"
              '';
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
          home = "/Users/${name}";
          shell = pkgs.fish;
        }
        // user.userSettings
    ) (config.myNixOS.users);
  };
}
