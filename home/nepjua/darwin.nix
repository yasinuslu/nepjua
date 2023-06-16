{inputs, pkgs, ...}: {
  # You can import other home-manager modules here
  imports = [
    # You can also split up your configuration and import pieces of it here:
    ./common.nix
    ./cli
    ./desktop/darwin.nix
    # ./desktop
    # ./development
  ];

  home.packages = with pkgs; [
    rectangle
  ];

  programs.vscode = {
    enable = true;
  };

  # # Enable home-manager
  # programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
