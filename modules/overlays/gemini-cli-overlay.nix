final: prev: {
  # Use final by default, but callpackage is not a package so its ok
  gemini-cli = prev.callPackage ../dev/packages/gemini-cli.nix {};
}
