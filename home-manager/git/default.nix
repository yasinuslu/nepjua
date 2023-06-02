{ inputs, lib, config, pkgs, colors, ... }: {
  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
  };
}
