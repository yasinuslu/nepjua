# A simple hello module to test our module system
localFlake:
{
  config,
  my,
  ...
}:
{
  flake = {
    testingIfConfigIsSet = config.my.nixos.features.hello.enable;
    somethingElse = my.cfg;
  };
}
