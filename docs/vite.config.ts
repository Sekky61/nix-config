import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

const base = process.env.BASE_PATH ?? '/';
const currentDir = path.dirname(fileURLToPath(import.meta.url));
const optionsPath = path.resolve(currentDir, '../result/options.json');

if (!fs.existsSync(optionsPath)) {
  throw new Error(
    [
      'Missing Nix options data for the docs build.',
      `Expected file at: ${optionsPath}`,
      'Generate it with: nix build .#michal-options-docs',
      'See README.md (Custom Options Docs) for details.',
    ].join('\n')
  );
}

export default defineConfig({
  base,
  plugins: [react()],
});
