{
  config,
  lib,
  inputs,
  specialArgs,
  modulesPath,
  options,
  darwinConfig,
  osConfig,
}: {
  imports = [
    ../../src/extensions/extra-paths/__enter.nix
    ../../profiles/minimal

    # Actual darwin configuration
    ../../profiles/darwin/profiles-darwin.nix

    ../../src/extensions/extra-paths/__exit.nix
  ];
}
