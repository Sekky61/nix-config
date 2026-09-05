# Secrets

## Co patří kam

```text
Git
├── Nix konfigurace
├── zašifrované SOPS soubory
└── veřejné age recipients

VM
├── /etc/ssh/ssh_host_ed25519_key
├── /run/secrets/*
└── /var/lib/homelab/*
```

Privátní age klíče, privátní SSH klíče a hodnoty secretů v čitelné podobě
nepatří do Gitu ani do `/nix/store`.

## Produkční VM

Produkční VM musí mít persistentní SSH host key. `sops-nix` použije tento klíč
pro dešifrování secretů. Proto se při obnově zachovává celý VM disk včetně
`/etc/ssh`.

Administrátorský recovery key se drží mimo VM. Slouží k obnově po ztrátě VM
nebo host key. Musí být uložený odděleně od serveru a jeho backupu.

## Lokální build-vm

Lokální test nemá stabilní provisioning host key. Testovací age klíč se proto
předává při spuštění přes dočasný QEMU shared directory. Tento postup slouží
jen k ověření toku `SOPS -> sops-nix -> /run/secrets`. Secret provisioning
není součástí základní PR konfigurace; lokální testovací soubory zůstávají mimo
Git.

Launcher očekává testovací klíč na hostiteli:

```bash
mkdir -p /tmp/homelab2-secrets
age-keygen -o /tmp/homelab2-secrets/age-key.txt
chmod 600 /tmp/homelab2-secrets/age-key.txt
```

Tento klíč musí odpovídat recipientu v testovacím secretu. Testovací VM proto
není produkční provisioning mechanismus.

## Tailscale

Tailscale má vlastní stav včetně machine key. Tento stav je součástí VM a při
obnovení stejného systémového disku zachová identitu zařízení. Pouhé nastavení
hostname identitu nezachová.

První přihlášení se provede interaktivně uvnitř VM:

```bash
sudo tailscale up --hostname=homelab-apps
```

Auth key je vhodný pro automatizovaný provisioning, ale nepatří do Nix
konfigurace v otevřené podobě. Pro lokální test používáme interaktivní
přihlášení; později můžeme přidat SOPS secret s omezeným nebo krátkodobým key.

## GitHub a Codex

SSH klíč `git/food-organizer-deploy-key` je technicky účetní GitHub klíč pro
uživatele `t3code`. Název vznikl při prvním testu s repozitářem
`food-organizer`; oprávnění se řídí účtem GitHub, ke kterému je veřejný klíč
přidaný.

Git používá wrapper `/etc/t3code-git-ssh`, který načítá privátní klíč pouze z
`/run/secrets`. GitHub host key je deklarovaný v NixOS.

Codex, `gh` a T3 Code jsou instalované systémově pouze pro VM. Přihlášení je
stav uživatele `t3code`, nikoliv uživatele `michal`; jeho konfigurace proto
patří do `/var/lib/homelab/t3code` a není součástí Nix konfigurace.
