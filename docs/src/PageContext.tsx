import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from 'react';

export type LinkProtocol = 'vscode' | 'github' | 'file';

export interface LinkConfig {
  protocol: LinkProtocol;
  basePath?: string;
  githubBaseUrl?: string;
}

export interface PageStats {
  total: number;
  filtered: number;
  isFiltered: boolean;
}

interface PageContextValue {
  searchTerm: string;
  setSearchTerm: (value: string) => void;
  stats: PageStats;
  setStats: (stats: PageStats) => void;
  linkConfig: LinkConfig;
  buildDeclarationLink: (relativePath: string) => string;
}

const defaultStats: PageStats = {
  total: 0,
  filtered: 0,
  isFiltered: false,
};

const defaultLinkConfig: LinkConfig = {
  protocol: 'github',
  githubBaseUrl: 'https://github.com/Sekky61/nix-config/blob/main',
};

const normalizeBase = (base: string): string => base.replace(/\/+$/, '');
const normalizeRelative = (path: string): string => path.replace(/^\/+/, '');

export const createDeclarationLink = (relativePath: string, config: LinkConfig): string => {
  const normalizedPath = normalizeRelative(relativePath);

  if (config.protocol === 'github') {
    const baseUrl = config.githubBaseUrl ? normalizeBase(config.githubBaseUrl) : '';
    return baseUrl ? `${baseUrl}/${normalizedPath}` : normalizedPath;
  }

  const basePath = config.basePath ? normalizeBase(config.basePath) : '';
  const resolvedPath = basePath ? `${basePath}/${normalizedPath}` : normalizedPath;

  if (config.protocol === 'file') {
    return `file://${resolvedPath}`;
  }

  return `vscode://file/${resolvedPath}`;
};

const PageContext = createContext<PageContextValue | null>(null);

interface PageProviderProps {
  children: ReactNode;
  linkConfig?: LinkConfig;
}

export const PageProvider = ({ children, linkConfig }: PageProviderProps): JSX.Element => {
  const [searchTerm, setSearchTerm] = useState('');
  const [stats, setStats] = useState<PageStats>(defaultStats);
  const resolvedLinkConfig = useMemo(
    () => ({ ...defaultLinkConfig, ...linkConfig }),
    [linkConfig],
  );

  const buildDeclarationLink = useCallback(
    (relativePath: string) => createDeclarationLink(relativePath, resolvedLinkConfig),
    [resolvedLinkConfig],
  );

  const value = useMemo(
    () => ({
      searchTerm,
      setSearchTerm,
      stats,
      setStats,
      linkConfig: resolvedLinkConfig,
      buildDeclarationLink,
    }),
    [searchTerm, stats, resolvedLinkConfig, buildDeclarationLink],
  );

  return <PageContext.Provider value={value}>{children}</PageContext.Provider>;
};

export const usePageContext = (): PageContextValue => {
  const context = useContext(PageContext);
  if (!context) {
    throw new Error('usePageContext must be used within PageProvider');
  }
  return context;
};
