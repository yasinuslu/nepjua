{
  lib,
  inputs,
  ...
}:
let
  # Core module discovery function
  discoverModules =
    {
      baseDir, # Root directory to search
      moduleArgs ? { }, # Arguments to pass to each module
    }:
    let
      # Recursively find .nix files
      findModFiles =
        dir:
        let
          # Read directory contents safely
          contents = if builtins.pathExists dir then builtins.readDir dir else { };

          # Process each item in the directory
          processItem =
            name: type:
            let
              path = dir + "/${name}";
            in
            if type == "regular" && lib.hasSuffix ".nix" name then
              [
                {
                  inherit path;
                  name = lib.removeSuffix ".nix" name;
                }
              ]
            else if type == "directory" then
              findModFiles path
            else
              [ ];

          # Map over directory contents
          results = lib.mapAttrsToList processItem contents;
        in
        builtins.concatLists results;

      # Convert file paths to module paths
      pathToModulePath =
        path:
        let
          # Remove baseDir prefix and .nix suffix
          relative = lib.removePrefix (toString baseDir + "/") (toString path);
          withoutNix = lib.removeSuffix ".nix" relative;
        in
        withoutNix;

      # Find all module files
      moduleFiles = findModFiles baseDir;

      # Create the final modules
      modules = builtins.listToAttrs (
        map (file: {
          name = pathToModulePath file.path;
          value = moduleArgs.flake-parts-lib.importApply file.path;
        }) moduleFiles
      );

      # Optional debug logging
      _ = lib.warn (
        if builtins.length moduleFiles == 0 then
          "No .nix modules discovered in ${toString baseDir}"
        else
          "Discovered ${toString (builtins.length moduleFiles)} .nix modules"
      ) null;
    in
    modules;
in
{
  inherit discoverModules;
}
