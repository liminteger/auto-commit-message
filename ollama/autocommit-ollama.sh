#!/bin/bash

# autocommit.sh: Generate and apply git commit messages using a server API

VERSION="1.0.0-ollama"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            echo "autocommit.sh version $VERSION"
            exit 0
            ;;
        --help)
            echo "Usage: $0 [--version] [--help]"
            echo "Generate Git commit messages using Ollama server API"
            echo ""
            echo "Options:"
            echo "  --version               Show version information"
            echo "  --help                  Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

# Get environment variables
API_URL=${AUTOCOMMIT_API_URL:-"https://466e-39-116-133-230.ngrok-free.app/generate-commit-message"}

# Function to get staged diff
get_staged_diff() {
    git diff --staged
}

# Function to generate fallback commit message
generate_fallback_message() {
    local changed_files="$1"
    local git_diff="$2"
    
    if echo "$git_diff" | grep -q "app\.post"; then
        echo "feat: add new POST endpoint"
    elif echo "$changed_files" | grep -q "\.md$"; then
        if echo "$changed_files" | grep -q "README.md"; then
            echo "docs: update README documentation"
        else
            echo "docs: update documentation"
        fi
    elif echo "$changed_files" | grep -q "LICENSE$"; then
        echo "chore: add LICENSE file"
    elif echo "$changed_files" | grep -q "\.sh$"; then
        echo "feat: update shell script"
    elif echo "$git_diff" | grep -q "@Test"; then
        echo "test: add new unit tests"
    elif [ "$(echo "$changed_files" | wc -l)" -gt 5 ]; then
        echo "feat: add and update multiple files"
    else
        echo "chore: update project files"
    fi
}

# Function to generate commit message using server API
generate_commit_message() {
    local diff="$1"
    
    # No changes staged
    if [ -z "$diff" ]; then
        echo "No changes staged for commit." >&2
        exit 1
    fi
    
    # Create JSON payload
    local json_file=$(mktemp)
    printf '{"diff": %s}\n' "$(echo "$diff" | jq -Rs .)" > "$json_file" || {
        echo "Error creating JSON payload." >&2
        rm -f "$json_file"
        exit 1
    }

    echo "Calling server API..." >&2

    # Make API request
    local response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d @"$json_file" \
        "$API_URL") || {
        echo "Error: Failed to connect to server API." >&2
        rm -f "$json_file"
        return 1
    }

    rm -f "$json_file"

    # Check for errors
    if echo "$response" | grep -q "\"detail\""; then
        echo "API Error: $(echo "$response" | jq -r '.detail' 2>/dev/null || echo "$response")" >&2
        return 1
    fi

    # Extract commit message
    local commit_message=$(echo "$response" | jq -r '.commit_message' 2>/dev/null)
    
    # Check if jq command succeeded
    if [ $? -ne 0 ] || [ -z "$commit_message" ]; then
        echo "Error: Failed to parse commit message from response." >&2
        echo "Response: $response" >&2
        return 1
    fi

    # Clean up message
    commit_message=$(echo "$commit_message" | tr -d '\n\r"' | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')

    echo "$commit_message"
    return 0
}

# Function to edit commit message using the default editor
edit_commit_message() {
    local initial_message="$1"
    local temp_file=$(mktemp)

    echo "$initial_message" > "$temp_file"

    EDITOR=${EDITOR:-$(command -v nano || command -v vim || command -v vi)}
    if [ -z "$EDITOR" ]; then
        echo "No suitable editor found. Install nano, vim or set the EDITOR environment variable." >&2
        rm "$temp_file"
        return 1
    fi

    "$EDITOR" "$temp_file"

    local new_message=$(head -n 1 "$temp_file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    rm "$temp_file"

    if [ -n "$new_message" ]; then
        echo "$new_message"
        return 0
    else
        echo "Commit message was empty." >&2
        return 1
    fi
}

# Main function
main() {
    # 1. Get staged diff
    local diff=$(get_staged_diff)
    
    if [ -z "$diff" ]; then
        echo "No staged changes found. Use git add to stage files first." >&2
        exit 1
    fi
    
    # Get change information
    local changed_files=$(git diff --staged --name-only)
    echo "Changed files:" >&2
    echo "$changed_files" >&2
    
    local diff_stats=$(git diff --staged --stat)
    echo "Change summary:" >&2
    echo "$diff_stats" >&2
    
    # 2. Generate commit message
    echo "Using Ollama API to generate commit message..." >&2
    local commit_message=$(generate_commit_message "$diff")
    
    # 3. Fallback to pattern-based message if API fails
    if [ $? -ne 0 ] || [ -z "$commit_message" ]; then
        echo "API call failed or did not return a valid commit message. Using pattern-based fallback." >&2
        commit_message=$(generate_fallback_message "$changed_files" "$diff")
    fi
    
    echo "Suggested commit message: $commit_message" >&2
    
    # 4. User confirmation
    read -p "Do you want to commit with this message? (y/n/e-edit): " choice
    case "${choice,,}" in
        y|yes)
            git commit -m "$commit_message"
            echo "Successfully committed!" >&2
            ;;
        e|edit)
            echo "Opening editor to modify the suggested message..." >&2
            local new_message=$(edit_commit_message "$commit_message")
            if [ $? -eq 0 ] && [ -n "$new_message" ]; then
                git commit -m "$new_message"
                echo "Successfully committed with your edited message!" >&2
            else
                echo "Commit message was empty. Commit cancelled." >&2
            fi
            ;;
        *)
            echo "Commit cancelled." >&2
            ;;
    esac
}

# Check for required tools
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first." >&2
    exit 1
fi

# Run main
main