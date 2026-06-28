{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  # khanelivim (Neovim). Two heavy packages used to make this rebuild from source
  # on every switch, so we drop them via extendModules:
  #   - PowerShell 7.x + roslyn-ls, pulled in by the C# LSP
  #     (khanelivim.lsp.csharp defaults to "roslyn"); disabled with csharp = null.
  #   - sqlfluff (SQL linter + formatter), auto-installed by nvim-lint and
  #     conform; dropped via each plugin's autoInstall.overrides.
  # NOTE: marksman (Markdown LSP, written in .NET) still pulls dotnet-runtime
  # from source. Kept intentionally; drop it with
  # `lsp.servers.marksman.enable = lib.mkForce false;` if that build is unwanted.
  home.packages = [
    (
      let
        baseConfig = inputs.khanelivim.nixvimConfigurations.${pkgs.system}.khanelivim;
        extendedConfig = baseConfig.extendModules {
          modules = [
            {
              # C# LSP (roslyn.nvim + rzls) drags in roslyn-ls (PowerShell) and
              # dotnet, so drop it entirely.
              khanelivim.lsp.csharp = lib.mkForce null;

              # Drop sqlfluff from the SQL linter and formatter auto-install.
              plugins.lint.autoInstall.overrides.sqlfluff = null;
              plugins.conform-nvim.autoInstall.overrides.sqlfluff = null;
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
