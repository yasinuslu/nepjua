{
  appimageTools,
  fetchurl,
}:
let
  pname = "hoppscotch";
  version = "24.7.1-0";

  src = fetchurl {
    url = "https://github.com/hoppscotch/releases/releases/download/v${version}/Hoppscotch_linux_x64.AppImage";
    sha256 = "sha256-78q148HLRV7Pdx1B+62XktyLG24tZASyrCGUyVIAe9E=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      substituteInPlace $out/hoppscotch.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
    '';
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/hoppscotch.desktop $out/usr/share/applications/hoppscotch.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/256x256@2/apps/hoppscotch.png \
      $out/usr/share/icons/hicolor/256x256@2/apps/hoppscotch.png
  '';
}
