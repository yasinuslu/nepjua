{
  inputs,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    ./common.nix
    ./cli/darwin.nix
    ./desktop/darwin.nix
  ];

  # # Enable home-manager
  # programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}