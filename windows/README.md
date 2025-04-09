# Windows Installation Guide for AutoCommit

This document explains how to install and use AutoCommit in a Windows environment.

## System Requirements

- Windows 10 or higher
- PowerShell 5.1 or higher
- Git installation

## Installation Methods

### Automatic Installation

1. Run PowerShell as Administrator.

2. Change execution policy if needed:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. Run the installation script:
   ```powershell
   .\install.ps1
   ```

4. Open a new terminal window and test the `autocommit` command.

### Manual Installation

1. Copy the `autocommit.ps1` file to your desired location.

2. Add the following function to your PowerShell profile:
   ```powershell
   function autocommit {
       & "PATH\autocommit.ps1"
   }
   ```

## Using with WSL (Windows Subsystem for Linux)

If you're using WSL, you can use the Linux version of the script:

1. Install and set up WSL with a distribution like Ubuntu.

2. Run the Linux installation script in the WSL terminal:
   ```bash
   ./install.sh
   ```

## Troubleshooting

- **ExecutionPolicy related errors:**
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

- **Command not found after installation:**
  Open a new terminal window for PATH changes to take effect.
