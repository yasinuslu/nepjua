{
  config,
  lib,
  myLib,
  ...
}: let
  cfg = config.myHomeManager;

  extensions =
    map
    (f: import f {})
    (myLib.filesIn ./extensions);

  enterModules = map (f: f.enter) extensions;
  exitModules = map (f: f.exit) extensions;

  # Taking all modules in ./tui-features and adding enables to them
  tuiFeatures =
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
    (myLib.filesIn ./tui-features);

  # Taking all modules in ./tui-features and adding enables to them
  guiFeatures =
    myLib.extendModules
    (name: {
      extraOptions = {
        myHomeManager.gui.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
      };

      extraConfig = {
        myHomeManager.gui.${name}.enable = lib.mkDefault true;
      };

      configExtension = config: (lib.mkIf (cfg.gui.enable && cfg.gui.${name}.enable) config);
    })
    (myLib.filesIn ./gui-features);

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

            gui = {
              enable = lib.mkEnableOption "enable my gui configuration";
            };
          };
        };

        config = {
          myHomeManager = {
            tui = {
              enable = lib.mkDefault true;
            };

            gui = {
              enable = lib.mkDefault true;
            };
          };
        };
      })
    ]
    ++ enterModules
    ++ []
    ++ tuiFeatures
    ++ guiFeatures
    ++ bundles
    ++ exitModules;
}
