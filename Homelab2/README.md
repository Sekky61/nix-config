# Homelab2

Deklarativní homelab pro aplikace provozované v jedné hlavní NixOS VM.

`Homelab2` je samostatný zdroj konfigurace. Stávající `homelab/` zůstává
provozuschopný a tato složka ho nijak nemění.

## Záměr

Proxmox bude hostitel. V něm poběží jedna VM s NixOS. VM může běžet na
stolním počítači i později na serveru. Pro Tailscale je důležitá identita
zařízení, hostname a přístupová pravidla, ne to, na jakém fyzickém stroji
VM právě běží.

Uvnitř VM budou jednotlivé aplikace oddělené jako samostatné služby. Zatím
nepředepisujeme, jestli každá aplikace použije Podman Quadlet, Compose nebo
jiný runtime. Rozhodnutí uděláme podle konkrétní aplikace a její databáze.

## Vrstvy

```text
Proxmox
└── NixOS VM: homelab-apps
    ├── NixOS: OS, uživatelé, firewall, Tailscale
    ├── Podman/systemd: životní cyklus aplikací
    ├── Life Organizer
    ├── další aplikace
    ├── persistentní data
    └── Jellyfin media
```

- NixOS soubory v této složce jsou zdroj pravdy pro VM.
- Data aplikací nejsou konfigurace a nepatří do Gitu.
- Secrets jsou spravované přes SOPS + age.
- Proxmox a backup server zatím nejsou automatizované touto složkou.

## Secrets

Git obsahuje pouze zašifrované secret soubory a deklaraci jejich použití.
Dešifrovací privátní klíč není v Gitu ani v Nix store.

Produkční VM má vlastní persistentní SSH host key. Z jeho veřejné části se
odvodí age recipient, pro který se secrets zašifrují. `sops-nix` potom při
bootu použije privátní host key a vytvoří runtime soubory pod `/run/secrets`.

Při obnově stejného VM disku zůstává identita zachovaná. Při vytvoření nové VM
je potřeba její nový age recipient přidat do `.sops.yaml` nebo použít
administrátorský recovery key.

Lokální `build-vm` používá dočasný age key předaný přes QEMU shared directory.
Je to pouze testovací mechanismus a není součástí produkčního deploymentu.

## Persistentní data

NixOS deklaruje adresáře a mounty, ale nemaže jejich obsah. Persistentní data
aplikací žijí mimo `/nix/store`, typicky pod `/var/lib/homelab`. Základní
záloha je celý VM obraz. Databázové dumpy a aplikační exporty slouží jako
doplňková možnost obnovy jednotlivé aplikace.

VM používá oddělené disky. Systémový disk obsahuje NixOS. Datový disk je
připojený jako `/var/lib/homelab` a obsahuje databáze a persistentní stav
aplikací. Mediální disk je připojený jako `/srv/media` a obsahuje knihovnu
Jellyfinu.

T3 Code běží jako nativní systemd služba na portu 3773. Jeho pracovní adresář
je `/var/lib/homelab/t3code`. Samostatný modul `nixos/t3code.nix` do VM
přidává T3 Code, Codex CLI, GitHub CLI a Git SSH wrapper. Osobní vývojové
moduly z hlavního setupu se do VM neimportují.

GitHub SSH klíč je určený pro účet `Sekky61`, ne pouze pro jeden repozitář.
Jeho privátní část je za běhu dostupná pouze přes `/run/secrets`.

## Testování

NixOS konfiguraci lze nejdřív sestavit bez spuštění aplikací. Potom ji lze
spustit jako lokální NixOS VM nebo na Proxmoxu. Produkční data se přidávají až
po ověření obnovy.

Lokální VM se spouští příkazem:

```bash
./Homelab2/scripts/run-vm
```

Launcher sestaví konfiguraci a použije existující VM obrazy. Lokální port 2222
vede na SSH ve VM a port 3774 na T3 Code. Persistentní systémový obraz je
důležitý také pro zachování identity Tailscale.

Praktické příkazy a postupy jsou v [provozní dokumentaci](docs/operations.md).
