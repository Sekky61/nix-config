import type { NixOption } from './nix-options';

const sourceMarker = '-source/';

export const extractDeclarationPaths = (option: NixOption): string[] => {
  const declarations = Array.isArray(option.declarations) ? option.declarations : [];

  return declarations
    .map((declaration) => {
      if (typeof declaration !== 'string') {
        return null;
      }

      const trimmed = declaration.trim();
      if (!trimmed) {
        return null;
      }

      const markerIndex = trimmed.lastIndexOf(sourceMarker);
      const relativePath =
        markerIndex === -1 ? trimmed : trimmed.slice(markerIndex + sourceMarker.length);

      return relativePath || null;
    })
    .filter((value): value is string => Boolean(value));
};
