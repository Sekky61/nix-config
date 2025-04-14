lib: {
  # Extends nixpkgs' lib
  michal = {
    link = path: path;

    optionalHead = list:
      if list == []
      then null
      else builtins.head list;
  };
}
