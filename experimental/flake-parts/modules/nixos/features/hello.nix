# A simple hello module to test our module system
localFlake:
{
  config,
  ...
}:
{
  flake = {
    testingIfConfigIsSet = config.my.nixos.features.hello.enable;
  };
}
