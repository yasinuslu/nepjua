{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my.home;
in
{
  options = {
    my.home = {
      enable = lib.mkOption {
        default = true;
        example = true;
        description = "Whether to enable home.";
        type = lib.types.bool;
      };

      username = lib.mkOption {
        type = lib.types.str;
        default = "nepjua";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.username = cfg.username;
    home.homeDirectory = lib.mkDefault "/${
      if pkgs.stdenv.isDarwin then "Users" else "home"
    }/${cfg.username}";
    home.stateVersion = "24.11";
  };
}
