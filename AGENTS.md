# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

NixOS flake-based router configuration targeting a Banana Pi BPI-R3 (single host named `surfer`, `aarch64-linux`). Acts as a wired+wireless AP using `systemd-networkd` + `hostapd`, with secrets via `sops-nix` and remote builds via `nixbuild.net` or an `rpi5` builder.

## Common commands

Build the SD-card image (initial provisioning — note SSH key must be added post-flash so sops can decrypt):
```sh
nix build -L '.#nixosConfigurations.surfer.config.system.build.sdImage'
```

Rebuild & switch on the router itself:
```sh
sudo nixos-rebuild switch --flake .
```

Rebuild remotely via `nixbuild.net` and deploy to `surfer`:
```sh
nixos-rebuild --max-jobs 0 \
  --builders "ssh://eu.nixbuild.net aarch64-linux - 100 1 big-parallel,benchmark" \
  --flake .#surfer --target-host surfer --fast --use-remote-sudo switch
```

Deploy via `deploy-rs` (host `surfer.local`, ssh user `kghost`, activates as root):
```sh
nix run nixpkgs#deploy-rs -- .#surfer
```

Format Nix files (treefmt: `deadnix` + `nixpkgs-fmt`):
```sh
nix fmt
```

Flake checks build every `nixosConfigurations.*.system.build.toplevel` for the current system plus `deploy-rs` schema checks:
```sh
nix flake check
```

Edit/view sops secrets (`.sops.yaml` uses the user's ssh-derived age key):
```sh
sops secrets/secrets.yaml
```

## Architecture

Flake composition uses `flake-parts`. Three top-level imports wire the flake together:

- `nix/` — devshell + per-system `checks` (re-derived in `machines/default.nix`).
- `modules/` — splits into `modules/nixos/` (exposed as `flake.nixosModules.{network,hostapd,monitoring,sshd,nix,nixbuild,rpi-builder,dns}`) and `modules/hm/` (`flake.homeModules.{base,nvim,git,zsh}`). Adding a module requires registering it in the matching `default.nix`.
- `machines/` — defines `flake.nixosConfigurations.surfer` and `flake.deploy.nodes.surfer`. `machines/surfer/default.nix` is the entrypoint that pulls modules in via `inputs.self.nixosModules.*` and configures `home-manager` for user `kghost`. `specialArgs` injects `inputs` and `username` into every module.

Networking (`modules/nixos/network.nix`): a bridge `br-lan` enslaves `lan0..lan3` and `wan` (yes, WAN is currently bridged into the LAN — intentional in this config). `useNetworkd = true`, firewall enabled, NAT disabled, IPv4 forwarding enabled. DNS via `systemd-resolved` + `avahi` mDNS; `tailscale` enabled.

Wireless (`modules/nixos/hostapd.nix`): two radios — `wlan0` (2.4 GHz, WPA3-SAE on `koteczkowo5` + a legacy WPA2-PSK SSID `koteczkowo3` for ESP8266 etc.) and `wlan1` (5 GHz, WPA3-SAE, 160 MHz, Wi-Fi 4/5/6). BSSIDs are not hardcoded: each network defines a placeholder `bssid` plus a `dynamicConfigScripts."20-bssidFile"` that appends the real BSSID from a sops secret at hostapd start (this is how the same config flake can be rebuilt without leaking MACs). When changing wifi networks, both the placeholder and the dynamic script must remain consistent.

Secrets (`machines/surfer/secrets.nix` + `.sops.yaml`): sops decrypts `secrets/secrets.yaml` using an age key derived from `/home/kghost/.ssh/id_ed25519`. New secrets must be declared in `secrets.nix` AND added to the yaml. To generate the age key from an SSH key:
```sh
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"
```
Public form for `.sops.yaml`:
```sh
nix-shell -p ssh-to-age --run 'cat ~/.ssh/id_ed25519.pub | ssh-to-age'
```

Remote builders: `modules/nixos/rpi-builder.nix` declares an `rpi5` aarch64 builder over `ssh-ng` (configured in the local `~/.ssh/config`). `modules/nixos/nixbuild.nix` configures `nixbuild.net` substituter trust.

Hardware quirks: `inputs.nixos-sbc` is pinned to a fork (`ghostbuster91/nixos-sbc`) due to upstream issue #42 — do not bump it without checking. PCIe/disko bootstrap is currently commented out in `machines/surfer/default.nix` because of nixos-sbc issue #9; the system boots from `ext4` on the SD card (`sbc.bootstrap.rootFilesystem = "ext4"`).

## On-router diagnostics

See `README.md` for the full list. Most-used: `nft list ruleset`, `cat /var/lib/dnsmasq/dnsmasq.leases`, `sudo cat /run/hostapd/wlan0.hostapd.conf`, `bridge vlan show`, `ip link show`, `networkctl`, `iw list`.
