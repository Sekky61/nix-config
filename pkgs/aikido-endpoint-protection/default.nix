{dpkg, fetchurl, lib, stdenvNoCC}:
stdenvNoCC.mkDerivation rec {
  pname = "aikido-endpoint-protection";
  version = "1.10.20";

  src = fetchurl {
    url = "https://github.com/AikidoSec/safechain-internals/releases/download/v${version}/EndpointProtection-amd64.deb";
    hash = "sha256-Ik2yXB0ABNEvaASKp994aNO1JkOhN+Y2julM8oe3rz4=";
  };

  nativeBuildInputs = [dpkg];
  dontUnpack = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    payload="$TMPDIR/aikido-endpoint-protection"
    mkdir -p "$payload" "$out"
    dpkg-deb --extract "$src" "$payload"

    mkdir -p "$out/bin" "$out/opt/aikidosecurity"
    cp -a "$payload/opt/aikidosecurity/endpoint-protection" \
      "$out/opt/aikidosecurity/"
    install -Dm644 "$payload/usr/share/doc/aikido-endpoint-protection/copyright" \
      "$out/share/doc/aikido-endpoint-protection/copyright"

    ln -s "$out/opt/aikidosecurity/endpoint-protection/bin/aikido-doctor" \
      "$out/bin/aikido-doctor"
    ln -s "$out/opt/aikidosecurity/endpoint-protection/scripts/container-entrypoint" \
      "$out/bin/aikido-endpoint-protection-container-entrypoint"
    ln -s "$out/opt/aikidosecurity/endpoint-protection/scripts/healthy" \
      "$out/bin/aikido-endpoint-protection-healthy"
    ln -s "$out/opt/aikidosecurity/endpoint-protection/scripts/start" \
      "$out/bin/aikido-endpoint-protection-start"
    ln -s "$out/opt/aikidosecurity/endpoint-protection/scripts/submit_diagnostics" \
      "$out/bin/aikido-endpoint-protection-submit-diagnostics"
    ln -s "$out/bin/aikido-doctor" "$out/bin/aikidoctl"

    runHook postInstall
  '';

  meta = {
    description = "Aikido Device Protection endpoint agent";
    homepage = "https://github.com/AikidoSec/safechain-internals";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
