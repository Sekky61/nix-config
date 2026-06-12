{
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:
buildNpmPackage rec {
  pname = "safe-chain";
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "AikidoSec";
    repo = "safe-chain";
    rev = version;
    hash = "sha256-cyQ0fcjK//Oa9txLtgMN1nTYeB3g73ERfl2xsq6o9ck=";
  };

  npmDepsHash = "sha256-7GvSXlmaiFYl1YhFM2rDkB44LO498MLZ9gpQxjONnCc=";

  dontNpmBuild = true;

  npmRebuildFlags = ["--ignore-scripts"];

  installPhase = ''
    runHook preInstall

    npmWorkspace=packages/safe-chain npmInstallHook

    mkdir -p $out/lib/node_modules/aikido-safe-chain-workspace
    cp -r packages $out/lib/node_modules/aikido-safe-chain-workspace/
    rm -rf $out/lib/node_modules/aikido-safe-chain-workspace/node_modules/@aikidosec/safe-chain-e2e-tests

    mkdir -p $out/share/safe-chain
    cp -r packages/safe-chain/src/shell-integration/startup-scripts \
      $out/share/safe-chain/

    if [ ! -d $out/share/safe-chain/startup-scripts/include-python ]; then
      mkdir -p $out/share/safe-chain/startup-scripts/include-python
      cp $out/share/safe-chain/startup-scripts/init-posix.sh \
        $out/share/safe-chain/startup-scripts/include-python/
      cp $out/share/safe-chain/startup-scripts/init-fish.fish \
        $out/share/safe-chain/startup-scripts/include-python/
    fi

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Prevents developers from installing malware through JavaScript and Python package managers";
    homepage = "https://github.com/AikidoSec/safe-chain";
  };
}
