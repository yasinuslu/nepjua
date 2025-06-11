{ pkgs, ... }:
let
  nepjuaCli = pkgs.writeShellScriptBin "nep" ''
    export NEPJUA_ROOT="$NEPJUA_ROOT:-$HOME/code/nepjua"
    deno run -A -c "$NEPJUA_ROOT"/deno.jsonc "$NEPJUA_ROOT"/cli/main.ts "$@"
  '';

  nepjuaCliDebug = pkgs.writeShellScriptBin "nep-debug" ''
    export NEPJUA_ROOT="$NEPJUA_ROOT:-$HOME/code/nepjua"
    deno run -A -c "$NEPJUA_ROOT"/deno.jsonc --inspect-brk "$NEPJUA_ROOT"/cli/main.ts "$@"
  '';
in
{
  home.packages = [
    nepjuaCli
    nepjuaCliDebug
  ];
}
