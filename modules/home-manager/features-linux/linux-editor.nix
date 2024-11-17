{pkgs, ...}: {
    home.packages = with pkgs; [
        code-cursor
        vscodium
        vscode
        zed-editor
    ];
}