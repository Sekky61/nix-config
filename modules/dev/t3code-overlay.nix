final: prev: {
  t3code = prev.t3code.override {
    t3code-unwrapped = prev.t3code.unwrapped.overrideAttrs (old: rec {
      version = "0.1.1";
      src = final.fetchFromGitHub {
        owner = "pingdotgg";
        repo = "t3code";
        tag = "v${version}";
        hash = "sha256-kIGiC/uCDgRlqt+8/zZ9K48NBuCGJ1TgqW+rpdZgZUQ=";
      };
      pnpmDeps = final.fetchPnpmDeps {
        inherit (old) pname pnpmWorkspaces;
        inherit version src;
        pnpm = final.pnpm_11;
        fetcherVersion = 4;
        hash = "sha256-witoens1UicKE+SIQCrRk9YtbAVIW5x+2MqDrFh4F0s=";
      };
    });
  };
}
