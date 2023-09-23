{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./entry.nix
    ./cli/darwin.nix
    ./desktop/darwin.nix
    ./exit.nix
  ];

  home.file = {
    ".config/karabiner/karabiner.json".source = config.lib.file.mkOutOfStoreSymlink ./darwin/karabiner.json;
  };

  # # Enable home-manager
  # programs.home-manager.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
