{lib, ...}: {
  config.myHomeManager.minimal-home.enable = lib.mkDefault true;
  config.myHomeManager.fish.enable = lib.mkDefault true;
  config.myHomeManager.fzf.enable = lib.mkDefault true;
  config.myHomeManager.tmux.enable = lib.mkDefault true;
}
