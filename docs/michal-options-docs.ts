import { execSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

type OptionMeta = Record<string, unknown>;
type OptionTree = Record<string, OptionMeta | OptionTree>;

const optionMetaKeys = new Set([
  'declarations',
  'default',
  'description',
  'example',
  'loc',
  'readOnly',
  'type',
]);

const optionMetaKey = '_option';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const isOptionMeta = (value: unknown): value is OptionMeta => {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return false;
  }

  return Object.keys(value).some((key) => optionMetaKeys.has(key));
};

const ensureOptionsJson = (root: string): string => {
  const optionsPath = path.join(root, 'result', 'options.json');
  if (fs.existsSync(optionsPath)) {
    return optionsPath;
  }

  execSync('nix build .#michal-options-docs', { cwd: root, stdio: 'inherit' });

  if (!fs.existsSync(optionsPath)) {
    throw new Error(`Expected options JSON at ${optionsPath}`);
  }

  return optionsPath;
};

const insertOption = (tree: OptionTree, pathParts: string[], meta: OptionMeta): void => {
  let current = tree;

  for (let index = 0; index < pathParts.length; index += 1) {
    const key = pathParts[index];
    const isLeaf = index === pathParts.length - 1;
    const existing = current[key];

    if (isLeaf) {
      if (existing && typeof existing === 'object' && !Array.isArray(existing)) {
        if (isOptionMeta(existing)) {
          current[key] = meta;
          return;
        }

        (existing as OptionTree)[optionMetaKey] = meta;
        return;
      }

      current[key] = meta;
      return;
    }

    if (!existing || isOptionMeta(existing)) {
      current[key] = isOptionMeta(existing) ? { [optionMetaKey]: existing } : {};
    }

    current = current[key] as OptionTree;
  }
};

const buildOptionsTree = (options: Record<string, OptionMeta>): OptionTree => {
  const tree: OptionTree = {};

  for (const [fullName, meta] of Object.entries(options)) {
    insertOption(tree, fullName.split('.'), meta);
  }

  return tree;
};

const resolveOutputPath = (root: string): string | null => {
  const outIndex = process.argv.findIndex((value) => value === '--out');
  if (outIndex !== -1 && process.argv[outIndex + 1]) {
    return path.resolve(root, process.argv[outIndex + 1]);
  }

  const positional = process.argv[2];
  if (positional && !positional.startsWith('-')) {
    return path.resolve(root, positional);
  }

  return null;
};

const main = (): void => {
  const optionsPath = ensureOptionsJson(repoRoot);
  const rawOptions = fs.readFileSync(optionsPath, 'utf8');
  const options = JSON.parse(rawOptions) as Record<string, OptionMeta>;
  const tree = buildOptionsTree(options);
  const outputPath = resolveOutputPath(repoRoot);
  const serialized = `${JSON.stringify(tree, null, 2)}\n`;

  if (outputPath) {
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, serialized, 'utf8');
    return;
  }

  process.stdout.write(serialized);
};

main();
