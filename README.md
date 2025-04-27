# AutoCommit

자동으로 Git 커밋 메시지를 생성해주는 CLI 도구입니다. `git diff`를 분석하여 문맥에 맞는 커밋 메시지를 생성하며, Conventional Commits 형식을 준수합니다. 

AutoCommit is a CLI tool that automatically generates Git commit messages by analyzing `git diff`, following the Conventional Commits format.

---

## 🔧 주요 기능 | Key Features

- 다양한 방식의 커밋 메시지 생성 | Multiple commit generation modes:
  - **패턴 매칭**:
    LLM 없이도 기본적인 패턴 분석을 통해 메시지 생성  
    Simple pattern-based message generation without LLM
  - **Gemini**:
    Google의 Gemini API 활용 (API 키 필요)  
    Uses Gemini API (requires API key)
  - **Ollama**:
    Ollama LLM과 FastAPI를 연동하여 **git diff**를 분석하고 문맥에 맞는 커밋 메시지 자동 생성  
    Integrates Ollama LLM with FastAPI to analyze **git diff** and automatically generate commit messages based on context

- Git diff 내용의 분석 및 이해 | Understands and analyzes `git diff`
- 간편한 설치 및 사용 | Easy to install and use
- 다양한 운영체제 지원 (Linux, macOS, Windows/WSL 권장) | Cross-platform support (Linux, macOS, Windows via WSL)
- 커밋 메시지 편집 가능 | Optionally edit messages before committing

---

## 📁 디렉토리 구조 | Project Structure

- **pattern_based/**:
    패턴 기반 커밋 메시지 생성기
    Pattern-based commit message generator
- **gemini/**:
    Gemini API 기반 커밋 메시지 생성기  
    Commit message generator using Google Gemini API
- **ollama/**:
    Ollama LLM과 FastAPI를 연동한 커밋 메시지 생성기
    An API server integrating Ollama LLM with FastAPI to generate commit messages based on Git diff in the Conventional Commits format

---

## 📄 라이선스 | License

MIT License
