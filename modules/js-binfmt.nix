{pkgs, ...}: {
  boot.binfmt.registrations = {
    javascript-bun = {
      recognitionType = "extension";
      magicOrExtension = "js";
      interpreter = pkgs.writeShellScript "js-bun-wrapper" ''
        ${pkgs.bun}/bin/bun "$@"
      '';
    };
  };
}
