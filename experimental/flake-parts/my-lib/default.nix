{
  lib,
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

          # Recursive traversal
          processEntry =
            name: type:
            if type == "directory" && !(lib.hasPrefix "." name) then
              findModFiles (dir + "/${name}")
            else if type == "regular" && lib.hasSuffix ".nix" name then
              [ (dir + "/${name}") ]
            else
              [ ];

          # Collect module files
          modFiles = lib.flatten (lib.mapAttrsToList processEntry contents);
        in
        modFiles;

      # Collect all module files
      moduleFiles = findModFiles baseDir;

      # Transform module files into an attribute set
      moduleAttrs = builtins.listToAttrs (
        builtins.map (modPath: {
          # Create module name from path
          name = lib.strings.removePrefix "${toString baseDir}/" (
            lib.strings.removeSuffix ".nix" (toString modPath)
          );
          # Import module with arguments
          value = moduleArgs.importApply modPath moduleArgs;
        }) moduleFiles
      );

      # Optional debug logging
      _ = lib.warn (
        if builtins.length moduleFiles == 0 then
          "No .nix modules discovered in ${toString baseDir}"
        else
          "Discovered ${toString (builtins.length moduleFiles)} .nix modules"
      );
    in
    moduleAttrs;

in
{
  # Expose the discovery function
  inherit discoverModules;
}
