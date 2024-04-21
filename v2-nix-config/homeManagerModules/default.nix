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

  # Taking all modules in ./features and adding enables to them
  features =
    myLib.extendModules
    (name: {
      extraOptions = {
        myHomeManager.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
      };

      configExtension = config: (lib.mkIf cfg.${name}.enable config);
    })
    (myLib.filesIn ./features);

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
    enterModules
    ++ []
    ++ features
    ++ bundles
    ++ exitModules;
}
