#!/bin/bash

# 현재 디렉토리 확인
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 실행 권한 부여
chmod +x "$SCRIPT_DIR/autocommit"

# 시스템 경로에 설치
echo "AutoCommit을 시스템 경로에 설치합니다..."

if [ -d "/usr/local/bin" ] && [ -w "/usr/local/bin" ]; then
    cp "$SCRIPT_DIR/autocommit" /usr/local/bin/
    echo "설치 완료: /usr/local/bin/autocommit"
else
    echo "권한 오류: /usr/local/bin 에 쓰기 권한이 없습니다. sudo를 사용해 보세요:"
    echo "sudo cp \"$SCRIPT_DIR/autocommit\" /usr/local/bin/"
    exit 1
fi

# Ollama 설치 확인
echo "Ollama 설치 여부를 확인합니다..."
if command -v ollama >/dev/null 2>&1; then
    echo "Ollama가 설치되어 있습니다."
    
    # LLM 모델 확인
    if ollama list | grep -q "llama3"; then
        echo "llama3 모델이 설치되어 있습니다."
    else
        echo "llama3 모델이 설치되어 있지 않습니다. 설치하시겠습니까? (y/n)"
        read -r install_model
        if [ "$install_model" = "y" ]; then
            echo "llama3 모델을 다운로드합니다. 몇 분 정도 소요될 수 있습니다..."
            ollama pull llama3
        else
            echo "모델을 설치하지 않았습니다. autocommit을 사용하려면 다음 명령으로 모델을 설치하세요:"
            echo "ollama pull llama3"
        fi
    fi
else
    echo "Ollama가 설치되어 있지 않습니다."
    echo "Ollama 설치 방법: https://ollama.ai"
    echo "설치 후 다음 명령으로 필요한 모델을 다운로드하세요:"
    echo "ollama pull llama3"
fi

echo "설치가 완료되었습니다. 'autocommit' 명령으로 실행할 수 있습니다."