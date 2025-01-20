{
  config,
  lib,
  myLib,
  myArgs,
  ...
}:
let
  cfg = config.myHomeManager;

  extensions = map (f: import f { }) (myLib.filesIn ./extensions);

  enterModules = map (f: f.enter) extensions;
  exitModules = map (f: f.exit) extensions;

  # Taking all modules in ./bundles and adding enables to them
  bundles = myLib.wrapModules {
    available = true;
    prefix = "myHomeManager.bundles";
    files = myLib.filesIn ./bundles;
  };

  # Taking all modules in ./features-gui and adding enables to them
  features = myLib.wrapModules {
    available = true;
    prefix = "myHomeManager.features";
    files = myLib.filesIn ./features;
  };

  # Taking all modules in ./features-tui and adding enables to them
  featuresLinux = myLib.wrapModules {
    available = myArgs.isCurrentSystemLinux;
    prefix = "myHomeManager.linux";
    files = myLib.filesIn ./features-linux;
  };

  featuresDarwin = myLib.wrapModules {
    available = myArgs.isCurrentSystemDarwin;
    prefix = "myHomeManager.darwin";
    files = myLib.filesIn ./features-darwin;
  };
in
{
  home.stateVersion = "24.11";

  imports =
    enterModules ++ [ ] ++ bundles ++ features ++ featuresLinux ++ featuresDarwin ++ exitModules;
}
