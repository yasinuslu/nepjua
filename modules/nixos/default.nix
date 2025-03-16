{ flake, lib, ... }:
{
  # imports =
  #   with builtins;
  #   map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));

  # options = flake.my.common.mkOption { inherit lib; };
  options = {
    my = {
      common = {
        defaultUser = lib.mkOption { type = lib.types.str; };
      };
    };
  };
}
