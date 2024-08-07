#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [command]"
    echo "Available commands:"
    echo "  (no argument) : Update system"
    echo "  desktopiso    : Build desktop ISO"
    echo "  update        : Update software versions and rewrite lock file"
}

# Function to run the default command
run_default_command() {
    echo "Running default command"
    sudo --preserve-env=IMPURITY_PATH nixos-rebuild switch --flake .#michal --impure
}

# Function to run the desktop ISO command
run_desktopiso_command() {
    echo "Running desktop ISO command"
    sudo --preserve-env=IMPURITY_PATH nix build .#nixosConfigurations.desktopIso.config.system.build.isoImage --impure
    echo "ISO built at result/iso/"
}

# Function to run the update command
run_update_command() {
    echo "Updating software versions and rewriting lock file"
    nix flake update
    echo "Rebuilding system with updated versions"
    sudo --preserve-env=IMPURITY_PATH nixos-rebuild switch --flake .#michal --impure
}

export IMPURITY_PATH=$(pwd)

# Main script logic
case "$1" in
    "")
        run_default_command
        ;;
    "desktopiso")
        run_desktopiso_command
        ;;
    "update")
        run_update_command
        ;;
    *)
        echo "Error: Unknown command '$1'"
        usage
        exit 1
        ;;
esac
