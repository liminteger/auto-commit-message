## Ollama-Based Commit Message Generator

Ollama LLM (Large Language Model)과 FastAPI를 연동하여 **git diff**를 분석하고 문맥에 맞는 커밋 메시지를 자동으로 생성하는 API 서버입니다. Conventional Commits 형식을 준수합니다.  
This is an API server that integrates Ollama LLM with FastAPI to analyze **git diff** and automatically generate context-aware commit messages in the Conventional Commits format.

---

## ✨ 주요 기능 | Key Features

- **Ollama 연동**: 로컬 또는 원격 Ollama 인스턴스 활용  
  Integration with local or remote Ollama instances
- **FastAPI 기반 서버**: API 엔드포인트를 통해 커밋 메시지 생성 요청 처리  
  FastAPI-based server to handle commit message generation requests via API endpoints
- **유연한 모델 선택**: `llama3`, `qwen3:8b` 등 다양한 Ollama 모델 지원 (기본: `llama3`)  
  Flexible model selection, supporting various Ollama models like `llama3`, `qwen3:8b` (default: `llama3`)
- **다국어 지원**: 커밋 메시지 생성 언어 선택 가능 (예: `ko`, `en`)  
  Multilingual support: choose the language for generated commit messages (e.g., `ko`, `en`)
- **Conventional Commits**: 표준화된 커밋 메시지 형식 준수  
  Adherence to the Conventional Commits standard

---

## 📦 구성 파일 | Files

- **app.py**: FastAPI 애플리케이션 로직 (Ollama 연동, 프롬프트 처리, API 엔드포인트)  
  FastAPI application logic (Ollama integration, prompt handling, API endpoints)
- **requirements.txt**: Python 패키지 의존성 목록  
  List of Python package dependencies

---

## 🚀 시작하기 | Getting Started

### 1. 사전 준비 사항 | Prerequisites

- **Python 3.8 이상** 설치  
  Python 3.8 or higher installed
- **Ollama 설치 및 실행**: [Ollama 공식 웹사이트](https://ollama.com/) 참조  
  Ollama installed and running: refer to the [Ollama official website](https://ollama.com/)

### 2. Ollama 모델 다운로드 | Download Ollama Models

서버에서 사용할 Ollama 모델을 미리 다운로드합니다. 기본적으로 `llama3` 모델을 사용하지만, 다른 모델도 사용할 수 있습니다.  
Download the Ollama models you intend to use with the server. By default, it uses the `llama3` model, but others can be used.

```bash
ollama pull llama3
ollama pull qwen3:8b # 예시: 다른 모델 사용 시
```

### 3. 설치 | Installation

#### 가상 환경 설정 (권장) | Setting up a Virtual Environment (Recommended)

```bash
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate  # Windows
```

#### 의존성 설치 | Installing Dependencies

```bash
pip install -r requirements.txt
```

---

## ⚙️ 실행 방법 | How to Run

### 로컬에서 직접 실행 | Running Directly Locally

FastAPI 개발 서버를 사용하여 애플리케이션을 실행합니다.

```bash
uvicorn ollama.server.app:app --reload --host 0.0.0.0 --port 8000
```

- `--reload`: 코드 변경 시 자동 재시작
- `--host 0.0.0.0`: 모든 네트워크 인터페이스에서 접속 허용
- `--port 8000`: 사용할 포트 번호 (기본값)

서버가 실행되면 `http://localhost:8000/docs` 에서 API 문서를 확인할 수 있습니다.

---

## 📖 API 사용법 | API Usage

### `/generate-commit-message` (POST)

Git diff 내용을 받아 Conventional Commit 형식의 메시지를 생성합니다.

**Request Body:**

```json
{
  "diff": "your git diff content here"
}
```

**Query Parameters:**

- `model` (str, optional): 사용할 Ollama 모델 이름. 기본값: `llama3`. (예: `qwen3:8b`)
- `lang` (str, optional): 생성될 커밋 메시지의 언어. 기본값: `ko`. (예: `en`, `ja`)

**Example Request (curl):**

```bash
curl -X POST "http://localhost:8000/generate-commit-message?model=llama3&lang=ko" \
     -H "Content-Type: application/json" \
     -d '{
       "diff": "--- a/test.txt\n+++ b/test.txt\n@@ -1 +1 @@\n-hello\n+hello world"
     }'
```

**Example Response:**

```json
{
  "commit_message": "feat(test): add world to hello"
}
```

---

## 🛠️ 기여 방법 | How to Contribute

이 프로젝트에 기여하고 싶으시면, [Pull Request](https://github.com/liminteger/auto-commit-message/pulls)를 보내주세요.  
If you'd like to contribute to this project, feel free to send a [Pull Request](https://github.com/liminteger/auto-commit-message/pulls).

### 아이디어 | Ideas

- 특정 파일 변경에 대한 커밋 메시지 생성 규칙 추가
- 다양한 LLM 모델 지원 확대
- 프롬프트 엔지니어링 개선을 통한 메시지 품질 향상

---

## 📞 문제나 질문이 있다면 | Issues or Questions

문제나 질문이 있으면 [이슈 페이지](https://github.com/liminteger/auto-commit-message/issues)에서 알려주세요.  
If you encounter any issues or have questions, feel free to raise them on the [Issues page](https://github.com/liminteger/auto-commit-message/issues).

---

## 📄 라이선스 | License

이 프로젝트는 MIT 라이선스를 따릅니다.  
This project is licensed under the MIT License.
