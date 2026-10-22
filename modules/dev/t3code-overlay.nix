final: prev: {
  t3code = prev.t3code.override {
    t3code-unwrapped = prev.t3code.unwrapped.overrideAttrs (old: rec {
      version = "0.1.0";
      src = final.fetchFromGitHub {
        owner = "pingdotgg";
        repo = "t3code";
        tag = "v${version}";
        hash = "sha256-P82DqoY1E9wtROwu5Nr7MB/I1PdmZHWXXR4nRa4GWXM=";
      };
      pnpmDeps = final.fetchPnpmDeps {
        inherit (old) pname pnpmWorkspaces;
        inherit version src;
        pnpm = final.pnpm_11;
        fetcherVersion = 4;
        hash = "sha256-oX4tOu20tYO3ci7VvSEL8eFgxAYWp5HlQFSfAWJGJmg=";
      };
    });
  };
}
