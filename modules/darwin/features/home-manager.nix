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

              programs.zsh.initExtra = ''
                __init_homebrew() {
                  if [[ -e /opt/homebrew/bin/brew ]]; then
                    eval $(/opt/homebrew/bin/brew shellenv)
                  fi

                  if [[ -e /usr/local/bin/brew ]]; then
                    eval $(/usr/local/bin/brew shellenv)
                  fi
                }

                __init_homebrew
              '';

              programs.bash.initExtra = ''
                __init_homebrew() {
                  if [[ -e /opt/homebrew/bin/brew ]]; then
                    eval $(/opt/homebrew/bin/brew shellenv)
                  fi

                  if [[ -e /usr/local/bin/brew ]]; then
                    eval $(/usr/local/bin/brew shellenv)
                  fi
                }

                __init_homebrew
              '';

              programs.fish.shellInit = ''
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
