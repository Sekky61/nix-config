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

export interface OptionFilterContext {
  key: string;
  path: string;
  depth: number;
  node: OptionTree | OptionMeta;
  meta: OptionMeta | null;
  parent: OptionTree | null;
  ancestors: string[];
  pathParts: string[];
  childKeys: string[];
  hasChildren: boolean;
  isLeaf: boolean;
  isOption: boolean;
}

export type OptionTreeFilter = (context: OptionFilterContext) => boolean;

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

const resolveMeta = (node: OptionTree): OptionMeta | null => {
  const meta = node[optionMetaKey];
  return isOptionMeta(meta) ? meta : null;
};

export const createIgnoredKeyFilter = (ignoredKeys: Set<string>): OptionTreeFilter => {
  if (!ignoredKeys.size) {
    return () => true;
  }

  return (context) => {
    const pathParts = new Set(context.pathParts);
    return ignoredKeys.isDisjointFrom(pathParts)
  }
};

export const createSearchFilter = (query: string): OptionTreeFilter => {
  const normalized = query.trim().toLowerCase();
  if (!normalized) {
    return () => true;
  }

  return (context) => {
    const description =
      context.meta && typeof context.meta.description === 'string'
        ? context.meta.description
        : '';
    const typeLabel =
      context.meta && typeof context.meta.type === 'string' ? context.meta.type : '';
    const haystack = `${context.path} ${context.key} ${description} ${typeLabel}`
      .toLowerCase()
      .trim();
    return haystack.includes(normalized);
  };
};

export const filterOptionsTree = (tree: OptionTree, filters: OptionTreeFilter[]): OptionTree => {
  const activeFilters = filters.length > 0 ? filters : [() => true];

  const passesFilters = (context: OptionFilterContext): boolean =>
    activeFilters.every((filter) => filter(context));

  const filterEntry = (
    key: string,
    value: OptionTree | OptionMeta,
    parent: OptionTree | null,
    ancestors: string[],
    depth: number,
  ): OptionTree | OptionMeta | null => {
    const pathParts = [...ancestors, key];
    const path = pathParts.join('.');

    if (isOptionMeta(value)) {
      const context: OptionFilterContext = {
        key,
        path,
        depth,
        node: value,
        meta: value,
        parent,
        ancestors,
        pathParts,
        childKeys: [],
        hasChildren: false,
        isLeaf: true,
        isOption: true,
      };
      return passesFilters(context) ? value : null;
    }

    if (!value || typeof value !== 'object') {
      return null;
    }

    const node = value as OptionTree;
    const childKeys = Object.keys(node).filter((childKey) => childKey !== optionMetaKey);
    const filteredNode: OptionTree = {};

    for (const childKey of childKeys) {
      const childValue = node[childKey];
      if (!childValue) {
        continue;
      }
      const filteredChild = filterEntry(childKey, childValue, node, pathParts, depth + 1);
      if (filteredChild) {
        filteredNode[childKey] = filteredChild;
      }
    }

    const meta = resolveMeta(node);
    const context: OptionFilterContext = {
      key,
      path,
      depth,
      node,
      meta,
      parent,
      ancestors,
      pathParts,
      childKeys,
      hasChildren: childKeys.length > 0,
      isLeaf: childKeys.length === 0,
      isOption: Boolean(meta),
    };

    if (meta && passesFilters(context)) {
      filteredNode[optionMetaKey] = meta;
    }

    if (Object.keys(filteredNode).length === 0) {
      return null;
    }

    return filteredNode;
  };

  const filteredTree: OptionTree = {};
  for (const [key, value] of Object.entries(tree)) {
    const filteredEntry = filterEntry(key, value, null, [], 0);
    if (filteredEntry) {
      filteredTree[key] = filteredEntry;
    }
  }

  return filteredTree;
};
