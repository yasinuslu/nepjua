{
  flake.my.common = {
    mkOption =
      { lib, ... }:
      {
        my.common = {
          enable = lib.mkEnableOption "common";
          defaultUser = lib.mkOption {
            type = lib.types.str;
            default = "nepjua";
          };
        };
      };
  };
}
