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
      topModuleArgs ? { }, # Arguments to pass to each module
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
      # modules = builtins.listToAttrs (
      #   map (file: {
      #     name = pathToModulePath file.path;
      #     value =
      #       let
      #         originalModule = topModuleArgs.flake-parts-lib.importApply file.path topModuleArgs;
      #         wrapper =
      #           moduleArgs:
      #           let
      #             _debugThing = builtins.trace (toString moduleArgs) null;
      #             extraArgs = {
      #               cfgPath = file.path;
      #             };
      #             originalModuleResult = originalModule (moduleArgs // extraArgs);
      #             configOrTopLevel =
      #               if builtins.isAttrs originalModuleResult.config then
      #                 originalModuleResult.config
      #               else
      #                 originalModuleResult;
      #             options = originalModuleResult.options or { };
      #             imports = configOrTopLevel.imports or [ ];
      #             flake = configOrTopLevel.flake or { };
      #             perSystem = configOrTopLevel.perSystem or null;
      #             perInput = configOrTopLevel.perInput or null;
      #           in
      #           {
      #             options = options // {
      #               myFlake."${file.path}".enable = lib.mkEnableOption "Enable ${file.path}";
      #             };
      #             config = configOrTopLevel // {
      #               inherit
      #                 imports
      #                 flake
      #                 perSystem
      #                 perInput
      #                 ;
      #             };
      #           };
      #       in
      #       wrapper;
      #   }) moduleFiles
      # );

      modules = builtins.listToAttrs (
        map (file: {
          name = pathToModulePath file.path;
          value =
            let
              originalModule = topModuleArgs.flake-parts-lib.importApply file.path topModuleArgs;
              originalModuleImport = builtins.head originalModule.imports;
              stringPath = toString file.path;
              # Convert path to a safe string identifier
              safeId = builtins.replaceStrings [ "/" ] [ "--" ] stringPath;
            in
            {
              _file = originalModule._file;
              imports = [
                (
                  { ... }:
                  {
                    options = {
                      myFlake.${safeId}.enable = lib.mkEnableOption "Enable ${stringPath}";
                    };
                  }
                )
                (
                  { ... }:
                  {
                    myFlake.${safeId}.enable = lib.mkDefault false;
                  }
                )
                (
                  { config, ... }:
                  {
                    imports = if config.myFlake.${safeId}.enable then [ originalModuleImport ] else [ ];
                  }
                )
              ];
            };
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
