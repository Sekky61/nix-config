import { isOptionMeta, optionMetaKey, type OptionTree } from './options-tree';
import { type NixOption } from './nix-options';

export const getNodeMeta = (node: OptionTree | NixOption | null): NixOption | null => {
  if (!node) return null;
  if (isOptionMeta(node)) return node;
  if (typeof node === 'object' && optionMetaKey in node && isOptionMeta((node as OptionTree)[optionMetaKey])) {
    return (node as OptionTree)[optionMetaKey] as NixOption;
  }
  return null;
};

export const getNodeAtPath = (tree: OptionTree, segments: string[]): OptionTree | NixOption | null => {
  let current: OptionTree | NixOption = tree;
  for (const segment of segments) {
    if (!current || isOptionMeta(current) || typeof current !== 'object') return null;
    const next = (current as OptionTree)[segment];
    if (!next) return null;
    current = next as OptionTree | NixOption;
  }
  return current;
};
