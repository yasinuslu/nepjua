{ ... }:
{
  enter =
    { lib, ... }:
    {
      options.myHomeManager.paths = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "Extra paths to add to the PATH variable.";
      };
    };

  exit =
    {
      inputs,
      lib,
      config,
      ...
    }:
    {
      home.sessionVariables.PATH = lib.concatStringsSep ":" (config.myHomeManager.paths ++ [ "$PATH" ]);
    };
}
