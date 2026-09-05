# Provoz

## Lokální VM

VM se spouští z kořene repozitáře:

```bash
./Homelab2/scripts/run-vm
```

Launcher nejdřív sestaví `homelab-apps` a potom spustí existující VM obrazy.
Neukončuj VM druhým spuštěním launcheru: systémový disk může být otevřený jen
jednou.

Lokální přesměrování portů:

```text
127.0.0.1:2222  -> VM:22    SSH
127.0.0.1:3774  -> VM:3773 T3 Code
```

Připojení:

```bash
ssh -p 2222 michal@127.0.0.1
```

VM se ukončuje z terminálu, kde běží launcher, pomocí `Ctrl-C`.

## Tailscale

První přihlášení proběhne uvnitř VM:

```bash
sudo tailscale up --hostname=homelab-apps
tailscale status
tailscale ip
```

Po přihlášení je T3 Code dostupný přes MagicDNS na portu 3773. Tailscale
identita je uložená ve stavových datech VM, takže přesun nebo obnovení stejného
disku zachová stejné zařízení.

## T3 Code, Codex a GitHub CLI

Služba a její logy:

```bash
sudo systemctl status t3code
sudo journalctl -u t3code.service -n 200 -f --no-pager -o cat
```

Ověření nástrojů pod stejným účtem jako T3 Code:

```bash
sudo -u t3code -H codex --version
sudo -u t3code -H gh --version
sudo -u t3code -H gh auth status
```

GitHub CLI se přihlašuje jako `t3code`, například:

```bash
sudo -u t3code -H gh auth login
```

Clone přes účetní SSH klíč lze ověřit takto:

```bash
cd /tmp
sudo -u t3code env HOME=/var/lib/homelab/t3code \
  GIT_SSH_COMMAND=/etc/t3code-git-ssh \
  git ls-remote git@github.com:Sekky61/food-organizer.git HEAD
```

## Secrets

Runtime secrets patří pod `/run/secrets`. Nezapisuj jejich obsah do logů ani do
Git repozitáře. Secret provisioning zatím není součástí základní VM
konfigurace; před produkčním nasazením se vrátí jako samostatná změna.

## Storage

```text
/                         systémový disk
/var/lib/homelab          persistentní aplikační data
/srv/media                Jellyfin média
```

Lokální VM vytváří samostatné testovací obrazy `empty0.qcow2` a `empty1.qcow2`.
Jejich přesné umístění je součástí generovaného QEMU runneru; produkční
storage layout pro Proxmox ještě není definovaný.

Jellyfin zatím používá svůj výchozí stavový adresář. Přesun Jellyfin metadata
na datový disk je samostatný úkol před nasazením produkčních médií.

## Diagnostika

Stav důležitých služeb:

```bash
systemctl is-active tailscaled t3code jellyfin nginx
```

Pokud nejde spustit druhá VM, ověř, že první proces stále neběží a nedrží
`homelab-apps.qcow2`. VM obraz nemaž; jeho zachování je důležité pro data i
identitu Tailscale.
