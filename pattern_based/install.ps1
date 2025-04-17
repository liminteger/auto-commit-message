# Install AutoCommit Script
$AutoCommitFolder = "$env:LOCALAPPDATA\AutoCommit"

# 1. AutoCommit 디렉토리 생성
if (-not (Test-Path $AutoCommitFolder)) {
    New-Item -Path $AutoCommitFolder -ItemType Directory
    Write-Host "AutoCommit 폴더가 생성되었습니다." -ForegroundColor Green
} else {
    Write-Host "AutoCommit 폴더가 이미 존재합니다." -ForegroundColor Green
}

# 2. autocommit.ps1 파일 내용 생성
$autocommitScript = @'
# autocommit.ps1 - 자동 커밋 메시지 생성 스크립트

# 1. git diff 명령어로 변경된 파일 추출
$gitDiff = git diff --staged

if (-not $gitDiff) {
    Write-Host "변경 사항이 없습니다." -ForegroundColor Red
    exit
}

# 2. 추가된 코드와 삭제된 코드 추출
$added = $gitDiff | Select-String '^\+.*' | ForEach-Object { $_.Line.TrimStart(' ') }
$removed = $gitDiff | Select-String '^\-.*' | ForEach-Object { $_.Line.TrimStart(' ') }

# 3. 커밋 메시지 생성
$commitMessage = ""

if ($added.Count -gt 0) {
    $commitMessage += "feat: "
    $commitMessage += "Added lines: " + $added.Count + " line(s). "
}

if ($removed.Count -gt 0) {
    $commitMessage += "fix: "
    $commitMessage += "Removed lines: " + $removed.Count + " line(s). "
}

if (-not $commitMessage) {
    $commitMessage = "chore: No changes detected"
}

# 4. 커밋 메시지 출력
Write-Host "Generated Commit Message: $commitMessage"

# 5. 사용자 입력 받기
$commitChoice = Read-Host "자동 커밋 메시지를 생성했습니다. 커밋을 진행하시겠습니까? (y/n/e-edit)"

if ($commitChoice -eq 'y') {
    # 5. 커밋 실행
    git commit -m $commitMessage
    Write-Host "커밋이 완료되었습니다." -ForegroundColor Green
} elseif ($commitChoice -eq 'n') {
    Write-Host "커밋이 취소되었습니다." -ForegroundColor Yellow
} elseif ($commitChoice -eq 'e') {
    # 6. 커밋 메시지 수정
    $newMessage = Read-Host "새로운 커밋 메시지를 입력하세요"
    git commit --amend -m $newMessage
    Write-Host "커밋 메시지가 수정되었습니다." -ForegroundColor Green
} else {
    Write-Host "잘못된 입력입니다. 'y', 'n', 또는 'e'만 입력하세요." -ForegroundColor Red
}
'@

# autocommit.ps1 파일 생성
$autocommitPath = "$AutoCommitFolder\autocommit.ps1"
Set-Content -Path $autocommitPath -Value $autocommitScript -Force
Write-Host "autocommit.ps1 파일이 생성되었습니다." -ForegroundColor Green

# 3. autocommit.bat 파일 생성
$batScript = @'
@echo off
PowerShell -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\AutoCommit\autocommit.ps1"
'@
$batFilePath = "$AutoCommitFolder\autocommit.bat"
Set-Content -Path $batFilePath -Value $batScript -Force
Write-Host "autocommit.bat 파일이 생성되었습니다." -ForegroundColor Green

# 4. 시스템 환경에 AutoCommit 폴더 추가 (PowerShell에서 global command로 사용 가능)
$envPath = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)

if (-not ($envPath -contains $AutoCommitFolder)) {
    [System.Environment]::SetEnvironmentVariable("PATH", "$envPath;$AutoCommitFolder", [System.EnvironmentVariableTarget]::User)
    Write-Host "PATH 환경 변수에 AutoCommit 폴더가 추가되었습니다." -ForegroundColor Green
} else {
    Write-Host "이미 PATH에 AutoCommit 폴더가 포함되어 있습니다." -ForegroundColor Green
}

## 5. PowerShell 명령어로 'autocommit' 명령어 인식하도록 등록
#$profilePath = [System.Environment]::GetEnvironmentVariable("USERPROFILE", [System.EnvironmentVariableTarget]::User) + "\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
#
#if (Test-Path $profilePath) {
#    Add-Content -Path $profilePath -Value "`n# AutoCommit 명령어 설정"
#    Add-Content -Path $profilePath -Value "`nSet-Alias -Name autocommit -Value `"$AutoCommitFolder\autocommit.bat`""
#    Write-Host "'autocommit' 명령어가 PowerShell 프로필에 추가되었습니다." -ForegroundColor Green
#} else {
#    Write-Host "PowerShell 프로필 파일이 존재하지 않습니다. 'autocommit' 명령어를 수동으로 추가하세요." -ForegroundColor Yellow
#}

Write-Host "설치가 완료되었습니다. 이제 PowerShell에서 'autocommit' 명령어를 사용할 수 있습니다." -ForegroundColor Green
