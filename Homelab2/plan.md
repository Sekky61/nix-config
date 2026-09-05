# Homelab2 plan

## Základ

- [x] založit oddělený prostor bez zásahu do původního homelabu
- [x] popsat hlavní NixOS VM
- [x] připravit základní NixOS modul
- [x] ověřit jednoduchou nativní systemd službu
- [x] ověřit Jellyfin jako nativní NixOS službu
- [x] ověřit T3 Code jako nativní NixOS službu

## Nasazení

- [x] přidat lokální způsob spuštění VM na desktopu
- [ ] přidat Tailscale enrollment bez secretů v Gitu
- [ ] převést první aplikaci
- [ ] navrhnout databázové a VM zálohy
- [ ] řešit Proxmox provisioning

## Pravidla

Konfigurační soubory v repozitáři jsou zdrojem pravdy. Stav a data běžících
služeb se do tohoto souboru nezapisují.
