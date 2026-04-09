{ ... }:
let
  # Same module chain as Starship's default `$all`, but without `$directory`, so the path can sit
  # on its own line. Update when upgrading Starship if `starship print-config` changes the `$all` list.
  starshipFormatAfterDirectory =
    "$username$hostname$localip$shlvl$singularity$kubernetes$nats$vcsh$fossil_branch$fossil_metrics$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$hg_state$pijul_channel$docker_context$package$bun$c$cmake$cobol$cpp$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$fortran$gleam$golang$gradle$haskell$haxe$helm$java$julia$kotlin$lua$mojo$nim$nodejs$ocaml$odin$opa$perl$php$pulumi$purescript$python$quarto$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$typst$vlang$vagrant$xmake$zig$buf$guix_shell$nix_shell$conda$pixi$meson$spack$memory_usage$aws$gcloud$openstack$azure$direnv$env_var$mise$crystal$custom$sudo$cmd_duration$line_break$jobs$battery$time$status$container$netns$os$shell$character";
in
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    settings = {
      # Put the working directory on its own row so it does not share one line with git, toolchains,
      # Nix, cmd duration, etc. — those segments were crowding the path down to useless `…` tails.
      format = "$directory$line_break${starshipFormatAfterDirectory}";

      directory = {
        truncation_length = 8;
      };

      git_branch = {
        truncation_length = 24;
      };

      docker_context = {
        disabled = true;
      };

      shell = {
        disabled = false;
        fish_indicator = "󰈺 ";
        powershell_indicator = "_";
        bash_indicator = "_";
        zsh_indicator = "_";
        unknown_indicator = "mystery shell";
      };
    };
  };
}
