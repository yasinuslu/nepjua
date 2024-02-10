{
  inputs,
  pkgs,
  config,
  ...
}: {
  home.extraPaths = ["$HOME/.rd/bin"];

  home.file = {
    ".config/karabiner/karabiner.json".source = config.lib.file.mkOutOfStoreSymlink ./karabiner.json;
  };
}
