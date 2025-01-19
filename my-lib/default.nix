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
  wrapModule =
    {
      path,
      fullOptionName,
      available ? false,
      name,
      ...
    }@args:
    { pkgs, ... }@margs:
    let
      cfg = margs.config.${fullOptionName};
      isEnabled = available && cfg.enable;
      evalFn =
        { }: (if (builtins.isString path) || (builtins.isPath path) then import path margs else path margs);
      evalNoImportsFn =
        { }:
        builtins.removeAttrs (evalFn { }) [
          "imports"
          "options"
        ];

      eval = if isEnabled then evalFn else { };
      evalNoImports = if isEnabled then evalNoImportsFn else { };

      defaultModules = [
        (
          { ... }:
          {
            imports = [ ];
            options = {
              ${fullOptionName}.enable = lib.mkEnableOption "Enable ${name} module";
            };
            config = {
              ${fullOptionName}.enable = lib.mkDefault false;
            };
          }
        )
      ];
    in
    {
      imports = defaultModules ++ (eval.imports or [ ]);
      options = (eval.options or { });
      config = (eval.config or evalNoImports);
    };

  wrapModules =
    {
      available ? false,
      files,
      prefix ? "",
      ...
    }@args:
    map (
      f:
      let
        name = fileNameOf f;
        fullOptionName = prefix + name;
      in
      wrapModule {
        path = f;
        inherit fullOptionName available name;
      }
    ) files;

  # ============================ Shell ============================= #
  # Small tool to iterate over each systems
  eachSystem =
    f: inputs.nixpkgs.lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});

  # Eval the treefmt modules from ./treefmt.nix
  treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ../treefmt.nix);
}
