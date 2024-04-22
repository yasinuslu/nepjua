{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  cfg = config.myHomeManager;

  isLinux = myLib.isDarwinSystem pkgs.system;

  extensions =
    map
    (f: import f {})
    (myLib.filesIn ./extensions);

  enterModules = map (f: f.enter) extensions;
  exitModules = map (f: f.exit) extensions;

  # Taking all modules in ./features-gui and adding enables to them
  featuresTui =
    myLib.extendModules
    (name: {
      extraOptions = {
        myHomeManager.tui.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
      };

      extraConfig = {
        myHomeManager.tui.${name}.enable = lib.mkDefault true;
      };

      configExtension = config: (lib.mkIf (cfg.tui.enable && cfg.tui.${name}.enable) config);
    })
    (myLib.filesIn ./features);

  # Taking all modules in ./features-tui and adding enables to them
  featuresLinux = lib.mkIf isLinux (myLib.extendModules
    (name: {
      extraOptions = {
        myHomeManager.linux.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
      };

      extraConfig = {
        myHomeManager.linux.${name}.enable = lib.mkDefault true;
      };

      configExtension = config: (lib.mkIf (cfg.linux.enable && cfg.linux.${name}.enable) config);
    })
    (myLib.filesIn ./features-linux));

  # Taking all module bundles in ./bundles and adding bundle.enables to them
  bundles =
    myLib.extendModules
    (name: {
      extraOptions = {
        myHomeManager.bundles.${name}.enable = lib.mkEnableOption "enable ${name} module bundle";
      };

      configExtension = config: (lib.mkIf cfg.bundles.${name}.enable config);
    })
    (myLib.filesIn ./bundles);
in {
  home.stateVersion = "24.05";

  imports =
    [
      ({...}: {
        options = {
          myHomeManager = {
            tui = {
              enable = lib.mkEnableOption "enable my tui configuration";
            };

            linux = lib.mkIf isLinux {
              enable = lib.mkEnableOption "enable my gui configuration";
            };
          };
        };

        config = {
          myHomeManager = {
            tui = {
              enable = lib.mkOptionDefault false;
            };

            linux = lib.mkIf isLinux {
              enable = lib.mkOptionDefault false;
            };
          };
        };
      })
    ]
    ++ enterModules
    ++ []
    ++ featuresTui
    ++ (lib.mkIf isLinux featuresLinux)
    ++ bundles
    ++ exitModules;
}
