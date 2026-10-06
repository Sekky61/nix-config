# Raspberry Pi 4

This host boots from a microSD card. It has a separate `pi` user and Home
Manager profile. T3 Code runs as `pi`; Tailscale exposes its loopback port to
the tailnet. The main `michal` home and common desktop modules are not imported.

The NixOS SD image already contains an installed system, so there is no second
installer step. `nixos-anywhere` is useful for wiping and reinstalling remote
machines, but its usual `kexec` path targets x86_64 and it does not support
Wi-Fi. Colmena is useful for deploying fleets. For this one Pi, the existing
`deploy-rs` tool keeps the update path small and rolls back an activation if
SSH connectivity is lost.

## First boot

Use a 32 GB or larger card. Build the SD image on a machine with an AArch64
builder or binfmt emulation:

```sh
nix build .#nixpi-sd-image
```

Find the card with `lsblk`, unmount its partitions, then write the image to the
whole device. Replace `/dev/sdX` with the verified device path:

```sh
zstdcat result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

Boot with Ethernet connected. The image expands its root partition on first
boot. SSH uses the `michal-nix-key` public key already in the host config. There
is no preset password. Find the address from your router and replace the
example address below.

```sh
ssh pi@192.168.1.123
sudo tailscale up --hostname=nixpi --accept-dns=false
tailscale status
tailscale serve --bg 3773
tailscale serve status
systemctl status t3code
```

If the old Pi is still registered in Tailscale, remove that stale device in
the admin console so the new machine gets the intended `nixpi` MagicDNS name.

The Pi also connects to the `Smart Toilet` Wi-Fi network. Its password is kept
only on the Pi in `/var/lib/nixpi-wifi.secrets` (owner `root:wpa_supplicant`, mode
`0640`). Its content is `psk_smart_toilet=<password>`. Provision this file over
SSH after a fresh flash;
the SD image and Nix store do not contain the password. Ethernet stays enabled
while Wi-Fi connects, so confirm the Wi-Fi address with `ip -br addr` before
disconnecting the cable.

`tailscale serve` makes T3 Code available over HTTPS to devices allowed by your
tailnet policy. Its Serve configuration and Tailscale identity persist on the
card. T3 Code's own pairing may still be needed from the client. Keep a backup
of the card or at least `/var/lib/tailscale` and `/home/pi` before replacing it.

## Updates

Once `nixpi` resolves through Tailscale MagicDNS and SSH works, run from this
repository on the main machine:

```sh
deploy --skip-checks .#nixpi
```

`deploy-rs` evaluates the pinned flake, builds on the main machine using its
AArch64 binfmt support, copies the result to the Pi, activates it, and confirms
that SSH still works. Its automatic rollback is enabled. The Pi only needs
enough free space for the new generation; the main machine does the building.
The ARM activation helper comes from the Nixpkgs binary cache, so the main
machine does not have to compile `deploy-rs` under AArch64 emulation.
`--skip-checks` avoids the repository-wide formatter check, which currently
fails on unrelated files. The deployment still builds the Pi system before it
can activate it.
If an update needs a reboot, reboot separately and check
`systemctl status t3code tailscaled` afterward. Update `flake.lock` separately,
review the diff, and then deploy.

The card flashed in September 2026 has a 30 MB firmware partition. The running
system does not rewrite Raspberry Pi GPU firmware there because the full
firmware set does not fit. Normal NixOS and kernel updates still go through
`deploy-rs`. New SD images built from this repository allocate 256 MB to the
firmware partition. Reflash one of those images before enabling firmware
updates on a running system.

The system generation can be restored locally from the boot menu or with
`sudo nixos-rebuild switch --rollback` if necessary.

## Sources

- [NixOS on Raspberry Pi](https://wiki.nixos.org/wiki/Raspberry_Pi)
- [NixOS ARM SD image installation](https://wiki.nixos.org/wiki/NixOS_on_ARM/Installation)
- [deploy-rs deployment and rollback](https://github.com/serokell/deploy-rs/blob/master/README.md)
- [nixos-anywhere prerequisites](https://github.com/nix-community/nixos-anywhere/blob/main/README.md)
- [Colmena](https://github.com/nix-community/colmena/blob/main/README.md)
- [Tailscale Serve](https://tailscale.com/docs/features/tailscale-serve)
- [T3 Code remote access](https://github.com/pingdotgg/t3code/blob/main/docs/user/remote-access.md)
