{
  config,
  lib,
  myLib,
  myArgs,
  ...
}: let
  cfg = config.myHomeManager;

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

      extraConfig = {
        myHomeManager.linux.${name}.enable = lib.mkDefault true;
      };

      configExtension = config: (lib.mkIf (cfg.linux.${name}.enable) config);
    })
    (myLib.filesIn ./features-linux);

  featuresDarwin =
    myLib.extendModules
    (name: {
      extraOptions = {
        myHomeManager.darwin.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
      };

      extraConfig = {
        myHomeManager.darwin.${name}.enable = lib.mkDefault true;
      };

      configExtension = config: (lib.mkIf (cfg.darwin.${name}.enable) config);
    })
    (myLib.filesIn ./features-darwin);
in {
  home.stateVersion = "24.05";

  imports =
    enterModules
    ++ []
    ++ features
    ++ (
      if myArgs.isCurrentSystemLinux
      then featuresLinux
      else []
    )
    ++ (
      if myArgs.isCurrentSystemDarwin
      then featuresDarwin
      else []
    )
    ++ exitModules;
}
