# Windows용 AutoCommit 설치 가이드

이 문서는 Windows 환경에서 AutoCommit을 설치하고 사용하는 방법을 설명합니다.

## 시스템 요구사항

- Windows 10 이상
- PowerShell 5.1 이상
- Git 설치
- [Ollama](https://ollama.ai) 설치 (선택사항, LLM 기능 사용 시 필요)

## 설치 방법

### 자동 설치

1. PowerShell을 관리자 권한으로 실행합니다.

2. 실행 정책을 변경합니다 (필요한 경우):
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. 설치 스크립트를 실행합니다:
   ```powershell
   .\install.ps1
   ```

4. 새 터미널 창을 열고 `autocommit` 명령을 테스트합니다.

### 수동 설치

1. `autocommit.ps1` 파일을 원하는 위치에 복사합니다.

2. 다음 함수를 PowerShell 프로필에 추가합니다:
   ```powershell
   function autocommit {
       & "경로\autocommit.ps1"
   }
   ```

## Ollama 설정

Windows에서 Ollama를 사용하는 방법:

1. [Ollama 웹사이트](https://ollama.ai)에서 Windows용 Ollama를 다운로드하고 설치합니다.

2. 모델을 설치합니다:
   ```
   ollama pull llama3
   ```

3. Ollama 서비스가 실행 중인지 확인합니다:
   ```
   curl http://localhost:11434/api/tags
   ```

## WSL(Windows Subsystem for Linux)에서 사용

WSL을 사용하는 경우 리눅스 버전의 스크립트를 그대로 사용할 수 있습니다:

1. WSL을 설치하고 Ubuntu와 같은 배포판을 설정합니다.

2. WSL 터미널에서 리눅스용 설치 스크립트를 실행합니다:
   ```bash
   ./install.sh
   ```

## 문제 해결

- **"Ollama 서비스를 찾을 수 없습니다" 오류:**
  Ollama가 설치되어 있고 실행 중인지 확인하세요.

- **"ExecutionPolicy" 관련 오류:**
  ```powershell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

- **커밋 메시지가 생성되지 않음:**
  Ollama 서비스가 실행 중인지 확인하고, 패턴 매칭 기반 백업 방식이 작동하는지 확인하세요.
