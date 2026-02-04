import { useCallback } from 'react';
import { useQueryParam } from './use-query-param';

export const useSearchTerm = () => {
  const [searchParam, setSearchParam] = useQueryParam('search', '');

  const setSearchTerm = useCallback(
    (value: string) => {
      setSearchParam(value);
    },
    [setSearchParam],
  );

  return {
    searchTerm: searchParam ?? '',
    setSearchTerm,
  };
};
