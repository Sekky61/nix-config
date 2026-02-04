export type OptionMeta = Record<string, unknown>;

export interface OptionTree {
  [key: string]: OptionTree | OptionMeta;
}

export const optionMetaKey = '_option';

export const optionMetaKeys = new Set([
  'declarations',
  'default',
  'description',
  'example',
  'loc',
  'readOnly',
  'type',
]);

export const isOptionMeta = (value: unknown): value is OptionMeta => {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return false;
  }

  return Object.keys(value).some((key) => optionMetaKeys.has(key));
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

export const buildOptionsTree = (options: Record<string, OptionMeta>): OptionTree => {
  const tree: OptionTree = {};

  for (const [fullName, meta] of Object.entries(options)) {
    insertOption(tree, fullName.split('.'), meta);
  }

  return tree;
};
