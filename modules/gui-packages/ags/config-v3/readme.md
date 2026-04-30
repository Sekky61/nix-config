# AGS v3 config

This directory contains the local AGS v3 config:

- `app.tsx`
- `bar.tsx`
- `style.scss`
- `env.d.ts`
- `package.json`
- `prettier.config.mjs`
- `tsconfig.json`

## Generate types

Run this in this directory:

```bash
ags types -d . -u
```

That command:

- downloads `@girs`
- updates `tsconfig.json`
- links `node_modules`

## Formatting

Prettier is configured locally in this directory so editor tooling can resolve it from here.

Install dependencies once:

```bash
npm install
```

Format everything in this directory that Prettier understands:

```bash
npm run format
```

Check formatting without writing changes:

```bash
npm run format:check
```

Once `node_modules` exists here, tools that look for a local `prettier` binary and config should pick up this directory automatically.
