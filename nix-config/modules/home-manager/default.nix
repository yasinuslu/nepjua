{
  config,
  lib,
  myLib,
  pkgs,
  ...
}: let
  cfg = config.myHomeManager;

  isLinux = myLib.isLinuxSystem "aarch64-darwin";

  extensions =
    map
    (f: import f {})
    (myLib.filesIn ./extensions);

  enterModules = map (f: f.enter) extensions;
  exitModules = map (f: f.exit) extensions;

  # Taking all modules in ./features-gui and adding enables to them
  features =
    myLib.extendModules
    (name: {
      extraOptions = {
        myHomeManager.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
      };

      extraConfig = {
        myHomeManager.${name}.enable = lib.mkDefault true;
      };

      configExtension = config: (lib.mkIf (cfg.${name}.enable) config);
    })
    (myLib.filesIn ./features);

  # Taking all modules in ./features-tui and adding enables to them
  featuresLinux =
    myLib.extendModules
    (name: {
      extraOptions = {
        myHomeManager.linux.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
      };

      configExtension = config: (lib.mkIf (cfg.linux.${name}.enable) config);
    })
    (myLib.filesIn ./features-linux);

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
    ++ (
      if isLinux
      then featuresLinux
      else []
    )
    ++ exitModules;
}
