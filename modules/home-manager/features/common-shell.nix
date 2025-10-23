{ ... }:
let
  aliases = {
    lsl = "command ls --color";
    ls = "lsd";
  };
  abbreviations = {
    gpd = "git diff $(git merge-base HEAD origin/main)..HEAD | cat";
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
  home.shellAliases = aliases // abbreviations;
  programs.fish.shellAbbrs = abbreviations;
}
