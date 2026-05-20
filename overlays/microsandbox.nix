final: prev:
let
  inherit (final) lib stdenv;

  version = "0.4.6";

  sources = {
    "aarch64-darwin" = {
      target = "darwin-aarch64";
      hash = "sha256:1pnibl1gwyz3py0zbfg9qrn76v9ccjhxgc65w9mbyzvp9yqwars6";
      lib = "libkrunfw.5.dylib";
    };
    "aarch64-linux" = {
      target = "linux-aarch64";
      hash = "sha256:1ls6rm0m4sa9hjd0nyi7xxzrvd1lv94442gkaj4v35fj4yl4gcg4";
      lib = "libkrunfw.so.5.2.1";
    };
    "x86_64-linux" = {
      target = "linux-x86_64";
      hash = "sha256:19vddxrggl37czj824llbi8vxyrqblcgdxabcdyd4109575zq9l0";
      lib = "libkrunfw.so.5.2.1";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "microsandbox: unsupported system ${stdenv.hostPlatform.system}");

  # Fish completion: subcommand list (from crates/cli/bin/main.rs) plus
  # dynamic sandbox-name completion for the handful of subcommands that
  # take a sandbox name as their first positional arg.
  msbFishCompletion = ''
    # msb completions — installed by the microsandbox nix package.

    set -l __msb_cmds run create start stop list ls status ps metrics \
        remove rm exec logs image pull registry inspect volume vol \
        snapshot snap install uninstall self

    set -l __msb_no_sub "not __fish_seen_subcommand_from $__msb_cmds"

    complete -c msb -f -n "$__msb_no_sub" -a run      -d "Create a sandbox from an image and run a command in it"
    complete -c msb -f -n "$__msb_no_sub" -a create   -d "Create a sandbox and boot it in the background"
    complete -c msb -f -n "$__msb_no_sub" -a start    -d "Start a stopped sandbox"
    complete -c msb -f -n "$__msb_no_sub" -a stop     -d "Stop one or more running sandboxes"
    complete -c msb -f -n "$__msb_no_sub" -a list     -d "List all sandboxes"
    complete -c msb -f -n "$__msb_no_sub" -a ls       -d "List all sandboxes (alias)"
    complete -c msb -f -n "$__msb_no_sub" -a status   -d "Show sandbox status"
    complete -c msb -f -n "$__msb_no_sub" -a ps       -d "Show sandbox status (alias)"
    complete -c msb -f -n "$__msb_no_sub" -a metrics  -d "Show live metrics for a running sandbox"
    complete -c msb -f -n "$__msb_no_sub" -a remove   -d "Remove one or more sandboxes"
    complete -c msb -f -n "$__msb_no_sub" -a rm       -d "Remove one or more sandboxes (alias)"
    complete -c msb -f -n "$__msb_no_sub" -a exec     -d "Run a command in a running sandbox"
    complete -c msb -f -n "$__msb_no_sub" -a logs     -d "Show captured output from a sandbox"
    complete -c msb -f -n "$__msb_no_sub" -a image    -d "Manage OCI images"
    complete -c msb -f -n "$__msb_no_sub" -a pull     -d "Download an image from a registry"
    complete -c msb -f -n "$__msb_no_sub" -a registry -d "Manage registry credentials"
    complete -c msb -f -n "$__msb_no_sub" -a inspect  -d "Show detailed sandbox configuration and status"
    complete -c msb -f -n "$__msb_no_sub" -a volume   -d "Manage named volumes"
    complete -c msb -f -n "$__msb_no_sub" -a vol      -d "Manage named volumes (alias)"
    complete -c msb -f -n "$__msb_no_sub" -a snapshot -d "Manage disk snapshots"
    complete -c msb -f -n "$__msb_no_sub" -a snap     -d "Manage disk snapshots (alias)"
    complete -c msb -f -n "$__msb_no_sub" -a install  -d "Install a sandbox as a system command"
    complete -c msb -f -n "$__msb_no_sub" -a uninstall -d "Remove an installed sandbox command"
    complete -c msb -f -n "$__msb_no_sub" -a self     -d "Manage the msb installation"

    function __msb_sandboxes
        command msb list -q 2>/dev/null
    end
    function __msb_running_sandboxes
        command msb list --running -q 2>/dev/null
    end
    function __msb_stopped_sandboxes
        command msb list --stopped -q 2>/dev/null
    end

    # Subcommands whose first positional is a sandbox name.
    for sub in exec stop logs inspect remove rm metrics status ps
        complete -c msb -f -n "__fish_seen_subcommand_from $sub" -a "(__msb_running_sandboxes)"
    end
    complete -c msb -f -n "__fish_seen_subcommand_from start" -a "(__msb_stopped_sandboxes)"
  '';
in
{
  microsandbox = stdenv.mkDerivation {
    pname = "microsandbox";
    inherit version;

    src = final.fetchurl {
      url = "https://github.com/superradcompany/microsandbox/releases/download/v${version}/microsandbox-${source.target}.tar.gz";
      inherit (source) hash;
    };

    sourceRoot = ".";

    nativeBuildInputs =
      [ final.makeWrapper ]
      ++ lib.optionals stdenv.isLinux [ final.autoPatchelfHook ];

    buildInputs = lib.optionals stdenv.isLinux [ final.stdenv.cc.cc.lib ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 msb $out/bin/.msb-unwrapped
      install -Dm755 ${source.lib} $out/lib/${source.lib}

      ${lib.optionalString stdenv.isDarwin ''
        # msb dlopens libkrunfw by SONAME at runtime — point it at $out/lib.
        makeWrapper $out/bin/.msb-unwrapped $out/bin/msb \
          --prefix DYLD_LIBRARY_PATH : $out/lib
      ''}
      ${lib.optionalString stdenv.isLinux ''
        # Same idea on linux. autoPatchelfHook handles glibc/ld-linux.
        ln -s ${source.lib} $out/lib/libkrunfw.so.5
        ln -s libkrunfw.so.5 $out/lib/libkrunfw.so
        makeWrapper $out/bin/.msb-unwrapped $out/bin/msb \
          --prefix LD_LIBRARY_PATH : $out/lib
      ''}

      ln -s msb $out/bin/microsandbox

      install -Dm644 ${final.writeText "msb.fish" msbFishCompletion} \
        $out/share/fish/vendor_completions.d/msb.fish

      runHook postInstall
    '';

    meta = {
      description = "Lightweight micro-VM sandboxes for AI agents (libkrun)";
      homepage = "https://github.com/superradcompany/microsandbox";
      license = lib.licenses.asl20;
      platforms = lib.attrNames sources;
      mainProgram = "msb";
    };
  };
}
