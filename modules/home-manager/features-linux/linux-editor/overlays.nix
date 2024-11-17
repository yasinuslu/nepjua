{...}: {
    nixpkgs.overlays = [
        (final: prev: {
            code-cursor = prev.code-cursor.overrideAttrs (oldAttrs: {
                # Add a simple postInstall message to verify the override works
                postInstall = (oldAttrs.postInstall or "") + ''
                    echo "THIS IS A TEST OVERRIDE" > $out/test-override.txt
                '';
            });
        })
    ];
}
