final: prev: {
  # Use final by default, but callpackage is not a package so its ok
  opencode = prev.callPackage ../dev/packages/opencode.nix {};
}
