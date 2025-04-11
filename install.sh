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


echo "설치가 완료되었습니다. 'autocommit' 명령으로 실행할 수 있습니다."