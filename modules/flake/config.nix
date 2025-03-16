{ lib, ... }:
let
  userSubmodule = lib.types.submodule {
    options = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "Your username as shown by `id -un`";
      };
      githubUsername = lib.mkOption {
        type = lib.types.str;
        description = "Your GitHub username";
      };
      fullname = lib.mkOption {
        type = lib.types.str;
        description = "Your full name for use in Git config";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Your email for use in Git config";
      };
    };
  };
in
{
  options = {
    me = lib.mkOption {
      default = { };
      type = userSubmodule;
    };
  };

  config = {
    me = {
      username = "nepjua";
      githubUsername = "yasinuslu";
      fullname = "Yasin Uslu";
      email = "nepjua@gmail.com";
    };
  };
}
