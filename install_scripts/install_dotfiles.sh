#!/bin/bash

# Function to check if synth-shell is installed
synth_shell_installed() {
    if [ -d "$HOME/.config/synth-shell" ] && [ -f "$HOME/.config/synth-shell/synth-shell-prompt.config" ]; then
        return 0  # true, synth-shell is installed
    else
        return 1  # false, synth-shell is not installed
    fi
}

# Check if synth-shell is installed
if ! synth_shell_installed; then
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
cp -R dotfiles/synth-shell/* ~/.config/synth-shell/

# Clean up
echo "Cleaning up..."
rm -rf dotfiles

echo "Installation complete!"
