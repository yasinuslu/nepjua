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

              # programs.bash.interactiveShellInit = ''
              #   eval "$(/opt/homebrew/bin/brew shellenv)"
              #   . /etc/profiles/per-user/${name}/etc/profile.d/*
              # '';

              # programs.zsh.interactiveShellInit = ''
              #   eval "$(/opt/homebrew/bin/brew shellenv)"
              #   . /etc/profiles/per-user/${name}/etc/profile.d/*
              # '';

              programs.fish.interactiveShellInit = ''
                function __init_homebrew
                  if test -e /opt/homebrew/bin/brew
                    eval (/opt/homebrew/bin/brew shellenv)
                  end

                  if test -e /usr/local/bin/brew
                    eval (/usr/local/bin/brew shellenv)
                  end
                end

                __init_homebrew
              '';
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
