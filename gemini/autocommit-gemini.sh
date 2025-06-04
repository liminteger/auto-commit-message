#!/bin/bash
# autocommit-gemini.sh - Generate commit messages using Gemini API

VERSION="1.0.0-gemini"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            echo "autocommit-gemini.sh version $VERSION"
            exit 0
            ;;
        --help)
            echo "Usage: $0 [--version] [--help]"
            echo "Generate Git commit messages using Google Gemini API"
            echo ""
            echo "Options:"
            echo "  --version               Show version information"
            echo "  --help                  Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Get git diff
GIT_DIFF=$(git diff --staged)
if [ -z "$GIT_DIFF" ]; then
    echo "No staged changes found. Use git add to stage files first." >&2
    exit 1
fi

# Get changed files
CHANGED_FILES=$(git diff --staged --name-only)
echo "Changed files: $CHANGED_FILES" >&2

# Get diff stats
DIFF_STATS=$(git diff --staged --stat)
echo "Change summary:" >&2
echo "$DIFF_STATS" >&2

# Get lines added/deleted
LINES_ADDED=$(git diff --staged --numstat | awk '{sum+=$1} END {print sum}')
LINES_DELETED=$(git diff --staged --numstat | awk '{sum+=$2} END {print sum}')

# Function to generate fallback commit message
generate_fallback_message() {
    if echo "$GIT_DIFF" | grep -q "app\.post"; then
        echo "feat: add new POST endpoint"
    elif echo "$CHANGED_FILES" | grep -q "\.md$"; then
        if echo "$CHANGED_FILES" | grep -q "README.md"; then
            echo "docs: update README documentation"
        else
            echo "docs: update documentation"
        fi
    elif echo "$CHANGED_FILES" | grep -q "LICENSE$"; then
        echo "chore: add LICENSE file"
    elif echo "$CHANGED_FILES" | grep -q "\.sh$"; then
        echo "feat: update shell script"
    elif echo "$GIT_DIFF" | grep -q "@Test"; then
        echo "test: add new unit tests"
    elif [ "$(echo "$CHANGED_FILES" | wc -l)" -gt 5 ]; then
        echo "feat: add and update multiple files"
    else
        echo "chore: update project files"
    fi
}

# Function to generate commit message using Gemini API
generate_gemini_commit_message() {
    local api_key=${GEMINI_API_KEY}
    if [ -z "$api_key" ]; then
        echo "Error: GEMINI_API_KEY environment variable not set" >&2
        return 1
    fi

    local api_url="https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${api_key}"
    local temp_file=$(mktemp)

    cat > "$temp_file" << EOL
You are an expert in writing high-quality Git commit messages. Create a concise, professional commit message that follows the Conventional Commits specification.

Rules:
1. The commit message MUST start with one of these prefixes followed by a colon and a space: "feat: ", "fix: ", "docs: ", "style: ", "refactor: ", "test: ", "chore: ".
2. After the prefix, provide a short description of the change (under 50 characters).
3. Return ONLY the commit message in a single line, nothing else.

Changed files:
$CHANGED_FILES

Summary of changes:
$DIFF_STATS

Lines added: $LINES_ADDED
Lines deleted: $LINES_DELETED
EOL

    local json_file=$(mktemp)
    jq -n \
        --arg text "$(cat "$temp_file")" \
        '{
            "contents": [{"parts": [{"text": $text}]}],
            "generationConfig": {
                "temperature": 0.2,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 100
            }
        }' > "$json_file"
    rm "$temp_file"

    echo "Calling Gemini API..." >&2
    local response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d @"$json_file" \
        "$api_url")
    rm "$json_file"

    if echo "$response" | grep -q "\"error\""; then
        echo "API Error: $(echo "$response" | jq -r '.error.message')" >&2
        echo "Full response: $response" >&2
        return 1
    fi

    local commit_message=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text')
    commit_message=$(echo "$commit_message" | tr -d '\n\r"' | sed -E 's/^[[:space:]]*//;s/[[:space:]]*$//')

    if [[ "$commit_message" =~ ^(feat|fix|docs|style|refactor|test|chore):[[:space:]].+ ]]; then
        echo "$commit_message"
        return 0
    else
        echo "Invalid commit message format: $commit_message" >&2
        return 1
    fi
}

# Function to edit commit message
edit_commit_message() {
    local initial_message="$1"
    >&2 echo "Enter your custom commit message (or press Enter to use the default):"
    >&2 echo "Default suggestion: $initial_message"
    read -r -p "> " new_message

    if [ -z "$new_message" ]; then
        echo "$initial_message"
    else
        echo "$new_message"
    fi
}

# Generate commit message
echo "Using Gemini API to generate commit message..." >&2
COMMIT_MESSAGE=$(generate_gemini_commit_message)

if [ $? -ne 0 ] || [ -z "$COMMIT_MESSAGE" ]; then
    echo "API call failed or did not return a valid commit message. Using pattern-based fallback." >&2
    COMMIT_MESSAGE=$(generate_fallback_message)
fi

echo "Suggested commit message: $COMMIT_MESSAGE" >&2
read -p "Do you want to commit with this message? (y/n/e-edit): " confirm

if [ "$confirm" = "y" ]; then
    git commit -m "$COMMIT_MESSAGE"
    echo "✅ Successfully committed!" >&2
elif [ "$confirm" = "e" ]; then
    echo "Opening editor to modify the suggested message..." >&2
    NEW_MESSAGE=$(edit_commit_message "$COMMIT_MESSAGE")
    if [ $? -eq 0 ] && [ -n "$NEW_MESSAGE" ]; then
        git commit -m "$NEW_MESSAGE"
        echo "✅ Successfully committed with your edited message!" >&2
    else
        echo "❌ Commit message was empty. Commit cancelled." >&2
    fi
else
    echo "❌ Commit cancelled." >&2
fi


