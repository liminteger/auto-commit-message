# AutoCommit 윈도우 설치 스크립트

# 설정 디렉토리 생성
$CONFIG_DIR = "$env:USERPROFILE\.config\autocommit"
if (-not (Test-Path $CONFIG_DIR)) {
    New-Item -ItemType Directory -Path $CONFIG_DIR -Force | Out-Null
    Write-Host "설정 디렉토리를 생성했습니다: $CONFIG_DIR"
}

# 기본 설정 생성
$CONFIG_FILE = "$CONFIG_DIR\config.json"
if (-not (Test-Path $CONFIG_FILE)) {
    @{
        language = "ko"
        model = "llama3"
    } | ConvertTo-Json | Out-File -FilePath $CONFIG_FILE -Encoding utf8
    Write-Host "기본 설정 파일을 생성했습니다: $CONFIG_FILE"
}

# 윈도우 PATH에 접근할 수 있는 위치에 설치
$INSTALL_DIR = "$env:LOCALAPPDATA\AutoCommit"
if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    Write-Host "설치 디렉토리를 생성했습니다: $INSTALL_DIR"
}

# 현재 스크립트 경로
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# 파일 복사
Copy-Item -Path "$SCRIPT_DIR\autocommit.ps1" -Destination "$INSTALL_DIR\autocommit.ps1" -Force
Write-Host "스크립트를 설치했습니다: $INSTALL_DIR\autocommit.ps1"

# 실행 스크립트 생성
$CMD_SCRIPT = "$INSTALL_DIR\autocommit.cmd"
@"
@echo off
powershell -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\AutoCommit\autocommit.ps1" %*
"@ | Out-File -FilePath $CMD_SCRIPT -Encoding ascii -Force

Write-Host "명령어 래퍼를 생성했습니다: $CMD_SCRIPT"

# PATH 확인 및 추가
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $currentPath.Contains($INSTALL_DIR)) {
    [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$INSTALL_DIR", "User")
    Write-Host "PATH에 설치 디렉토리를 추가했습니다."
    Write-Host "변경사항을 적용하려면 명령 프롬프트 또는 PowerShell을 다시 시작하세요."
} else {
    Write-Host "설치 디렉토리가 이미 PATH에 추가되어 있습니다."
}

# Ollama 설치 확인
$ollamaTest = $null
try {
    $ollamaTest = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 2 -ErrorAction SilentlyContinue
} catch {
    $ollamaTest = $null
}

if ($ollamaTest) {
    Write-Host "Ollama 서비스가 실행 중입니다."
    
    # 모델 확인
    $models = $ollamaTest.models | ForEach-Object { $_.name }
    if ($models -contains "llama3") {
        Write-Host "llama3 모델이 설치되어 있습니다."
    } else {
        Write-Host "llama3 모델이 설치되어 있지 않습니다."
        $installModel = Read-Host "llama3 모델을 설치하시겠습니까? (y/n)"
        if ($installModel -eq "y") {
            Write-Host "Ollama CLI를 통해 모델을 설치하세요:"
            Write-Host "ollama pull llama3"
        }
    }
} else {
    Write-Host "Ollama 서비스를 찾을 수 없습니다."
    Write-Host "Ollama를 설치하려면 https://ollama.ai에 방문하세요."
}

Write-Host ""
Write-Host "설치가 완료되었습니다!"
Write-Host "명령 프롬프트 또는 PowerShell에서 'autocommit' 명령을 사용할 수 있습니다."
Write-Host "주의: 새 터미널 창을 열어야 PATH 변경이 적용됩니다."
