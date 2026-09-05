# Storage

## Disky VM

```text
/                         systémový disk
/var/lib/homelab          aplikační data
/srv/media                média pro Jellyfin
```

Systémový disk obsahuje NixOS a může se znovu vytvořit z konfigurace. Datový
disk obsahuje databáze, konfigurace aplikací a jejich persistentní stav.
Mediální disk obsahuje velké soubory, které Jellyfin indexuje a čte.

Konfigurace systému a aplikací patří do Gitu. Obsah datových a mediálních
disků do Gitu nepatří.

## Zálohy

Celá VM je hlavní obnovovací jednotka. Záloha VM zahrnuje systémový i datový
disk. Mediální disk lze zálohovat samostatně, protože obvykle zabírá nejvíc
místa a jeho obsah může být znovu získatelný z původních zdrojů.

U Jellyfinu není nutné zálohovat cache. Důležitá je jeho konfigurace a
metadata, například databáze knihovny, obrázky a nastavení uživatelů.

Při přesunu VM na jiný hypervizor musí zůstat zachované identity VM a obsah
datového disku. Mediální disk může být připojený jiným virtuálním diskem,
pokud uvnitř VM stále dostane filesystem label `homelab-media`.
