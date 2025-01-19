{
  lib,
  inputs,
  ...
}:
let
  inherit (lib) filesystem;

  # Recursively find all _mod.nix files in a given directory
  findModules =
    dir:
    let
      # Filter for _mod.nix files, excluding hidden directories
      modFiles = filesystem.listFilesRecursive dir;
      filteredMods = builtins.filter (
        path:
        lib.hasSuffix "/_mod.nix" path
        && !(lib.any (part: lib.hasPrefix "." part) (lib.splitString "/" path))
      ) modFiles;
    in
    builtins.listToAttrs (
      builtins.map (modPath: {
        # Convert file path to module path, removing base dir and _mod.nix
        name = lib.removePrefix (dir + "/") (lib.removeSuffix "/_mod.nix" modPath);
        value = import modPath;
      }) filteredMods
    );

  # Auto-discover modules with optional arguments
  autoDiscoverModules =
    {
      baseDir, # Base directory to start discovery
      moduleArgs ? { }, # Additional arguments to pass to modules
    }:
    findModules baseDir;

in
{
  inherit findModules autoDiscoverModules;
}
