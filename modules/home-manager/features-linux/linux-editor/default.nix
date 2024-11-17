{ pkgs, ... }: {
    imports = [
        ./overlays.nix
    ];

    home.packages = with pkgs; [
        code-cursor
        vscode
        zed-editor
    ];
}
