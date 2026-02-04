import { useCallback, useEffect, useState } from 'react';

const readQueryParam = (key: string): string | null => {
  if (typeof window === 'undefined') return null;
  const params = new URLSearchParams(window.location.search);
  return params.get(key);
};

const buildNextUrl = (params: URLSearchParams): string => {
  const query = params.toString();
  return `${window.location.pathname}${query ? `?${query}` : ''}${window.location.hash}`;
};

export const useQueryParam = (key: string, defaultValue: string | null = null) => {
  const readValue = useCallback(() => {
    const nextValue = readQueryParam(key);
    return nextValue ?? defaultValue;
  }, [key, defaultValue]);

  const [value, setValue] = useState<string | null>(() => readValue());

  useEffect(() => {
    setValue(readValue());
  }, [readValue]);

  useEffect(() => {
    const handlePopState = () => {
      setValue(readValue());
    };

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, [readValue]);

  const updateValue = useCallback(
    (nextValue: string | null) => {
      const params = new URLSearchParams(window.location.search);
      const normalized = nextValue ?? '';

      if (normalized) {
        params.set(key, normalized);
      } else {
        params.delete(key);
      }

      window.history.replaceState(null, '', buildNextUrl(params));
      setValue(normalized ? normalized : defaultValue);
    },
    [key, defaultValue],
  );

  return [value, updateValue] as const;
};
