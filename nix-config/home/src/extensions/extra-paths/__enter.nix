{lib, ...}: {
  options.home.extraPaths = lib.mkOption {
    type = with lib.types; listOf str;
    default = [];
    description = "Extra paths to add to the PATH variable.";
  };
}
