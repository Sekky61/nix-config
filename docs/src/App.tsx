import { Link } from 'lucide-react';
import { useEffect, useMemo, useState } from 'react';
import {
  buildOptionsTree,
  createIgnoredKeyFilter,
  createSearchFilter,
  filterOptionsTree,
  isOptionMeta,
  optionMetaKey,
  type OptionTreeFilter,
  type OptionTree,
} from './lib/options-tree';
import { usePageContext } from './PageContext';
import { extractDeclarationPaths } from './lib/extract-declaration-paths';
import { getNixOptions, type NixOption } from './lib/nix-options';

// ─────────────────────────────────────────────────────────────
// Type Badge Component
// ─────────────────────────────────────────────────────────────

type TypeCategory = 'string' | 'number' | 'boolean' | 'list' | 'attrs' | 'path' | 'function' | 'null' | 'unknown';

const categorizeType = (typeLabel: string): TypeCategory => {
  const normalized = typeLabel.toLowerCase();
  if (normalized.includes('string') || normalized.includes('str')) return 'string';
  if (normalized.includes('int') || normalized.includes('float') || normalized.includes('number')) return 'number';
  if (normalized.includes('bool')) return 'boolean';
  if (normalized.includes('list') || normalized.includes('array')) return 'list';
  if (normalized.includes('attrs') || normalized.includes('set') || normalized.includes('submodule')) return 'attrs';
  if (normalized.includes('path')) return 'path';
  if (normalized.includes('function') || normalized.includes('lambda')) return 'function';
  if (normalized.includes('null')) return 'null';
  return 'unknown';
};

interface TypeBadgeProps {
  type: string;
}

const TypeBadge = ({ type }: TypeBadgeProps): JSX.Element => {
  const category = categorizeType(type);
  return (
    <span className={`type-badge type-${category}`} title={type}>
      {type}
    </span>
  );
};

// ─────────────────────────────────────────────────────────────
// Node Description Component
// ─────────────────────────────────────────────────────────────

interface NodeDescriptionProps {
  description: string;
}

const NodeDescription = ({ description }: NodeDescriptionProps): JSX.Element | null => {
  if (!description) return null;
  return <span className="node-description">{description}</span>;
};

// ─────────────────────────────────────────────────────────────
// Node Declarations Component
// ─────────────────────────────────────────────────────────────

interface NodeDeclarationsProps {
  declarations: string[];
}

const NodeDeclarations = ({ declarations }: NodeDeclarationsProps): JSX.Element | null => {
  const { buildDeclarationLink } = usePageContext();
  if (!declarations.length) return null;

  return (
    <span className="node-declarations">
      {declarations.map((declaration) => (
        <a
          key={declaration}
          className="node-declaration"
          href={buildDeclarationLink(declaration)}
          target="_blank"
          rel="noreferrer"
          aria-label={declaration}
          title={declaration}
        >
          <span className="node-declaration__icon" aria-hidden="true">
            <Link size={14} />
          </span>
          <span className="node-declaration__text">{declaration}</span>
        </a>
      ))}
    </span>
  );
};

// ─────────────────────────────────────────────────────────────
// Node Key Component
// ─────────────────────────────────────────────────────────────

interface NodeKeyProps {
  name: string;
  hasChildren: boolean;
  isExpanded: boolean;
  onToggle?: () => void;
}

const NodeKey = ({ name, hasChildren, isExpanded, onToggle }: NodeKeyProps): JSX.Element => {
  return (
    <span
      className={`node-key ${hasChildren ? 'node-key--expandable' : ''}`}
      onClick={hasChildren ? onToggle : undefined}
    >
      {hasChildren && (
        <span className="node-chevron">{isExpanded ? '▾' : '▸'}</span>
      )}
      {name}
    </span>
  );
};

// ─────────────────────────────────────────────────────────────
// Tree Node Component
// ─────────────────────────────────────────────────────────────

interface TreeNodeProps {
  nodeKey: string;
  value: OptionTree | NixOption;
  path: string;
  depth: number;
  defaultExpanded?: boolean;
}

const describeMeta = (meta: NixOption): { typeLabel: string; description: string } => {
  const typeLabel = typeof meta.type === 'string' ? meta.type : 'unknown';
  const description = typeof meta.description === 'string' ? meta.description.trim() : '';
  return { typeLabel, description };
};

const TreeNode = ({ nodeKey, value, path, depth, defaultExpanded = true }: TreeNodeProps): JSX.Element => {
  const [isExpanded, setIsExpanded] = useState(defaultExpanded);

  const meta =
    isOptionMeta(value) ||
      (typeof value === 'object' &&
        value &&
        optionMetaKey in value &&
        isOptionMeta((value as OptionTree)[optionMetaKey]))
      ? (isOptionMeta(value)
        ? value
        : ((value as OptionTree)[optionMetaKey] as NixOption))
      : null;

  const metaContent = meta ? describeMeta(meta) : null;
  const declarations = meta ? extractDeclarationPaths(meta) : [];
  const hasChildren = typeof value === 'object' && value && !isOptionMeta(value);
  const childEntries = hasChildren
    ? Object.entries(value as OptionTree).filter(([k]) => k !== optionMetaKey)
    : [];

  return (
    <li className={`tree-node ${depth === 0 ? 'tree-node--root' : ''}`}>
      <div className="tree-node__header">
        <NodeKey
          name={nodeKey}
          hasChildren={childEntries.length > 0}
          isExpanded={isExpanded}
          onToggle={() => setIsExpanded(!isExpanded)}
        />
        {metaContent && (
          <span className="tree-node__meta">
            <TypeBadge type={metaContent.typeLabel} />
            <NodeDescription description={metaContent.description} />
            <NodeDeclarations declarations={declarations} />
          </span>
        )}
      </div>
      {childEntries.length > 0 && isExpanded && (
        <ul className="tree-node__children">
          {childEntries.map(([childKey, childValue]) => (
            <TreeNode
              key={`${path}.${childKey}`}
              nodeKey={childKey}
              value={childValue}
              path={`${path}.${childKey}`}
              depth={depth + 1}
              defaultExpanded={depth < 1}
            />
          ))}
        </ul>
      )}
    </li>
  );
};

// ─────────────────────────────────────────────────────────────
// Options Tree Component
// ─────────────────────────────────────────────────────────────

interface OptionsTreeProps {
  tree: OptionTree;
}

const OptionsTree = ({ tree }: OptionsTreeProps): JSX.Element => {
  const entries = Object.entries(tree);

  if (entries.length === 0) {
    return <p className="empty-state">No matching options. Try a different search.</p>;
  }

  return (
    <ul className="tree">
      {entries.map(([key, value]) => (
        <TreeNode
          key={key}
          nodeKey={key}
          value={value}
          path={key}
          depth={0}
          defaultExpanded={true}
        />
      ))}
    </ul>
  );
};

// ─────────────────────────────────────────────────────────────
// Stats Component
// ─────────────────────────────────────────────────────────────

const Stats = (): JSX.Element => {
  const { stats } = usePageContext();
  const { total, filtered, isFiltered } = stats;
  return (
    <div className="stats">
      <span className="stats__count">{isFiltered ? filtered : total}</span>
      <span className="stats__label">{isFiltered ? `of ${total}` : 'options'}</span>
    </div>
  );
};

// ─────────────────────────────────────────────────────────────
// Counter Utility
// ─────────────────────────────────────────────────────────────

const countOptions = (node: OptionTree | NixOption): number => {
  if (isOptionMeta(node)) {
    return 1;
  }

  return Object.values(node).reduce<number>((total, value) => {
    if (isOptionMeta(value)) {
      return total + 1;
    }

    if (typeof value === 'object' && value) {
      return total + countOptions(value as OptionTree);
    }

    return total;
  }, 0);
};

// ─────────────────────────────────────────────────────────────
// Main App Component
// ─────────────────────────────────────────────────────────────

const App = (): JSX.Element => {
  const { searchTerm, setSearchTerm, setStats } = usePageContext();
  const nixOptions = useMemo(() => getNixOptions(), []);
  const optionsTree = useMemo(
    () => (nixOptions ? buildOptionsTree(nixOptions) : {}),
    [nixOptions],
  );
  const ignoredKeys = useMemo(() => new Set<string>(['_module']), []);
  const activeFilters = useMemo(() => {
    const filters: OptionTreeFilter[] = [createIgnoredKeyFilter(ignoredKeys)];
    if (searchTerm.trim()) {
      filters.push(createSearchFilter(searchTerm));
    }
    return filters;
  }, [ignoredKeys, searchTerm]);
  const filteredTree = useMemo(
    () => filterOptionsTree(optionsTree, activeFilters),
    [activeFilters, optionsTree],
  );
  const totalCount = countOptions(optionsTree);
  const filteredCount = countOptions(filteredTree);
  const isFiltered = searchTerm.trim().length > 0;

  useEffect(() => {
    setStats({ total: totalCount, filtered: filteredCount, isFiltered });
  }, [totalCount, filteredCount, isFiltered, setStats]);

  if (!nixOptions) {
    return (
      <div className="page">
        <header className="header">
          <div className="header__title">
            <span className="header__eyebrow">michal-options-docs</span>
            <h1>Option Explorer</h1>
          </div>
        </header>
        <main className="main">
          <p className="empty-state">
            Failed to load options.json. Check the console for details.
          </p>
        </main>
      </div>
    );
  }

  return (
    <div className="page">
      <header className="header">
        <div className="header__title">
          <span className="header__eyebrow">michal-options-docs</span>
          <h1>Option Explorer</h1>
        </div>
        <div className="header__controls">
          <div className="search">
            <input
              className="search__input"
              type="search"
              placeholder="Filter options..."
              value={searchTerm}
              onChange={(event) => setSearchTerm(event.target.value)}
            />
          </div>
          <Stats />
        </div>
      </header>

      <main className="main">
        <div className="tree-container">
          <OptionsTree tree={filteredTree} />
        </div>
      </main>
    </div>
  );
};

export default App;
