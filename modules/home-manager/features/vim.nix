{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [
    (
      let
        baseConfig = inputs.khanelivim.nixvimConfigurations.${pkgs.system}.khanelivim;
        extendedConfig = baseConfig.extendModules {
          modules = [
            {
              # Disable specific plugins
              plugins.neotest.enable = lib.mkForce false;
            }
          ];
        };
      in
      extendedConfig.config.build.package
    )
    pkgs.pngpaste
  ];

  home.shellAliases = {
    vim = "nvim";
  };
}
