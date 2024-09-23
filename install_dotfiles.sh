#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if synth-shell is installed
if ! command_exists synth-shell-prompt; then
    echo "synth-shell is not installed. Installing now..."

    # Install dependencies
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm git base-devel

    # Clone and install synth-shell
    git clone --recursive https://github.com/andresgongora/synth-shell.git
    cd synth-shell
    ./setup.sh
    cd ..
    rm -rf synth-shell
else
    echo "synth-shell is already installed."
fi

# Clone the dotfiles repository
echo "Cloning dotfiles repository..."
git clone https://github.com/Hekel1989/dotfiles.git

# Create the destination directory if it doesn't exist
mkdir -p ~/.config/synth-shell

# Copy the contents of the dotfiles/synth-shell directory to .config/synth-shell
echo "Installing dotfiles..."
cp -R dotfiles/assets/synth-shell/* ~/.config/synth-shell/

# Clean up
echo "Cleaning up..."
rm -rf dotfiles

echo "Installation complete!"
