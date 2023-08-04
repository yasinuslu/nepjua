{
  inputs,
  lib,
  config,
  ...
}: {
  home.sessionVariables.PATH = lib.concatStringsSep ":" (
    config.home.extraPaths ++ ["$PATH"]
  );
}
