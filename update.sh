#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [command]"
    echo "Available commands:"
    echo "  (no argument) : Update system"
    echo "  desktopiso    : Build desktop ISO"
    # Add more command descriptions here as they are implemented
}

# Function to run the default command
run_default_command() {
    echo "Running default command"
    # Add your default command here
    sudo --preserve-env=IMPURITY_PATH nixos-rebuild switch --flake .#michal --impure
}

# Function to run the desktop ISO command
run_desktopiso_command() {
    echo "Running desktop ISO command"
    # Add your desktop ISO command here
    sudo --preserve-env=IMPURITY_PATH nix build .#nixosConfigurations.desktopIso.config.system.build.isoImage --impure
	echo "ISO built at result/iso/"
}

export IMPURITY_PATH=$(pwd)

# Main script logic
if [ $# -eq 0 ]; then
    run_default_command
elif [ "$1" = "desktopiso" ]; then
    run_desktopiso_command
else
    echo "Error: Unknown command '$1'"
    usage
    exit 1
fi


