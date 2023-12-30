{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../src/__enter.nix
    ./profiles-darwin.nix
    ../../src/cli/__enter.nix
    ../../src/cli/__exit.nix
    ../../src/__exit.nix
  ];
}
