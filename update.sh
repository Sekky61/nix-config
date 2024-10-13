#!/bin/bash

# Function to display usage information
usage () {
  echo "Usage: $0 [command]"
  echo "Available commands:"
  echo "  (no argument) : Update system"
  echo "  desktopiso    : Build desktop ISO"
  echo "  update        : Update software versions and rewrite lock file"
  echo "  pi-img        : Build rpi image"
  echo "  pi-deploy     : Deploy to pi"
  echo "  cleanup       : Remove old generations and garbage"
  }

  # Function to run the default command
  run_default_command() {
  echo "Running default command"
  sudo --preserve-env = IMPURITY_PATH nixos-rebuild switch - -flake.#michal --impure
  }

  # Function to run the desktop ISO command
  run_desktopiso_command () {
    echo "Running desktop ISO command"
    sudo --preserve-env = IMPURITY_PATH nix
      build.#nixosConfigurations.desktopIso.config.system.build.isoImage --impure
      echo "ISO built at result/iso/"
      }

      # IMPURITY_PATH=$(pwd) sudo --preserve-env=IMPURITY_PATH nix build  .#nixosConfigurations.michal.config.system.build.vm --impure

      # rpi
      run_rpi_command() {
      echo "Running rpi command"
      nix build '.#nixosConfigurations.rpi.config.system.build.sdImage'
      echo "ISO built at result/sd-image/"
      # Next steps:
      #
      # Get device file:
      # sudo lsblk -p
      #
      # Write image to SD card:
      # caligula burn result/sd-image/nixos-sd-image-24.11.20241006.c31898a-aarch64-linux.img.zst -o /dev/mmcblk0
      #
      # find ip
      # sudo nmap -sn 192.168.0.0/24
      }

      run_pi_deploy() {
      echo "Running rpi deploy command"
      nixos-rebuild switch --flake ".#rpi" --target-host root@nixpi-wifi --use-remote-sudo
      echo "Deployed to pi"
      }

      # Function to run the update command
      run_update_command() {
      echo "Updating software versions and rewriting lock file"
      nix flake update
      echo "Rebuilding system with updated versions"
      sudo --preserve-env=IMPURITY_PATH nixos-rebuild switch --flake .#michal --impure
      }

      # Function to remove old generations and remove garbage
      run_cleanup_command() {
      echo "Removing old generations and garbage"
      nix-env --delete-generations 14d
      nix-store --gc
      }

      export IMPURITY_PATH=$(pwd)

      # Main script logic
      case "$1" in
      "")
      run_default_command
    ;
    ;
    "desktopiso")
    run_desktopiso_command
      ;;
      "update")
      run_update_command
      ;;
      "cleanup")
      run_cleanup_command
      ;;
      "pi-img")
      run_rpi_command
      ;;
      "pi-deploy")
      run_pi_deploy
      ;;
      *)
      echo "Error: Unknown command '$1'"
      usage
      exit 1
      ;;
      esac
