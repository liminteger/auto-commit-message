# AutoCommit

Git diff를 분석하여 자동으로 커밋 메시지를 생성하는 CLI 도구입니다.

## 개요

AutoCommit은 `git diff`의 내용을 분석하여 LLM(Large Language Model)을 사용하여 문맥에 맞는 커밋 메시지를 자동으로 생성합니다. Conventional Commits 형식을 준수합니다.

## 현재 구현 상태

다음 세 가지 버전으로 구현되어 있습니다:

- **Ollama**: 로컬에서 실행되는 Ollama 기반 LLM 활용 (기본 모델: llama3)
- **Gemini**: Google의 Gemini API 활용 (API 키 필요)
- **패턴 매칭**: LLM 없이도 기본적인 패턴 분석을 통해 커밋 메시지 생성 가능

## 특징

- 🧠 **다양한 LLM 지원**:
  - Ollama 기반 로컬 LLM (기본 모델: llama3, 변경 가능)
  - Google Gemini API 활용
  - 패턴 매칭 기반 단순 분석 (LLM 없이 동작)
- 📝 Conventional Commits 형식 준수
- 🔍 Git diff 내용의 깊이 있는 분석 및 이해
- 🚀 간편한 설치 및 사용
- 💻 다양한 운영체제 지원 (Linux, macOS, Windows(**WSL** 사용 권장))
- ⚙️ 사용자의 필요에 따른 커밋 메시지 편집 옵션

## 설치 요구사항

### 공통
- Git

### Linux/macOS
- Bash 쉘
- `curl`
- `jq`
- `netcat` (`nc`) - Ollama 버전 사용 시 필요

### 버전별 추가 요구사항
- **Ollama 버전**: Ollama ([https://ollama.ai/](https://ollama.ai/)) 설치 및 실행
- **Gemini 버전**: Google Gemini API 키 필요

### Windows
- Git for Windows (기본 포함)
- Windows Subsystem for Linux (WSL) 권장 (Linux 버전 스크립트 사용)
- 또는 아래 명시된 Windows용 도구 설치 (WSL 미사용 시)

#### Windows (선택 사항 - WSL 미사용 시)
- `curl` (예: Chocolatey 또는 Git for Windows에 포함)
- `jq` (예: Chocolatey 설치: `choco install jq`)
- `netcat` (예: nmap 설치: `choco install nmap`) - Ollama 버전 사용 시 필요

## 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/liminteger/auto-commit-message.git
cd auto-commit-message
```

### Ollama 버전 설치

```bash
cd ollama
chmod +x install-ollama.sh
./install-ollama.sh
```

### Gemini 버전 설치

```bash
cd gemini
chmod +x install-gemini.sh
chmod +x autocommit-gemini.sh
bash ./install-gemini.sh
```

### 패턴 매칭 버전 설치

```bash
cd pattern-matching
chmod +x install.sh
./install.sh
```

### Windows (WSL 사용 권장)

WSL 환경에서는 Linux 설치 방법을 따르십시오.

## 사용 방법

1. 변경 사항을 스테이징합니다:

```bash
git add file1.js file2.js
```

2. 버전에 따라 AutoCommit 실행:

#### Ollama 버전
```bash
autocommit-ollama
```

#### Gemini 버전
```bash
autocommit-gemini
```

#### 패턴 매칭 버전
```bash
autocommit
```

3. 제안된 커밋 메시지를 확인하고 다음 옵션 중 하나를 선택합니다:
   - `y`: 제안된 메시지로 커밋합니다.
   - `n`: 커밋을 취소합니다.
   - `e`: 편집기를 열어 메시지를 직접 수정하고 커밋합니다.

## 환경 설정

### Ollama 버전 설정

#### Ollama 모델 변경

기본적으로 `llama3` 모델이 사용됩니다. 다른 모델을 사용하려면 `OLLAMA_MODEL` 환경 변수를 설정하십시오.

```bash
export OLLAMA_MODEL="gemma3:1b"
autocommit-ollama
```

#### Ollama API URL 변경

Ollama 서버가 기본 포트(11434)가 아닌 다른 포트에서 실행 중인 경우 `OLLAMA_API_URL` 환경 변수를 설정하십시오.

```bash
export OLLAMA_API_URL="http://localhost:8080/api/generate"
autocommit-ollama
```

### Gemini 버전 설정

#### API 키 설정

Gemini API 키는 아래와 같이 환경 변수로 설정해야 합니다!

```bash
export GEMINI_API_KEY="your-api-key-here"
```

## 문제 해결

### Ollama 버전
- **Ollama 서버 연결 오류**: Ollama 서버가 `http://localhost:11434`에서 실행 중인지, 그리고 올바른 모델이 다운로드 및 실행 중인지 확인하십시오.
- **API 호출 오류**: Ollama 서버가 응답하지 않거나 오류를 반환하는 경우 서버 상태 및 모델 존재 여부를 확인하십시오.

### Gemini 버전
- **API 키 오류**: `GEMINI_API_KEY` 환경 변수가 올바르게 설정되어 있는지 확인하십시오.
- **API 호출 한도**: Gemini API는 사용량 제한이 있을 수 있으므로 오류 발생 시 제한 여부를 확인하십시오.

### 패턴 매칭 버전
- 특별한 설치 없이 기본적인 기능을 제공합니다. 다른 문제가 발생하는 경우 스크립트 실행 권한을 확인하십시오.

## 기여 방법

프로젝트 개선에 기여하고 싶으신가요? 여러분의 참여를 환영합니다! PR을 제출해 주세요.

## 라이센스

MIT 라이센스에 따라 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하십시오.
