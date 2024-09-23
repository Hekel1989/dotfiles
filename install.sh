#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to execute a single script
execute_script() {
    local script_path="$1"

    if [[ ! -f "$script_path" ]]; then
        echo -e "${RED}Error: Script $script_path not found.${NC}"
        return 1
    fi

    echo -e "${YELLOW}Executing $script_path${NC}"
    chmod +x "$script_path"

    # Execute the script and capture its exit status
    . "$script_path"
    local exit_status=$?

    if [ $exit_status -eq 0 ]; then
        echo -e "${GREEN}Success: $script_path${NC}"
    else
        echo -e "${RED}Failure: $script_path (Exit status: $exit_status)${NC}"
    fi

    return $exit_status
}

# Function to clone the repository
clone_repo() {
    local repo_url="$1"
    local repo_name=$(basename "$repo_url" .git)

    git clone "$repo_url"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to clone repository. Exiting.${NC}"
        exit 1
    fi
}

# Function to clean up
cleanup() {
    local repo_name="$1"
    if [ -d "$repo_name" ]; then
        echo -e "${YELLOW}Cleaning up existing $repo_name directory...${NC}"
        rm -rf "$repo_name"
        echo -e "${GREEN}Cleanup complete. Removed existing $repo_name directory.${NC}"
    else
        echo -e "${YELLOW}No existing $repo_name directory found. Proceeding with clean slate.${NC}"
    fi
}

# Main execution
main() {
    local repo_url="https://github.com/Hekel1989/dotfiles.git"
    local repo_name=$(basename "$repo_url" .git)
    local scripts_dir="$repo_name/install_scripts"

    # Initial cleanup
    cleanup "$repo_name"

    # Clone the repository
    clone_repo "$repo_url"

    # Store the current directory
    local original_dir=$(pwd)

    # Change to the scripts directory
    cd "$scripts_dir"

    # Execute each script individually
    for script in *.sh; do
        execute_script "./$script"
        echo # Add a blank line for readability
    done

    # Return to the original directory
    cd "$original_dir"

    # Final cleanup
    cleanup "$repo_name"

    echo -e "${GREEN}All scripts have been executed and final cleanup is complete.${NC}"
}

# Run the main function
main

# Example of how to execute individual scripts:
# execute_script "path/to/dotfiles/install_scripts/script1.sh"
# execute_script "path/to/dotfiles/install_scripts/script2.sh"
