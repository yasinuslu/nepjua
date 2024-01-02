{inputs, ...}: {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    inputs.nix-colors.homeManagerModule
    ../../src/cli/packages.nix
    ../../src/cli/fish
    ../../src/cli/git
    ../../src/cli/fzf.nix
    ../../src/cli/tmux.nix
    ../../src/cli/node.nix
    ../../src/cli/deno.nix
  ];

  programs = {
    home-manager.enable = true;
    java.enable = true;
    gh.enable = false;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
