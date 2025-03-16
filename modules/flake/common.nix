{
  flake.my.common = {
    mkOption =
      { lib, ... }:
      {
        enable = lib.mkEnableOption "common";
        defaultUser = lib.mkOption {
          type = lib.types.str;
          default = "nepjua";
        };
      };
  };
}
