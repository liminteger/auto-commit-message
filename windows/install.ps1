# AutoCommit Windows Installation Script

# Create configuration directory
$CONFIG_DIR = "$env:USERPROFILE\.config\autocommit"
if (-not (Test-Path $CONFIG_DIR)) {
    New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
    Write-Host "Created configuration directory: $CONFIG_DIR"
}

# Create default configuration
$CONFIG_FILE = "$CONFIG_DIR\config.json"
if (-not (Test-Path $CONFIG_FILE)) {
    @{
        language = "ko"
    } | ConvertTo-Json | Out-File -FilePath $CONFIG_FILE -Encoding utf8
    Write-Host "Created default configuration file: $CONFIG_FILE"
}

# Install to accessible location in Windows PATH
$INSTALL_DIR = "$env:LOCALAPPDATA\AutoCommit"
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    Write-Host "Created installation directory: $INSTALL_DIR"
}

# Current script path
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Copy files
Copy-Item -Path "$SCRIPT_DIR\autocommit.ps1" -Destination "$INSTALL_DIR\autocommit.ps1" -Force
Write-Host "Installed script to: $INSTALL_DIR\autocommit.ps1"

# Create command wrapper
$CMD_SCRIPT = "$INSTALL_DIR\autocommit.cmd"
@"
@echo off
powershell -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\AutoCommit\autocommit.ps1" %*
"@ | Out-File -FilePath $CMD_SCRIPT -Encoding ascii -Force

Write-Host "Created command wrapper: $CMD_SCRIPT"

# Check and add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $currentPath.Contains($INSTALL_DIR)) {
    [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$INSTALL_DIR", "User")
    Write-Host "Added installation directory to PATH."
    Write-Host "To apply the changes, restart your command prompt or PowerShell."
} else {
    Write-Host "Installation directory is already in PATH."
}

Write-Host ""
Write-Host "Installation completed!"
Write-Host "You can now use the 'autocommit' command in Command Prompt or PowerShell."
Write-Host "Note: You need to open a new terminal window for PATH changes to take effect."
