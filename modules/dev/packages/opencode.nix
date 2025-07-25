{
  lib,
  stdenvNoCC,
  buildGoModule,
  bun,
  fetchFromGitHub,
  fetchurl,
  nix-update-script,
  testers,
  writableTmpDirAsHomeHook,
}: let
  # Source: https://github.com/delafthi/nixpkgs/blob/1f0f25154225df0302adcd7b8110ad2c99e48adc/pkgs/by-name/op/opencode/package.nix
  opencode-node-modules-hash = {
    "aarch64-darwin" = "sha256-uk8HQfHCKTAW54rNHZ1Rr0piZzeJdx6i4o0+xKjfFZs=";
    "aarch64-linux" = "sha256-gDQh8gfFKl0rAujtos1XsCUnxC2Vjyq9xH5FLZoNW5s=";
    "x86_64-darwin" = "sha256-H5+qa7vxhwNYRXUo4v8IFUToVXtyXzU3veIqu4idAbU=";
    "x86_64-linux" = "sha256-meyPYs3daoebdfiWIuljYbplR0+8qNztmw5huhN33nQ=";
  };
  bun-target = {
    "aarch64-darwin" = "bun-darwin-arm64";
    "aarch64-linux" = "bun-linux-arm64";
    "x86_64-darwin" = "bun-darwin-x64";
    "x86_64-linux" = "bun-linux-x64";
  };
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "opencode";
    version = "0.3.22";
    src = fetchFromGitHub {
      owner = "sst";
      repo = "opencode";
      tag = "v${finalAttrs.version}";
      hash = "sha256-yT6uaTEKYb/+A1WhP6AQW0hWMnmS9vlfLn1E57cnzn0=";
    };

    tui = buildGoModule {
      pname = "opencode-tui";
      inherit (finalAttrs) version;
      src = "${finalAttrs.src}/packages/tui";

      vendorHash = "sha256-G1vM8wxTTPpB1Oaxz2YI8AkirwG54A9i6Uq5e92ucyY=";

      subPackages = ["cmd/opencode"];

      env.CGO_ENABLED = 0;

      ldflags = [
        "-s"
        "-X=main.Version=${finalAttrs.version}"
      ];

      installPhase = ''
        runHook preInstall

        install -Dm755 $GOPATH/bin/opencode $out/bin/tui

        runHook postInstall
      '';
    };

    node_modules = stdenvNoCC.mkDerivation {
      pname = "opencode-node_modules";
      inherit (finalAttrs) version src;

      impureEnvVars =
        lib.fetchers.proxyImpureEnvVars
        ++ [
          "GIT_PROXY_COMMAND"
          "SOCKS_SERVER"
        ];

      nativeBuildInputs = [
        bun
        writableTmpDirAsHomeHook
      ];

      dontConfigure = true;

      buildPhase = ''
        runHook preBuild

         export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

         bun install \
           --filter=opencode \
           --force \
           --no-progress

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/node_modules
        cp -R ./node_modules $out

        runHook postInstall
      '';

      # Required else we get errors that our fixed-output derivation references store paths
      dontFixup = true;

      outputHash = opencode-node-modules-hash.${stdenvNoCC.hostPlatform.system};
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

    models-dev-data = fetchurl {
      url = "https://models.dev/api.json";
      sha256 = "sha256-zN6yxf3DpVnjBVXqRiQS+XwHaADC7B4soWjXV5DAExI=";
    };

    nativeBuildInputs = [bun];

    patches = [
      # Patch `packages/opencode/src/provider/models-macro.ts` to load the prefetched `models.dev/api.json`
      # from the `MODELS_JSON` environment variable instead of fetching it at build time.
      ./fix-models-macro.patch
    ];

    configurePhase = ''
      runHook preConfigure

      cp -R ${finalAttrs.node_modules}/node_modules .

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      export MODELS_JSON="$(cat ${finalAttrs.models-dev-data})"
      bun build \
        --define OPENCODE_VERSION="'${finalAttrs.version}'" \
        --compile \
        --minify \
        --target=${bun-target.${stdenvNoCC.hostPlatform.system}} \
        --outfile=opencode \
        ./packages/opencode/src/index.ts \
        ${finalAttrs.tui}/bin/tui

      runHook postBuild
    '';

    dontStrip = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 opencode $out/bin/opencode

      runHook postInstall
    '';

    passthru = {
      tests.version = testers.testVersion {
        package = finalAttrs.finalPackage;
        command = "HOME=$(mktemp -d) opencode --version";
        inherit (finalAttrs) version;
      };
      updateScript = nix-update-script {
        extraArgs = [
          "--subpackage"
          "tui"
          "--subpackage"
          "node_modules"
          "--subpackage"
          "models-dev-data"
        ];
      };
    };

    meta = {
      description = "AI coding agent built for the terminal";
      longDescription = ''
        OpenCode is a terminal-based agent that can build anything.
        It combines a TypeScript/JavaScript core with a Go-based TUI
        to provide an interactive AI coding experience.
      '';
      homepage = "https://github.com/sst/opencode";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
      maintainers = with lib.maintainers; [
        zestsystem
        delafthi
      ];
      mainProgram = "opencode";
    };
  })
