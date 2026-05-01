export const railOrientations = ['vertical', 'horizontal'] as const;

export type RailOrientation = (typeof railOrientations)[number];

export const DEFAULT_RAIL_ORIENTATION: RailOrientation = 'vertical';

export function isRailOrientation(value: unknown): value is RailOrientation {
  return typeof value === 'string' && railOrientations.includes(value as RailOrientation);
}
