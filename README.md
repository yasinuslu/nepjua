# Nepjua Nix Config

## MacOS Configuration

### Requirements

1. [Install Nix](https://zero-to-nix.com/start/install)
2. [Install Nix Darwin](https://github.com/LnL7/nix-darwin)
3. Make sure you follow both of the above guides to completion

### Applying Configuration

Execute this every time you make a change to the configuration

```sh
darwin-rebuild switch --flake .#raiden
```

## Linux Configuration

### NixOS Configuration

Install the system

```sh
sudo nixos-rebuild switch --flake .#kaori
```

### Hetzner Cloud Configuration

Add this cloud-config:

```
#cloud-config

runcmd:
  - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=hetznercloud NIX_CHANNEL=nixos-23.11 bash 2>&1 | tee /tmp/infect.log
```

Once the server is up, run:

```sh
nix-shell -p git
git clone https://github.com/yasinuslu/nix-config
cd nix-config
sudo nixos-rebuild switch --flake .#hetzner --impure
```
