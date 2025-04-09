#!/bin/bash

# 현재 디렉토리 확인
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 기본 설정 파일 경로
CONFIG_DIR="$HOME/.config/autocommit"
CONFIG_FILE="$CONFIG_DIR/config.sh"

# 설정 디렉토리 생성
mkdir -p "$CONFIG_DIR"

# 사용 가능한 모델 목록 가져오기
echo "Ollama에서 사용 가능한 모델을 확인 중..."
MODELS=$(ollama list 2>/dev/null | awk 'NR>1 {print $1}')

if [ -z "$MODELS" ]; then
    echo "경고: Ollama가 실행 중이 아니거나 설치되지 않았습니다."
    MODELS="llama3 phi3 mistral"
fi

# 설정 파일 생성
create_config() {
    cat > "$CONFIG_FILE" << EOF
#!/bin/bash

# AutoCommit 설정 파일

# 사용할 모델
AC_MODEL="$1"

# 언어 설정 (ko 또는 en)
AC_LANGUAGE="$2"

# 프롬프트 파일 경로
AC_PROMPT_FILE="$SCRIPT_DIR/config/prompt_$2.txt"

# 로그 활성화 여부
AC_LOGGING="$3"

# 백업 모드 활성화 여부
AC_FALLBACK_MODE="$4"
EOF

    chmod +x "$CONFIG_FILE"
    echo "설정이 저장되었습니다: $CONFIG_FILE"
}

# 대화형 설정
echo "AutoCommit 고급 설정"
echo "===================="

# 모델 선택
echo "사용 가능한 모델:"
i=1
for model in $MODELS; do
    echo "$i) $model"
    i=$((i+1))
done
echo "$i) 직접 입력"

read -p "사용할 모델을 선택하세요 (기본: 1): " model_choice
model_choice=${model_choice:-1}

if [ "$model_choice" -eq "$i" ]; then
    read -p "모델 이름을 입력하세요: " selected_model
else
    selected_model=$(echo "$MODELS" | awk '{print $1}' | sed -n "${model_choice}p")
    if [ -z "$selected_model" ]; then
        selected_model="llama3"
        echo "유효하지 않은 선택입니다. 기본값 'llama3'를 사용합니다."
    fi
fi

# 언어 선택
echo "언어 선택:"
echo "1) 한국어"
echo "2) 영어"
read -p "선호하는 언어를 선택하세요 (기본: 1): " lang_choice
lang_choice=${lang_choice:-1}

if [ "$lang_choice" -eq 1 ]; then
    selected_lang="ko"
else
    selected_lang="en"
fi

# 로깅 옵션
read -p "디버깅 로그를 활성화하시겠습니까? (y/n, 기본: n): " enable_logs
enable_logs=${enable_logs:-n}

if [ "$enable_logs" = "y" ]; then
    log_setting="true"
else
    log_setting="false"
fi

# 백업 모드 옵션
read -p "LLM 호출 실패 시 패턴 매칭 백업 모드를 사용하시겠습니까? (y/n, 기본: y): " fallback_mode
fallback_mode=${fallback_mode:-y}

if [ "$fallback_mode" = "y" ]; then
    fallback_setting="true"
else
    fallback_setting="false"
fi

# 설정 저장
create_config "$selected_model" "$selected_lang" "$log_setting" "$fallback_setting"

# autocommit 스크립트 업데이트
echo "설정을 적용하기 위해 autocommit 스크립트를 업데이트합니다..."
sed -i.bak "s/MODEL=\"llama3\"/MODEL=\"\$AC_MODEL\"/g" "$SCRIPT_DIR/autocommit" 2>/dev/null || sed -i '' "s/MODEL=\"llama3\"/MODEL=\"\$AC_MODEL\"/g" "$SCRIPT_DIR/autocommit"

# 완료 메시지
echo "설정이 완료되었습니다!"
echo "사용 모델: $selected_model"
echo "언어: $selected_lang"
echo "로깅: $log_setting"
echo "백업 모드: $fallback_setting"
echo ""
echo "autocommit 명령을 실행하여 사용하세요."