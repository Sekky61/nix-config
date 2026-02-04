/*
Browser Options Generator

This function generates a consistent set of NixOS options for browser modules.
It creates enable/default toggles and metadata options for each browser.

Parameters:
- lib: Nixpkgs lib functions
- execName: The executable name of the browser (e.g., "firefox", "google-chrome")
- humanName: Human-readable name for the browser (defaults to execName)
- package: The Nix package for the browser (optional, used for desktop file detection)
- desktopFileName: The desktop file name for MIME associations (auto-detected from package if available)

Generated Options:
- enable: Whether to install and enable this browser
- default: Whether this browser should be the system default
- name: The browser's executable name (read-only, used internally)
- desktopFileName: The desktop file name for MIME type associations (read-only)
*/
{
  lib,
  execName,
  humanName ? execName,
  package ? null,
  desktopFileName ? (
    if package == null
    then null
    else package.meta.desktopFileName or null
  ),
}:
with lib; {
  # Enable this browser - installs the package and makes it available
  enable = mkEnableOption "${humanName} browser";

  # Set this browser as the system default for web protocols
  # Only one browser can be default at a time (enforced by assertions)
  default = mkEnableOption "${humanName} to be the default browser";

  # The executable name used to launch the browser
  # This is used internally for BROWSER environment variable and scripts
  name = mkOption {
    type = types.str;
    default = execName;
    description = "Executable name for launching the browser";
  };

  # Desktop file name for MIME type associations
  # Used by xdg-mime to set default applications for web protocols
  desktopFileName = mkOption {
    type = types.str;
    default = desktopFileName;
    description = "Desktop file name for MIME type associations";
  };
}
