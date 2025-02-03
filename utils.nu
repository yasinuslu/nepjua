# ================= NixOS related =========================
export def nixos-switch[
    name: string
    mode: string
]
{if ==$mode
{
        # show details via nix-output-monitornom build$".#nixosConfigurations.($name ).config.system.build.toplevel"--show-tracee--verbosenixos-rebuild switch
--use-remote-sudo--flake$".#($name )"--show-tracee--verbose else
{nixos-rebuild switch
--use-remote-sudo--flake$".#($name )"}}#=================
macOSrelated
=========================export def darwin-build[
    name: string
    mode: string
]
{let target = $".#darwinConfigurations.($name ).system"iff"debug"==$mode
{nom build
$target
--extra-experimental-features
--extra-experimental-features
"nix-command flakes"--show-trace--verbose else
{nix build
$target --extra-experimental-features
--extra-experimental-features
"nix-command flakes"}}export def darwin-switch[
    name: string
    mode: string
]
{if ==$mode
{./result/sw/bin/darwin-rebuild switch
--flake$".#($name )"--show-tracee--verbose else
{./result/sw/bin/darwin-rebuild switch
--flake$".#($name )"}}export def darwin-rollback[]
{./result/sw/bin/darwin-rebuild --rollback
}
