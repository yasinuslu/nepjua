# ================= NixOS related =========================

export def nixos-switch [
    name: string
    mode: string
]
{if "debug"==$mode {
        # show details via nix-output-monitornom build
$".#nixosConfigurations.($name ).config.system.build.toplevel"--show-trace
--verbose
nixos-rebuild switch
--use-remote-sudo
--flake
$".#($name )"--show-trace
--verbose
}else
{nixos-rebuild switch
--use-remote-sudo
--flake
$".#($name )"}}# ================= macOS related =========================

export def darwin-build [
    name: string
    mode: string
]
{let target = $".#darwinConfigurations.($name ).system"if "debug"==$mode {nom build
$target --extra-experimental-features
"nix-command flakes"
--show-trace
--verbose
}else
{nix build
$target --extra-experimental-features
"nix-command flakes"
}}
export def darwin-switch [
    name: string
    mode: string
]
{if "debug"==$mode {./result/sw/bin/darwin-rebuild switch
--flake
$".#($name )"--show-trace
--verbose
}else
{./result/sw/bin/darwin-rebuild switch
--flake
$".#($name )"}}
export def darwin-rollback []
{./result/sw/bin/darwin-rebuild --rollback
}
