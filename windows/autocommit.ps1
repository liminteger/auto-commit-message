# AutoCommit PowerShell 버전
# Windows 환경에서 git 커밋 메시지를 자동으로 생성합니다.

# 버전 정보
$VERSION = "1.0.0-win"

# 설정 파일 경로
$CONFIG_DIR = "$env:USERPROFILE\.config\autocommit"
$CONFIG_FILE = "$CONFIG_DIR\config.json"

# 설정 로드
function Load-Config {
    if (Test-Path $CONFIG_FILE) {
        $config = Get-Content $CONFIG_FILE | ConvertFrom-Json
        return $config
    } else {
        # 기본 설정
        return @{
            language = "ko"
            model = "llama3"
        }
    }
}

# 설정 초기화
$config = Load-Config

# git diff 정보 가져오기
$GIT_DIFF = git diff --staged

if (-not $GIT_DIFF) {
    Write-Host "스테이징된 변경 사항이 없습니다. git add 명령어로 파일을 스테이징하세요."
    exit 1
}

# 변경된 파일 목록 가져오기
$CHANGED_FILES = git diff --staged --name-only
Write-Host "변경된 파일: $CHANGED_FILES"

# 변경 통계 요약
$DIFF_STAT = (git diff --staged --stat | Select-Object -Last 1)
Write-Host "변경 요약: $DIFF_STAT"

Write-Host "변경 사항을 분석하여 커밋 메시지를 생성 중..."

# 변경된 파일 수 계산
$FILES_COUNT = ($CHANGED_FILES -split "`n").Count

# 파일 유형 확인하여 커밋 메시지 생성
$COMMIT_MESSAGE = ""

# Ollama API 호출 시도
try {
    $PROMPT = "당신은 git 커밋 메시지 생성 전문가입니다. 아래 git diff를 분석하고 매우 간결하고 명확한 커밋 메시지를 생성해 주세요. 
    
    규칙: 
    1. git diff에서 + 기호로 시작하는 줄은 추가된 코드, - 기호로 시작하는 줄은 삭제된 코드입니다. 
    2. 코드 추가와 삭제를 정확히 구분해서 분석하세요. 
    3. 오직 커밋 메시지만 응답으로 제공하세요. 
    4. 'feat:', 'fix:', 'docs:', 'style:', 'refactor:', 'test:', 'chore:' 중 하나로 시작해야 합니다. 
    5. 50자 이내로 작성하세요.
    
    변경된 파일: $CHANGED_FILES
    
    Git 변경사항:
    $GIT_DIFF"

    # Ollama API 호출 (JSON 데이터 생성)
    $JsonData = @{
        model = $config.model
        prompt = $PROMPT
        stream = $false
    } | ConvertTo-Json

    # API 호출
    $Response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $JsonData -ContentType "application/json" -TimeoutSec 30

    # 응답에서 커밋 메시지 추출
    if ($Response.response) {
        $COMMIT_MESSAGE = $Response.response
        # 불필요한 텍스트 제거
        $COMMIT_MESSAGE = $COMMIT_MESSAGE -replace "^커밋 메시지:\s*", "" -replace "^```", "" -replace "```$", ""
        $COMMIT_MESSAGE = $COMMIT_MESSAGE.Trim()
    }
}
catch {
    Write-Host "Ollama API 호출에 실패했습니다. 패턴 매칭 기반 커밋 메시지를 생성합니다."
    # API 호출 실패 - 로그 출력
    Write-Host "에러: $_"
}

# API 호출이 실패했거나 응답이 비어있을 경우 패턴 매칭 사용
if ([string]::IsNullOrEmpty($COMMIT_MESSAGE)) {
    # 파일 유형에 따른 패턴 매칭
    if ($CHANGED_FILES -match "\.md$") {
        if ($CHANGED_FILES -match "README.md") {
            $COMMIT_MESSAGE = "docs: README 문서 업데이트"
        } else {
            $COMMIT_MESSAGE = "docs: 문서 업데이트"
        }
    } elseif ($CHANGED_FILES -match "LICENSE$") {
        $COMMIT_MESSAGE = "chore: 라이센스 파일 추가"
    } elseif ($CHANGED_FILES -match "\.ps1$|\.bat$|\.cmd$") {
        $COMMIT_MESSAGE = "feat: 스크립트 파일 업데이트"
    } elseif ($FILES_COUNT -gt 5) {
        $COMMIT_MESSAGE = "feat: 여러 파일 추가 및 업데이트"
    } elseif ($GIT_DIFF -match "app\.get") {
        # 라우트 관련 변경
        if ($GIT_DIFF -match "\+.*app\.get") {
            $routeMatch = [regex]::Match($GIT_DIFF, "app\.get.*[\'\"](/[^\'\"]*)[\'\"']")
            if ($routeMatch.Success) {
                $ROUTE = $routeMatch.Groups[1].Value
                $COMMIT_MESSAGE = "feat: $ROUTE 엔드포인트 추가"
            } else {
                $COMMIT_MESSAGE = "feat: 새 API 엔드포인트 추가"
            }
        } else {
            $COMMIT_MESSAGE = "refactor: API 엔드포인트 수정"
        }
    } elseif ($CHANGED_FILES -match "\.js$") {
        $COMMIT_MESSAGE = "feat: JavaScript 코드 업데이트"
    } elseif ($CHANGED_FILES -match "\.css$|\.scss$") {
        $COMMIT_MESSAGE = "style: 스타일 파일 수정"
    } elseif ($CHANGED_FILES -match "\.html$") {
        $COMMIT_MESSAGE = "feat: HTML 템플릿 수정"
    } else {
        # 기본 메시지
        $FILE_NAME = (($CHANGED_FILES -split "`n")[0] -split "/")[-1]
        $COMMIT_MESSAGE = "chore: $FILE_NAME 파일 업데이트"
    }
}

# 추출된 커밋 메시지를 출력하고 사용자에게 확인을 요청합니다
Write-Host "제안된 커밋 메시지: $COMMIT_MESSAGE"
$confirm = Read-Host "이 메시지로 커밋하시겠습니까? (y/n/e-편집)"

if ($confirm -eq "y") {
    git commit -m "$COMMIT_MESSAGE"
    Write-Host "성공적으로 커밋되었습니다!"
} elseif ($confirm -eq "e") {
    $new_message = Read-Host "새 커밋 메시지를 입력하세요"
    git commit -m "$new_message"
    Write-Host "입력하신 메시지로 커밋되었습니다!"
} else {
    Write-Host "커밋이 취소되었습니다."
}
