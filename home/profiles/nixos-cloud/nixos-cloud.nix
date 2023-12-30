{inputs, ...}: {
  imports = [
    ../../src/extensions/extra-paths/__enter.nix
    ../../profiles/minimal

    # Actual darwin configuration
    ../../profiles/darwin/profiles-darwin.nix

    ../../src/extensions/extra-paths/__exit.nix
  ];

  home = {
    username = "nepjua";
    homeDirectory = "/home/nepjua";
  };

  programs.vscode = {
    enable = true;
  };
}
