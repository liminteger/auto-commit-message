#!/bin/bash

# 설치 스크립트 for autocommit

# 변수 정의
INSTALL_DIR="/usr/local/bin"
AUTOCOMMIT_BIN="$INSTALL_DIR/autocommit-ollama"
AUTOCOMMIT_SRC="autocommit-ollama.sh"
API_URL="https://466e-39-116-133-230.ngrok-free.app/generate-commit-message"  # 서버 URL로 변경
# DEFAULT_API_KEY="your-api-key"  # 기본값, 사용자 입력으로 대체 가능
SHELL_RC="$HOME/.zshrc"  # Zsh 기본값

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 에러 처리 함수
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# 디버그 로그 함수
log() {
    echo "[DEBUG] $1"
}

# 설치 시작
echo "Installing autocommit..."

# 1. 의존성 확인 및 설치
log "Checking dependencies..."

# jq 확인
if ! command -v jq &> /dev/null; then
    log "jq not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq || error_exit "Failed to install jq via Homebrew"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq || error_exit "Failed to install jq"
    else
        error_exit "Unsupported OS. Please install jq manually."
    fi
fi

# curl 확인
if ! command -v curl &> /dev/null; then
    log "curl not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install curl || error_exit "Failed to install curl via Homebrew"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y curl || error_exit "Failed to install curl"
    else
        error_exit "Unsupported OS. Please install curl manually."
    fi
fi

# 2. autocommit.sh 확인
log "Checking for $AUTOCOMMIT_SRC..."
if [[ ! -f "$AUTOCOMMIT_SRC" ]]; then
    error_exit "$AUTOCOMMIT_SRC not found in current directory"
fi

# 3. autocommit 설치
log "Installing autocommit to $INSTALL_DIR..."
sudo cp "$AUTOCOMMIT_SRC" "$AUTOCOMMIT_BIN" || error_exit "Failed to copy autocommit to $INSTALL_DIR"
sudo chmod +x "$AUTOCOMMIT_BIN" || error_exit "Failed to set executable permissions"

# 4. 환경 변수 설정
log "Setting up environment variables..."

# 쉘 확인
if [[ -n "$ZSH_VERSION" ]]; then
    SHELL_RC="$HOME/.zshrc"
    log "Detected Zsh. Using $SHELL_RC"
elif [[ -n "$BASH_VERSION" ]]; then
    SHELL_RC="$HOME/.bashrc"
    log "Detected Bash. Using $SHELL_RC"
else
    echo "Unknown shell. Using ~/.bashrc as default."
fi

# API 키 입력 요청
# read -p "Enter your API key (or press Enter to use default: $DEFAULT_API_KEY): " USER_API_KEY
# API_KEY=${USER_API_KEY:-$DEFAULT_API_KEY}

# 환경 변수 추가
if ! grep -q "AUTOCOMMIT_API_KEY" "$SHELL_RC"; then
    log "Adding environment variables to $SHELL_RC..."
    {
        echo ""
        echo "# autocommit environment variables"
        # echo "export AUTOCOMMIT_API_KEY=\"$API_KEY\""
        echo "export AUTOCOMMIT_API_URL=\"$API_URL\""
    } >> "$SHELL_RC" || error_exit "Failed to write to $SHELL_RC"
else
    log "Environment variables already exist in $SHELL_RC. Skipping..."
fi

# 5. Bash 설정 테스트
log "Testing Bash configuration..."
if ! bash -n "$SHELL_RC" &> /dev/null; then
    error_exit "Syntax error in $SHELL_RC. Please check the file and fix any issues."
fi

# 6. 설치 완료 및 사용법 안내
echo -e "${GREEN}Installation complete!${NC}"
echo
echo "To use autocommit:"
echo "1. Stage your changes:"
echo "   git add ."
echo "2. Run autocommit:"
echo "   autocommit"
echo "3. Follow the prompts to commit."
echo
echo "Please reload your shell to apply changes:"
echo "   source $SHELL_RC"
echo "or open a new terminal session."

exit 0