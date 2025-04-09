# AutoCommit PowerShell Version
# Generates git commit messages automatically in Windows environments.

# Version information
$VERSION = "1.0.0-win"

# Configuration file paths
$CONFIG_DIR = "$env:USERPROFILE\.config\autocommit"
$CONFIG_FILE = "$CONFIG_DIR\config.json"

# Load configuration
function Load-Config {
    if (Test-Path $CONFIG_FILE) {
        $config = Get-Content $CONFIG_FILE | ConvertFrom-Json
        return $config
    } else {
        # Default configuration
        return @{
            language = "ko"
        }
    }
}

# Initialize configuration
$config = Load-Config

# Get git diff information
$GIT_DIFF = git diff --staged

if (-not $GIT_DIFF) {
    Write-Host "No staged changes found. Use git add command to stage files."
    exit 1
}

# Get list of changed files
$CHANGED_FILES = git diff --staged --name-only
Write-Host "Changed files: $CHANGED_FILES"

# Change summary statistics
$DIFF_STAT = (git diff --staged --stat | Select-Object -Last 1)
Write-Host "Change summary: $DIFF_STAT"

Write-Host "Analyzing changes to generate commit message..."

# Count changed files
$FILES_COUNT = ($CHANGED_FILES -split "`n").Count

# Pattern matching based on file type
if ($CHANGED_FILES -match "\.md$") {
    if ($CHANGED_FILES -match "README.md") {
        $COMMIT_MESSAGE = "docs: update README documentation"
    } else {
        $COMMIT_MESSAGE = "docs: update documentation"
    }
} elseif ($CHANGED_FILES -match "LICENSE$") {
    $COMMIT_MESSAGE = "chore: add license file"
} elseif ($CHANGED_FILES -match "\.ps1$|\.bat$|\.cmd$") {
    $COMMIT_MESSAGE = "feat: update script files"
} elseif ($FILES_COUNT -gt 5) {
    $COMMIT_MESSAGE = "feat: add and update multiple files"
} elseif ($GIT_DIFF -match "app\.get") {
    # Route related changes
    if ($GIT_DIFF -match "\+.*app\.get") {
        $routeMatch = [regex]::Match($GIT_DIFF, "app\.get.*[\'\"](/[^\'\"]*)[\'\"']")
        if ($routeMatch.Success) {
            $ROUTE = $routeMatch.Groups[1].Value
            $COMMIT_MESSAGE = "feat: add $ROUTE endpoint"
        } else {
            $COMMIT_MESSAGE = "feat: add new API endpoint"
        }
    } else {
        $COMMIT_MESSAGE = "refactor: modify API endpoint"
    }
} elseif ($CHANGED_FILES -match "\.js$") {
    $COMMIT_MESSAGE = "feat: update JavaScript code"
} elseif ($CHANGED_FILES -match "\.css$|\.scss$") {
    $COMMIT_MESSAGE = "style: modify style files"
} elseif ($CHANGED_FILES -match "\.html$") {
    $COMMIT_MESSAGE = "feat: update HTML templates"
} else {
    # Default message
    $FILE_NAME = (($CHANGED_FILES -split "`n")[0] -split "/")[-1]
    $COMMIT_MESSAGE = "chore: update $FILE_NAME file"
}

# Output the extracted commit message and ask user for confirmation
Write-Host "Suggested commit message: $COMMIT_MESSAGE"
$confirm = Read-Host "Do you want to commit with this message? (y/n/e-edit)"

if ($confirm -eq "y") {
    git commit -m "$COMMIT_MESSAGE"
    Write-Host "Successfully committed!"
} elseif ($confirm -eq "e") {
    $new_message = Read-Host "Enter new commit message"
    git commit -m "$new_message"
    Write-Host "Committed with your edited message!"
} else {
    Write-Host "Commit cancelled."
}
