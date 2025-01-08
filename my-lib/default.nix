{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
  darwin = inputs.darwin;
  myLib = (import ./default.nix) { inherit inputs; };
  outputs = inputs.self.outputs;
in
rec {
  defaultSystems = {
    linux = "x86_64-linux";
    darwin = "aarch64-darwin";
  };

  systems = [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  # ================================================================ #
  # =                            My Lib                            = #
  # ================================================================ #

  # ======================= Package Helpers ======================== #

  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};

  # ========================== Buildables ========================== #

  mkSystem =
    sys: config:
    lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs myLib;
        myArgs = {
          system = sys;
          isCurrentSystemLinux = isLinuxSystem sys;
          isCurrentSystemDarwin = isDarwinSystem sys;
        };
      };
      modules = [
        config
        outputs.nixosModules.default
      ];
    };

  mkDarwinSystem =
    sys: config:
    darwin.lib.darwinSystem {
      system = sys;

      specialArgs = {
        inherit inputs outputs myLib;
        myArgs = {
          system = sys;
          isCurrentSystemLinux = isLinuxSystem sys;
          isCurrentSystemDarwin = isDarwinSystem sys;
        };
      };

      modules = [
        config
        outputs.darwinModules.default
      ];
    };

  mkHome =
    sys: config:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = {
        inherit inputs myLib outputs;
        myArgs = {
          system = sys;
          isCurrentSystemLinux = isLinuxSystem sys;
          isCurrentSystemDarwin = isDarwinSystem sys;
        };
      };
      modules = [
        config
        outputs.homeManagerModules.default
      ];
    };

  # =========================== Helpers ============================ #

  isLinuxSystem = lib.strings.hasSuffix "-linux";
  isDarwinSystem = lib.strings.hasSuffix "-darwin";

  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));

  dirsIn = dir: lib.filterAttrs (name: value: value == "directory") (builtins.readDir dir);

  fileNameOf = path: (builtins.head (builtins.split "\\." (baseNameOf path)));

  # ========================== Extenders =========================== #

  # Evaluates nixos/home-manager module and extends it's options / config
  extendModule =
    { path, ... }@args:
    { pkgs, ... }@margs:
    let
      eval = if (builtins.isString path) || (builtins.isPath path) then import path margs else path margs;
      evalNoImports = builtins.removeAttrs eval [
        "imports"
        "options"
      ];

      extra =
        if (builtins.hasAttr "extraOptions" args) || (builtins.hasAttr "extraConfig" args) then
          [
            (
              { ... }:
              {
                options = args.extraOptions or { };
                config = args.extraConfig or { };
              }
            )
          ]
        else
          [ ];
    in
    {
      imports = (eval.imports or [ ]) ++ extra;

      options =
        if builtins.hasAttr "optionsExtension" args then
          (args.optionsExtension (eval.options or { }))
        else
          (eval.options or { });

      config =
        if builtins.hasAttr "configExtension" args then
          (args.configExtension (eval.config or evalNoImports))
        else
          (eval.config or evalNoImports);
    };

  # Applies extendModules to all modules
  # modules can be defined in the same way
  # as regular imports, or taken from "filesIn"
  extendModules =
    extension: modules:
    map (
      f:
      let
        name = fileNameOf f;
      in
      (extendModule ((extension name) // { path = f; }))
    ) modules;

  # ============================ Shell ============================= #
  # Small tool to iterate over each systems
  eachSystem =
    f: inputs.nixpkgs.lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});

  # Eval the treefmt modules from ./treefmt.nix
  treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ../treefmt.nix);
}
