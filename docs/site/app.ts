import optionsTree from '../../result/options.json' with { type: 'json' };

type OptionMeta = Record<string, unknown>;
type OptionTree = Record<string, OptionTree | OptionMeta>;

const optionMetaKey = '_option';

const metaKeys = new Set([
  'declarations',
  'default',
  'description',
  'example',
  'loc',
  'readOnly',
  'type',
]);

const statusEl = document.querySelector('#status');
const treeEl = document.querySelector('#tree');
const countEl = document.querySelector('#option-count');
const sourceEl = document.querySelector('#data-source');

const isOptionMeta = (value: unknown): value is OptionMeta => {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return false;
  }

  return Object.keys(value).some((key) => metaKeys.has(key));
};

const updateText = (element: Element | null, text: string): void => {
  if (!element) {
    return;
  }

  element.textContent = text;
};

const renderTree = (node: OptionTree | OptionMeta, depth = 0): HTMLUListElement => {
  const list = document.createElement('ul');
  list.className = 'tree';
  list.style.marginLeft = depth === 0 ? '0' : '14px';

  for (const [key, value] of Object.entries(node)) {
    const item = document.createElement('li');
    item.className = 'tree-item';

    const title = document.createElement('div');
    title.className = 'node-key';
    title.textContent = key;
    item.appendChild(title);

    if (isOptionMeta(value)) {
      const meta = document.createElement('p');
      meta.className = 'node-meta';
      const typeLabel = typeof value.type === 'string' ? value.type : 'unknown';
      const description = typeof value.description === 'string' ? value.description.trim() : '';
      meta.innerHTML = `<strong>${typeLabel}</strong>${description ? ` — ${description}` : ''}`;
      item.appendChild(meta);
    } else if (typeof value === 'object' && value) {
      if (optionMetaKey in value && isOptionMeta(value[optionMetaKey])) {
        const meta = document.createElement('p');
        meta.className = 'node-meta';
        const optionMeta = value[optionMetaKey] as OptionMeta;
        const typeLabel = typeof optionMeta.type === 'string' ? optionMeta.type : 'unknown';
        const description =
          typeof optionMeta.description === 'string' ? optionMeta.description.trim() : '';
        meta.innerHTML = `<strong>${typeLabel}</strong>${description ? ` — ${description}` : ''}`;
        item.appendChild(meta);
      }

      item.appendChild(renderTree(value as OptionTree, depth + 1));
    }

    list.appendChild(item);
  }

  return list;
};

const countOptions = (node: OptionTree | OptionMeta): number => {
  if (isOptionMeta(node)) {
    return 1;
  }

  return Object.values(node).reduce((total, value) => {
    if (isOptionMeta(value)) {
      return total + 1;
    }

    if (typeof value === 'object' && value) {
      return total + countOptions(value as OptionTree);
    }

    return total;
  }, 0);
};

const main = (): void => {
  updateText(statusEl, 'Loaded');
  updateText(sourceEl, 'options-tree.json');
  updateText(countEl, `${countOptions(optionsTree as OptionTree)} options`);

  if (!treeEl) {
    return;
  }

  treeEl.innerHTML = '';
  treeEl.appendChild(renderTree(optionsTree as OptionTree));
};

main();
