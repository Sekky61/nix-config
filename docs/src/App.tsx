import { ChevronDown, ChevronRight, Github, Link, X } from 'lucide-react';
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
import { getNixOptions, type NixOption, type NixValue } from './lib/nix-options';

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
        <span className="node-chevron" aria-hidden="true">
          {isExpanded ? <ChevronDown size={14} /> : <ChevronRight size={14} />}
        </span>
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
  activePath?: string | null;
  onSelect?: (option: ActiveOption) => void;
}

const describeMeta = (meta: NixOption): { typeLabel: string; description: string } => {
  const typeLabel = typeof meta.type === 'string' ? meta.type : 'unknown';
  const description = typeof meta.description === 'string' ? meta.description.trim() : '';
  return { typeLabel, description };
};

const TreeNode = ({
  nodeKey,
  value,
  path,
  depth,
  defaultExpanded = true,
  activePath,
  onSelect,
}: TreeNodeProps): JSX.Element => {
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

  const isActive = activePath === path;

  return (
    <li className={`tree-node ${depth === 0 ? 'tree-node--root' : ''}`}>
      <div
        className={`tree-node__header ${
          meta ? 'tree-node__header--selectable' : ''
        } ${isActive ? 'tree-node__header--active' : ''}`}
        onClick={meta ? () => onSelect?.({ path, meta }) : undefined}
      >
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
              activePath={activePath}
              onSelect={onSelect}
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
  activePath?: string | null;
  onSelect?: (option: ActiveOption) => void;
}

const OptionsTree = ({ tree, activePath, onSelect }: OptionsTreeProps): JSX.Element => {
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
          activePath={activePath}
          onSelect={onSelect}
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
// Active Option Panel
// ─────────────────────────────────────────────────────────────

interface ActiveOption {
  path: string;
  meta: NixOption;
}

interface ActiveOptionPanelProps {
  activeOption: ActiveOption | null;
  optionsTree: OptionTree;
  onClose?: () => void;
  onSelect?: (option: ActiveOption) => void;
}

const formatNixValue = (value?: NixValue): string => {
  if (!value) return '—';
  return value.text || '—';
};

const getNodeMeta = (node: OptionTree | NixOption | null): NixOption | null => {
  if (!node) return null;
  if (isOptionMeta(node)) return node;
  if (typeof node === 'object' && optionMetaKey in node && isOptionMeta((node as OptionTree)[optionMetaKey])) {
    return (node as OptionTree)[optionMetaKey] as NixOption;
  }
  return null;
};

const getNodeAtPath = (tree: OptionTree, segments: string[]): OptionTree | NixOption | null => {
  let current: OptionTree | NixOption = tree;
  for (const segment of segments) {
    if (!current || isOptionMeta(current) || typeof current !== 'object') return null;
    const next = (current as OptionTree)[segment];
    if (!next) return null;
    current = next as OptionTree | NixOption;
  }
  return current;
};

interface ActiveOptionBreadcrumbsProps {
  path: string;
  optionsTree: OptionTree;
  onSelect?: (option: ActiveOption) => void;
}

interface BreadcrumbOption {
  label: string;
  path: string;
  meta: NixOption | null;
  isActive: boolean;
  children: BreadcrumbOption[];
}

interface BreadcrumbDropdownProps {
  label: string;
  hasDropdown: boolean;
  isOpen: boolean;
  options: BreadcrumbOption[];
  onToggle: () => void;
  onSelect?: (option: ActiveOption) => void;
  onClose: () => void;
}

interface BreadcrumbMenuProps {
  options: BreadcrumbOption[];
  isSubmenu?: boolean;
  onSelect?: (option: ActiveOption) => void;
  onClose: () => void;
}

const BreadcrumbMenu = ({ options, isSubmenu = false, onSelect, onClose }: BreadcrumbMenuProps): JSX.Element => {
  return (
    <div className={`breadcrumb-menu ${isSubmenu ? 'breadcrumb-menu--sub' : ''}`} role="menu">
      {options.map((option) => (
        <div key={option.path} className="breadcrumb-menu__item-wrapper">
          <button
            type="button"
            role="menuitem"
            className={`breadcrumb-menu__item ${option.isActive ? 'breadcrumb-menu__item--active' : ''}`}
            onClick={() => {
              if (!option.meta || option.isActive) return;
              onSelect?.({ path: option.path, meta: option.meta });
              onClose();
            }}
          >
            <span>{option.label}</span>
            {option.children.length > 0 && <ChevronRight size={12} className="breadcrumb-menu__chevron" />}
          </button>
          {option.children.length > 0 && (
            <BreadcrumbMenu options={option.children} isSubmenu={true} onSelect={onSelect} onClose={onClose} />
          )}
        </div>
      ))}
    </div>
  );
};

const BreadcrumbDropdown = ({
  label,
  hasDropdown,
  isOpen,
  options,
  onToggle,
  onSelect,
  onClose,
}: BreadcrumbDropdownProps): JSX.Element => {
  return (
    <>
      <button
        type="button"
        className="breadcrumb-button"
        onClick={() => {
          if (!hasDropdown) return;
          onToggle();
        }}
        aria-expanded={isOpen}
        disabled={!hasDropdown}
      >
        <span className="breadcrumb-label">{label}</span>
        {hasDropdown && <ChevronDown size={12} aria-hidden="true" />}
      </button>
      {hasDropdown && isOpen && <BreadcrumbMenu options={options} onSelect={onSelect} onClose={onClose} />}
    </>
  );
};

const ActiveOptionBreadcrumbs = ({ path, optionsTree, onSelect }: ActiveOptionBreadcrumbsProps): JSX.Element => {
  const [openIndex, setOpenIndex] = useState<number | null>(null);
  const segments = useMemo(() => path.split('.').filter(Boolean), [path]);

  const buildBreadcrumbOptions = (
    node: OptionTree | NixOption | null,
    parentSegments: string[],
  ): BreadcrumbOption[] => {
    if (!node || isOptionMeta(node) || typeof node !== 'object') return [];

    return Object.keys(node as OptionTree)
      .filter((key) => key !== optionMetaKey)
      .map((key) => {
        const currentSegments = [...parentSegments, key];
        const currentNode = (node as OptionTree)[key] as OptionTree | NixOption;
        return {
          label: key,
          path: currentSegments.join('.'),
          meta: getNodeMeta(currentNode),
          isActive: segments.join('.') === currentSegments.join('.'),
          children: buildBreadcrumbOptions(currentNode, currentSegments),
        };
      });
  };

  useEffect(() => {
    setOpenIndex(null);
  }, [path]);

  return (
    <div className="active-panel__breadcrumbs" aria-label="Option path">
      <span className="breadcrumb-root">/</span>
      {segments.map((segment, index) => {
        const parentSegments = segments.slice(0, index);
        const parentNode = parentSegments.length ? getNodeAtPath(optionsTree, parentSegments) : optionsTree;
        const siblingOptions = buildBreadcrumbOptions(parentNode, parentSegments);
        const hasDropdown = siblingOptions.length > 1;

        return (
          <div className="breadcrumb-item" key={`${segment}-${index}`}>
            {index > 0 && <span className="breadcrumb-separator">/</span>}
            <BreadcrumbDropdown
              label={segment}
              hasDropdown={hasDropdown}
              isOpen={openIndex === index}
              options={siblingOptions}
              onToggle={() => setOpenIndex(openIndex === index ? null : index)}
              onSelect={onSelect}
              onClose={() => setOpenIndex(null)}
            />
          </div>
        );
      })}
    </div>
  );
};

const ActiveOptionPanel = ({
  activeOption,
  optionsTree,
  onClose,
  onSelect,
}: ActiveOptionPanelProps): JSX.Element => {
  const { buildDeclarationLink } = usePageContext();

  if (!activeOption) {
    return (
      <div className="active-panel active-panel--empty">
        <span className="active-panel__eyebrow">Active option</span>
        <h2>Pick something on the left</h2>
        <p className="active-panel__description">
          Click any option name to spotlight its details, defaults, and declaration trail.
        </p>
      </div>
    );
  }

  const { meta, path } = activeOption;
  const declarations = extractDeclarationPaths(meta);

  return (
    <div className="active-panel">
      <ActiveOptionBreadcrumbs path={path} optionsTree={optionsTree} onSelect={onSelect} />
      <div className="active-panel__header">
        <div>
          <span className="active-panel__eyebrow">Active option</span>
          <h2 className="active-panel__title">{path}</h2>
        </div>
        <div className="active-panel__actions">
          <TypeBadge type={meta.type} />
          {onClose && (
            <button
              type="button"
              className="active-panel__close"
              onClick={onClose}
              aria-label="Close active option"
            >
              <X size={16} />
            </button>
          )}
        </div>
      </div>
      <p className="active-panel__description">
        {meta.description ? meta.description.trim() : 'No description provided.'}
      </p>
      <div className="active-panel__grid">
        <div className="active-panel__card">
          <span className="active-panel__label">Default</span>
          <pre className="active-panel__value">{formatNixValue(meta.default)}</pre>
        </div>
        <div className="active-panel__card">
          <span className="active-panel__label">Example</span>
          <pre className="active-panel__value">{formatNixValue(meta.example)}</pre>
        </div>
        <div className="active-panel__card">
          <span className="active-panel__label">Read-only</span>
          <span className="active-panel__value active-panel__value--inline">
            {meta.readOnly ? 'Yes' : 'No'}
          </span>
        </div>
        <div className="active-panel__card">
          <span className="active-panel__label">Type</span>
          <span className="active-panel__value active-panel__value--inline">{meta.type}</span>
        </div>
      </div>
      <div className="active-panel__section">
        <span className="active-panel__label">Declarations</span>
        <div className="active-panel__links">
          {declarations.length === 0 && <span className="active-panel__muted">No declarations found.</span>}
          {declarations.map((declaration) => (
            <div key={declaration} className="active-panel__link-group">
              <span className="active-panel__link-label">{declaration}</span>
              <a
                className="active-panel__link"
                href={buildDeclarationLink(declaration)}
                target="_blank"
                rel="noreferrer"
              >
                <Github size={14} />
                View on GitHub
              </a>
            </div>
          ))}
        </div>
      </div>
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
  const [activeOption, setActiveOption] = useState<ActiveOption | null>(null);
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
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
        <section className="pane-left">
          <div className="tree-container">
            <OptionsTree
              tree={filteredTree}
              activePath={activeOption?.path ?? null}
              onSelect={(option) => {
                setActiveOption(option);
                setIsDrawerOpen(true);
              }}
            />
          </div>
        </section>
        <button
          type="button"
          className={`drawer-backdrop ${isDrawerOpen ? 'drawer-backdrop--open' : ''}`}
          onClick={() => {
            setActiveOption(null);
            setIsDrawerOpen(false);
          }}
          aria-label="Close active option"
        />
        <section className={`pane-right ${isDrawerOpen ? 'pane-right--open' : ''}`}>
          <ActiveOptionPanel
            activeOption={activeOption}
            optionsTree={optionsTree}
            onClose={() => {
              setActiveOption(null);
              setIsDrawerOpen(false);
            }}
            onSelect={(option) => {
              setActiveOption(option);
              setIsDrawerOpen(true);
            }}
          />
        </section>
      </main>
    </div>
  );
};

export default App;
