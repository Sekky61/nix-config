{
  lib,
  getent,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "clockify-cli";
  version = "0.55.2";

  src = fetchFromGitHub {
    owner = "lucassabreu";
    repo = "clockify-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-D+toy7tFfN5RchqJeT1W1WiGY62ZagEPxE2AnNxGT6I=";
  };

  vendorHash = "sha256-L8jT328TEGbpVq5OwuQrSQdCU24Sb/dwvaty86l8n9Q=";

  buildInputs = [
    getent
  ];

  env.CGO_ENABLED = 0;

  doCheck = true;

  doInstallCheck = true;

  meta = with lib; {
    description = "Command line interface for Clockify";
    homepage = "https://github.com/lucassabreu/clockify-cli";
    license = licenses.mit;
    mainProgram = "clockify-cli";
    platforms = platforms.unix;
  };
})
