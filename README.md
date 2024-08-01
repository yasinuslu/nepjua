# Nepjua Nix Config

## Getting Started

1. [Install Nix](https://zero-to-nix.com/start/install)

## MacOS Configuration

### Applying Configuration

Execute this every time you make a change to the configuration

Default config is raiden, yours might change

```sh
nix run nix-darwin -- switch --flake .#$hostname
```

## Linux Configuration

### NixOS Configuration

Install the system

```sh
sudo nixos-rebuild switch --flake .#kaori
```

### NixOS-WSL Configuration

Install the system

```sh
sudo nixos-rebuild switch --flake .#tristan --impure
```

### Hetzner Cloud Configuration

Add this cloud-config:

```
#cloud-config

runcmd:
  - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=hetznercloud NIX_CHANNEL=nixos-unstable bash 2>&1 | tee /tmp/infect.log
```

Once the server is up, run:

```sh
nix-shell -p git
git clone https://github.com/yasinuslu/nix-config
cd nix-config
sudo nixos-rebuild switch --flake .#hetzner --impure
```

## References

- Some configurations and ideas are taken from [vimjoyer/nixconf](https://github.com/vimjoyer/nixconf)
- The structure is heavily inspired by [this amazing youtube video](https://www.youtube.com/watch?v=vYc6IzKvAJQ) from @vimjoyer

  ![Directory Structure](./assets/images/directory-structure.png)


## FAQ

### How do I avoid github rate limiting?

First login:

```sh
gh auth login
```

Then set `NIX_CONFIG` environment variable

```sh
export NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)"
```

Or even better

```sh
alias nix="NIX_CONFIG=\"extra-access-tokens = github.com=$(gh auth token)\" nix"
alias niv="NIX_CONFIG=\"extra-access-tokens = github.com=$(gh auth token)\" niv"
```

## Personal Notes

### Google Drive Mount

```sh
rclone mount gdrive: ~/rclone/gdrive --daemon --vfs-cache-mode full
```
