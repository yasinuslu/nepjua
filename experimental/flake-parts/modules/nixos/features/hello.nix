# A simple hello module to test our module system
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    message = lib.mkOption {
      type = lib.types.str;
      default = "Hello, World!";
      description = "The message to display";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.hello;
      description = "The hello package to use";
    };
  };

  config = {
    environment.systemPackages = [ config.myFlake.nixos.features.hello.package ];
  };
}
