# My nixos router configuration

## Performance

wifi 2.4 Ghz
```
Connecting to host surfer.lan, port 5201
[  7] local 192.168.10.175 port 53554 connected to 192.168.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  7]   0.00-1.00   sec  12.9 MBytes   108 Mbits/sec    0    494 KBytes
[  7]   1.00-2.00   sec  11.8 MBytes  99.1 Mbits/sec    0    660 KBytes
[  7]   2.00-3.00   sec  12.5 MBytes   105 Mbits/sec    0    809 KBytes
[  7]   3.00-4.00   sec  10.0 MBytes  83.9 Mbits/sec    0    871 KBytes
[  7]   4.00-5.00   sec  11.2 MBytes  94.4 Mbits/sec    0    962 KBytes
[  7]   5.00-6.00   sec  11.2 MBytes  94.4 Mbits/sec    0    962 KBytes
[  7]   6.00-7.00   sec  11.2 MBytes  94.4 Mbits/sec    0    962 KBytes
[  7]   7.00-8.00   sec  12.5 MBytes   105 Mbits/sec    0   1.03 MBytes
[  7]   8.00-9.00   sec  11.2 MBytes  94.4 Mbits/sec    0   1.09 MBytes
[  7]   9.00-10.00  sec  11.2 MBytes  94.4 Mbits/sec    0   1.09 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  7]   0.00-10.00  sec   116 MBytes  97.3 Mbits/sec    0             sender
[  7]   0.00-10.04  sec   113 MBytes  94.7 Mbits/sec                  receiver
```

wifi 5 Ghz
```
Connecting to host surfer.lan, port 5201
[  7] local 192.168.10.175 port 45274 connected to 192.168.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  7]   0.00-1.00   sec   153 MBytes  1.28 Gbits/sec    0   3.03 MBytes
[  7]   1.00-2.00   sec   175 MBytes  1.47 Gbits/sec    0   3.03 MBytes
[  7]   2.00-3.00   sec   176 MBytes  1.48 Gbits/sec    0   3.03 MBytes
[  7]   3.00-4.00   sec   180 MBytes  1.51 Gbits/sec    0   3.03 MBytes
[  7]   4.00-5.00   sec   181 MBytes  1.52 Gbits/sec    0   3.03 MBytes
[  7]   5.00-6.00   sec   174 MBytes  1.46 Gbits/sec    0   3.03 MBytes
[  7]   6.00-7.00   sec   184 MBytes  1.54 Gbits/sec    0   3.03 MBytes
[  7]   7.00-8.00   sec   185 MBytes  1.55 Gbits/sec    0   3.03 MBytes
[  7]   8.00-9.00   sec   182 MBytes  1.53 Gbits/sec    0   3.03 MBytes
[  7]   9.00-10.00  sec   176 MBytes  1.48 Gbits/sec    0   3.03 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  7]   0.00-10.00  sec  1.73 GBytes  1.48 Gbits/sec    0             sender
[  7]   0.00-10.01  sec  1.72 GBytes  1.48 Gbits/sec                  receiver
```

etherenet 1 Ghz
```
Connecting to host surfer.lan, port 5201
[  9] local 192.168.10.113 port 47970 connected to 192.168.10.1 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  9]   0.00-1.00   sec   114 MBytes   955 Mbits/sec    0    359 KBytes
[  9]   1.00-2.00   sec   113 MBytes   945 Mbits/sec    0    376 KBytes
[  9]   2.00-3.00   sec   112 MBytes   939 Mbits/sec    0    376 KBytes
[  9]   3.00-4.00   sec   112 MBytes   940 Mbits/sec    0    376 KBytes
[  9]   4.00-5.00   sec   113 MBytes   946 Mbits/sec    0    376 KBytes
[  9]   5.00-6.00   sec   112 MBytes   942 Mbits/sec    0    395 KBytes
[  9]   6.00-7.00   sec   112 MBytes   937 Mbits/sec    0    395 KBytes
[  9]   7.00-8.00   sec   112 MBytes   942 Mbits/sec    0    395 KBytes
[  9]   8.00-9.00   sec   112 MBytes   942 Mbits/sec    0    395 KBytes
[  9]   9.00-10.00  sec   112 MBytes   942 Mbits/sec    0    395 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  9]   0.00-10.00  sec  1.10 GBytes   943 Mbits/sec    0             sender
[  9]   0.00-10.00  sec  1.10 GBytes   942 Mbits/sec                  receiver

```

## Useful commands

Build an SD-Image with:

```
$ nix build -L '.#nixosConfigurations.bpir3.config.system.build.sdImage'
```

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
