{inputs, ...}: {
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    inputs.nix-colors.homeManagerModule
    ./cli/fish
    ./cli/git
    ./cli/fzf.nix
    ./cli/tmux.nix
    ./cli/node.nix
    ./cli/deno.nix
  ];

  config = {
    programs = {
      java.enable = true;
      gh.enable = false;
      direnv.enable = true;
      direnv.nix-direnv.enable = true;
    };
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
