{inputs, ...}: {
  imports = [
    ../../src/extensions/extra-paths/__enter.nix
    ../../profiles/minimal

    # Actual darwin configuration
    ../../profiles/nixos-wsl/profiles-nixos-wsl.nix

    ../../src/extensions/extra-paths/__exit.nix
  ];

  home = {
    username = "nepjua";
    homeDirectory = "/home/nepjua";
  };
}
