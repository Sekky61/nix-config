import nixOptions from '../../result/options.json';

type OptionMeta = Record<string, unknown>;
interface OptionTree {
  [key: string]: OptionTree | OptionMeta;
}

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

const isOptionMeta = (value: unknown): value is OptionMeta => {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return false;
  }

  return Object.keys(value).some((key) => metaKeys.has(key));
};

const describeMeta = (meta: OptionMeta): { typeLabel: string; description: string } => {
  const typeLabel = typeof meta.type === 'string' ? meta.type : 'unknown';
  const description = typeof meta.description === 'string' ? meta.description.trim() : '';
  return { typeLabel, description };
};

const renderTree = (
  node: OptionTree | OptionMeta,
  path: string,
  depth: number,
): JSX.Element => {
  const entries = Object.entries(node);

  return (
    <ul className="tree" style={{ marginLeft: depth === 0 ? 0 : 14 }}>
      {entries.map(([key, value]) => {
        const itemPath = `${path}.${key}`;
        const meta =
          isOptionMeta(value) ||
            (typeof value === 'object' &&
              value &&
              optionMetaKey in value &&
              isOptionMeta((value as OptionTree)[optionMetaKey]))
            ? (isOptionMeta(value)
              ? value
              : ((value as OptionTree)[optionMetaKey] as OptionMeta))
            : null;
        const metaContent = meta ? describeMeta(meta) : null;

        return (
          <li className="tree-item" key={itemPath}>
            <div className="node-key">{key}</div>
            {metaContent ? (
              <p className="node-meta">
                <strong>{metaContent.typeLabel}</strong>
                {metaContent.description ? ` — ${metaContent.description}` : ''}
              </p>
            ) : null}
            {typeof value === 'object' && value && !isOptionMeta(value)
              ? renderTree(value as OptionTree, itemPath, depth + 1)
              : null}
          </li>
        );
      })}
    </ul>
  );
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

const App = (): JSX.Element => {
  const optionsTree = nixOptions as OptionTree | OptionMeta;
  const status = 'Loaded';
  const dataSource = 'options-tree.json';
  const optionCount = `${countOptions(optionsTree)} options`;

  return (
    <div className="page">
      <header className="hero">
        <div>
          <p className="eyebrow">michal-options-docs</p>
          <h1>Option Explorer</h1>
          <p className="lead">
            A lightweight view into the custom Nix options. Generated data is shown as a
            nested tree so the hierarchy stays intact.
          </p>
        </div>
        <div className="hero-card">
          <p className="label">Data Source</p>
          <p className="value">{dataSource}</p>
          <p className="label">Total Options</p>
          <p className="value">{optionCount}</p>
        </div>
      </header>

      <main>
        <section className="panel">
          <div className="panel-header">
            <h2>Options Tree</h2>
            <p className="status">{status}</p>
          </div>
          <div className="panel-body" id="tree">
            {optionsTree ? renderTree(optionsTree, 'root', 0) : null}
          </div>
        </section>
      </main>
    </div>
  );
};

export default App;
