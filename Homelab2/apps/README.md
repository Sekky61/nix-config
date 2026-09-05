# Aplikace

Každá aplikace dostane vlastní podsložku a vlastní deklaraci služby.

```text
apps/
└── life-organizer/
    ├── README.md
    ├── service.nix nebo *.container
    ├── env.example
    └── backup.md
```

Do Gitu patří image reference, porty, mounty, healthchecky a názvy secrets.
Hodnoty secrets a obsah persistentních adresářů do Gitu nepatří.

Než přidáme první aplikaci, sepíšeme její skutečné runtime požadavky. Nechci
zavést jeden obecný mechanismus, který by později musel obcházet databáze,
permissions nebo specifické backup příkazy jednotlivých aplikací.
