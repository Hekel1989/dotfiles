#!/bin/bash

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if synth-shell is installed
synth_shell_installed() {
    if [ -d "$HOME/.config/synth-shell" ]; then
        return 0  # true, synth-shell is installed
    else
        return 1  # false, synth-shell is not installed
    fi
}

# Function to print colored output
print_status() {
    case $1 in
        "success") echo -e "${GREEN}$2${NC}" ;;
        "warning") echo -e "${YELLOW}$2${NC}" ;;
        "error") echo -e "${RED}$2${NC}" ;;
        *) echo "$2" ;;
    esac
}

# Check if synth-shell is installed
if ! synth_shell_installed; then
    print_status "warning" "synth-shell is not installed. Installing now..."

    # Install dependencies
    sudo pacman -Syu --noconfirm
    if ! sudo pacman -S --noconfirm git base-devel; then
        print_status "error" "Failed to install dependencies. Exiting."
        exit 1
    fi

    # Clone and install synth-shell
    if git clone --recursive https://github.com/andresgongora/synth-shell.git; then
        cd synth-shell
        if ./setup.sh; then
            print_status "success" "synth-shell installed successfully."
        else
            print_status "error" "Failed to install synth-shell. Exiting."
            exit 1
        fi
        cd ..
    else
        print_status "error" "Failed to clone synth-shell repository. Exiting."
        exit 1
    fi
else
    print_status "warning" "synth-shell is already installed."
fi

# Create the destination directory if it doesn't exist
mkdir -p ~/.config/synth-shell

# Copy the contents of the /assets/synth-shell directory to ~/.config/synth-shell
print_status "warning" "Installing dotfiles..."
if [ -d "/assets/synth-shell" ]; then
    if cp -R /assets/synth-shell/* ~/.config/synth-shell/; then
        print_status "success" "Dotfiles installed successfully."
    else
        print_status "error" "Failed to install dotfiles. Exiting."
        exit 1
    fi
else
    print_status "error" "/assets/synth-shell directory not found. Exiting."
    exit 1
fi

print_status "success" "Installation complete!"
