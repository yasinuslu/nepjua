{ ... }:
let
  aliases = {
    lsl = "command ls --color";
    ls = "lsd";
  };
  abbreviations_and_maybe_aliases = {
    gst = "git status";
    # Git Pull Request Diff, shows the diff between the current branch and the closest ancestor in main branch
    gpd = "git diff $(git merge-base HEAD origin/main)..HEAD";
    cls = "clear; echo 'Shell cleared'";
    gcom = "git checkout (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')";
    gcd = "cd (git rev-parse --show-toplevel)"; 
    d = "docker";
    doc = "docker compose";
    docp = "docker compose -f docker-compose.yml -f docker-compose.prod.yml";
    docd = "docker compose -f docker-compose.yml -f docker-compose.dev.yml";
    k = "kubectl";
    mk = "microk8s.kubectl";
    md = "microk8s.docker";
    sk = "skaffold";
    df = "df -x'squashfs'";
    j = "just";
  };
in
{
  home.shellAliases = aliases // abbreviations_and_maybe_aliases;
  programs.fish.shellAbbrs = abbreviations_and_maybe_aliases;
}
