{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "oh-my-tmux";
  version = "2026-02-21";

  src = pkgs.fetchFromGitHub {
    owner = "gpakosz";
    repo = ".tmux";
    # Pin to an immutable commit, not a moving branch. Tracking `master`
    # breaks reproducibility: upstream moves, the recorded hash goes stale,
    # and a fresh Nix store (e.g. after a reinstall) fails to fetch.
    rev = "af33f07134b76134acca9d01eacbdecca9c9cda6";
    sha256 = "sha256-nXm664l84YSwZeRM4Hsweqgz+OlpyfwXcgEdyNGhaGA=";
  };

  installPhase = ''
    mkdir -p $out
    cp .tmux.conf $out/tmux.conf
    cp .tmux.conf.local $out/tmux.conf.local
  '';

  meta = with pkgs.lib; {
    description = "Oh my tmux! My self-contained, pretty & versatile tmux configuration";
    homepage = "https://github.com/gpakosz/.tmux";
    license = with licenses; [
      mit
      wtfpl
    ];
    platforms = platforms.unix;
  };
}
