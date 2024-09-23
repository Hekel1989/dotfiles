#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to execute a single script
execute_script() {
    local script_path="$1"

    if [[ ! -f "$script_path" ]]; then
        echo -e "${RED}Error: Script $script_path not found.${NC}"
        return 1
    fi

    echo "Executing $script_path"
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

    if [[ ! -d "$repo_name" ]]; then
        git clone "$repo_url"
    else
        echo "Repository $repo_name already exists. Updating..."
        cd "$repo_name"
        git pull
        cd ..
    fi
}

# Main execution
main() {
    local repo_url="https://github.com/Hekel1989/dotfiles.git"
    local scripts_dir="dotfiles/install_scripts"

    # Clone or update the repository
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

    echo "All scripts have been executed"
}

# Run the main function
main

# Example of how to execute individual scripts:
# execute_script "path/to/dotfiles/install_scripts/script1.sh"
# execute_script "path/to/dotfiles/install_scripts/script2.sh"
