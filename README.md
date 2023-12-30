# My nixos router configuration

_Based on https://github.com/nakato/nixos-bpir3-example_

## Getting started

Build an SD-Image with:

```sh
$ nix build -L '.#nixosConfigurations.bpir3.config.system.build.sdImage'
```

At this moment the wifi password is not set because the SD card image does not contain ssh key to decrypt sops secrets. Copy the ssh key and reboot the device.

Building using nixbuild remote builder:

```sh
$ nixos-rebuild --max-jobs 0  --builders "ssh://eu.nixbuild.net aarch64-linux - 100 1 big-parallel,benchmark" --flake .#surfer --target-host surfer --fast --use-remote-sudo switch
```

## Useful commands

generate age key from ssh using:

```sh
$ nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt"

```

obtain public key:

```sh
$ nix-shell -p ssh-to-age --run 'cat ~/.ssh/id_ed25519.pub | ssh-to-age'
```

switch configuration:

```sh
$ sudo nixos-rebuild switch --flake .
```

show generated nftables:

```sh
$ nft list ruleset
```

show dhcp leases

```sh
$ cat /var/lib/dnsmasq/dnsmasq.leases
```

show hostapd configs:

```sh
$ sudo cat /run/hostapd/wlan0.hostapd.conf
```

show vlans:

```sh
$ bridge vlan show
```

show ip links (including master-slave relation)

```sh
$ ip link show
```

general state of the network interfaces

```sh
$ networkctl
```

details about radio devices

```sh
$ iw list
```

list connected clients

```sh
$ arp
```

To see the status of the timer run

```sh
$ systemctl status nixos-upgrade.timer
```

The upgrade log can be printed with this command

```sh
$ systemctl status nixos-upgrade.service
```
