import { setRailOrientation, toggleRailOrientation } from './state';
import { type RailOrientation, isRailOrientation } from './types';

type RequestInput = string | string[];

function normalizeArgs(request: RequestInput): string[] {
  if (Array.isArray(request)) {
    return request.filter(Boolean);
  }

  return request.split(' ').filter(Boolean);
}

function setOrientation(orientation: RailOrientation) {
  setRailOrientation(orientation);
  return orientation;
}

export function requestHandler(
  request: RequestInput,
  respond: (response: unknown) => void,
) {
  const args = normalizeArgs(request);
  const command = args[0];

  switch (command) {
    case 'bar-vertical':
      respond(setOrientation('vertical'));
      return;
    case 'bar-horizontal':
      respond(setOrientation('horizontal'));
      return;
    case 'bar-toggle':
      respond(toggleRailOrientation());
      return;
    default:
      if (command && isRailOrientation(command)) {
        respond(setOrientation(command));
        return;
      }

      respond(command ? `unknown request: ${command}` : 'missing request');
  }
}
