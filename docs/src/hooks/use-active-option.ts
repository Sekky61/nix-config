import { useCallback, useMemo } from 'react';
import { getNodeAtPath, getNodeMeta } from '../lib/option-node';
import { type OptionTree } from '../lib/options-tree';
import { type NixOption } from '../lib/nix-options';
import { useQueryParam } from './use-query-param';

export interface ActiveOption {
  path: string;
  meta: NixOption;
}

export const useActiveOption = (optionsTree: OptionTree) => {
  const [pathParam, setPathParam] = useQueryParam('active', null);

  const activeOption = useMemo(() => {
    if (!pathParam) return null;
    const segments = pathParam.split('.').filter(Boolean);
    if (segments.length === 0) return null;

    const node = getNodeAtPath(optionsTree, segments);
    const meta = getNodeMeta(node);
    if (!meta) return null;

    return {
      path: segments.join('.'),
      meta,
    };
  }, [optionsTree, pathParam]);

  const setActiveOption = useCallback(
    (option: ActiveOption | null) => {
      if (!option) {
        setPathParam(null);
        return;
      }

      setPathParam(option.path);
    },
    [setPathParam],
  );

  return {
    activeOption,
    setActiveOption,
  };
};
