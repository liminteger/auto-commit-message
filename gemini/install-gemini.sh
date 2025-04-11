#!/bin/bash
# install.sh - Install autocommit-gemini script

set -e

echo "Installing autocommit-gemini script..."

# Check for dependencies
echo "Checking dependencies..."

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed."
    if command -v apt-get &> /dev/null; then
        echo "Installing jq using apt-get..."
        sudo apt-get update && sudo apt-get install -y jq
    elif command -v brew &> /dev/null; then
        echo "Installing jq using Homebrew..."
        brew install jq
    elif command -v yum &> /dev/null; then
        echo "Installing jq using yum..."
        sudo yum install -y jq
    else
        echo "Please install jq manually and try again: https://stedolan.github.io/jq/download/"
        exit 1
    fi
fi

# Check for curl
if ! command -v curl &> /dev/null; then
    echo "curl is required but not installed."
    if command -v apt-get &> /dev/null; then
        echo "Installing curl using apt-get..."
        sudo apt-get update && sudo apt-get install -y curl
    elif command -v brew &> /dev/null; then
        echo "Installing curl using Homebrew..."
        brew install curl
    elif command -v yum &> /dev/null; then
        echo "Installing curl using yum..."
        sudo yum install -y curl
    else
        echo "Please install curl manually and try again."
        exit 1
    fi
fi

# Create installation directory
INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR"

# Copy script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_SOURCE="${SCRIPT_DIR}/autocommit-gemini.sh"

if [ -f "$SCRIPT_SOURCE" ]; then
    cp "$SCRIPT_SOURCE" "${INSTALL_DIR}/autocommit-gemini"
    chmod +x "${INSTALL_DIR}/autocommit-gemini"
    echo "Script installed to ${INSTALL_DIR}/autocommit-gemini"
else
    echo "Error: autocommit-gemini.sh not found in the current directory."
    exit 1
fi

# Update PATH if needed
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    echo "Adding ${INSTALL_DIR} to your PATH..."
    
    # Determine shell configuration file
    SHELL_CONFIG=""
    if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
        SHELL_CONFIG="${HOME}/.zshrc"
    elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
        if [ -f "${HOME}/.bash_profile" ]; then
            SHELL_CONFIG="${HOME}/.bash_profile"
        else
            SHELL_CONFIG="${HOME}/.bashrc"
        fi
    fi
    
    if [ -n "$SHELL_CONFIG" ]; then
        echo -e "\n# Added by autocommit-gemini installer" >> "$SHELL_CONFIG"
        echo "export PATH=\"\$PATH:${INSTALL_DIR}\"" >> "$SHELL_CONFIG"
        echo "Added ${INSTALL_DIR} to $SHELL_CONFIG."
        echo "Please restart your shell or run 'source $SHELL_CONFIG' to update your PATH."
    else
        echo "Could not determine shell configuration file."
        echo "Please manually add ${INSTALL_DIR} to your PATH."
    fi
fi

# Prompt about API key
echo
echo "The autocommit-gemini script requires a Google Gemini API key."
echo "You can configure this in two ways:"

# Check if API key is already set in the script
if grep -q "local api_key=\"AIzaSy" "${INSTALL_DIR}/autocommit-gemini"; then
    echo "1. The script already contains an API key."
    echo "2. If you prefer, you can set the GEMINI_API_KEY environment variable instead."
    
    read -p "Would you like to set the GEMINI_API_KEY environment variable? (y/n): " set_env_var
    if [ "$set_env_var" = "y" ]; then
        read -p "Enter your Gemini API key: " gemini_key
        
        if [ -n "$SHELL_CONFIG" ]; then
            echo -e "\n# Added by autocommit-gemini installer" >> "$SHELL_CONFIG"
            echo "export GEMINI_API_KEY=\"$gemini_key\"" >> "$SHELL_CONFIG"
            echo "Added GEMINI_API_KEY to $SHELL_CONFIG."
            echo "Please restart your shell or run 'source $SHELL_CONFIG' to set the environment variable."
        else
            echo "Could not determine shell configuration file."
            echo "Please manually add the following to your shell configuration file:"
            echo "export GEMINI_API_KEY=\"$gemini_key\""
        fi
    fi
else
    echo "1. Set it as an environment variable GEMINI_API_KEY in your shell configuration"
    echo "2. Directly edit the script to add your API key"
    
    read -p "Enter your Gemini API key (leave empty to edit the script manually later): " gemini_key
    
    if [ -n "$gemini_key" ] && [ -n "$SHELL_CONFIG" ]; then
        echo -e "\n# Added by autocommit-gemini installer" >> "$SHELL_CONFIG"
        echo "export GEMINI_API_KEY=\"$gemini_key\"" >> "$SHELL_CONFIG"
        echo "Added GEMINI_API_KEY to $SHELL_CONFIG."
        echo "Please restart your shell or run 'source $SHELL_CONFIG' to set the environment variable."
    elif [ -n "$gemini_key" ]; then
        echo "Could not determine shell configuration file."
        echo "Please manually add the following to your shell configuration file:"
        echo "export GEMINI_API_KEY=\"$gemini_key\""
    else
        echo "No API key provided. You will need to set the GEMINI_API_KEY environment variable"
        echo "or edit the script at ${INSTALL_DIR}/autocommit-gemini before using it."
    fi
fi

echo
echo "Installation complete!"
echo "Usage:"
echo "  autocommit-gemini    # Generate a commit message for staged changes"
echo "  autocommit-gemini --help    # Show help information"
echo
echo "Make sure you have staged changes with 'git add' before running the script."