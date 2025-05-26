# AutoCommit

자동으로 Git 커밋 메시지를 생성해주는 CLI 도구입니다. `git diff`를 분석하여 문맥에 맞는 커밋 메시지를 생성하며, Conventional Commits 형식을 준수합니다. 

AutoCommit is a CLI tool that automatically generates Git commit messages by analyzing `git diff`, following the Conventional Commits format.

---

## 🔧 주요 기능 | Key Features

- 다양한 방식의 커밋 메시지 생성 | Multiple commit generation modes:

  - **패턴 매칭**: LLM 없이도 기본적인 패턴 분석을 통해 메시지 생성  
    Simple pattern-based message generation without LLM
  - **Gemini**: Google의 Gemini API 활용 (API 키 필요)  
    Uses Gemini API (requires API key)
  - **Ollama**: Ollama LLM과 FastAPI를 연동하여 **git diff**를 분석하고 문맥에 맞는 커밋 메시지 자동 생성  
    Integrates Ollama LLM with FastAPI to analyze **git diff** and automatically generate commit messages based on context

- Git diff 내용의 분석 및 이해 | Understands and analyzes `git diff`
- 간편한 설치 및 사용 | Easy to install and use
- 다양한 운영체제 지원 (Linux, macOS, Windows/WSL 권장) | Cross-platform support (Linux, macOS, Windows via WSL)
- 커밋 메시지 편집 가능 | Optionally edit messages before committing

---

## 📦 설치 방법 | Installation

설치 방법 및 사용법은 각 서브 디렉토리(pattern_based, gemini, ollama) 내 README.md 파일에 각각 상세히 정리되어 있습니다.
Please refer to the README.md files in each subdirectory (pattern_based, gemini, ollama) for detailed installation instructions and usage.

---

## 📁 디렉토리 구조 | Project Structure
- **pattern_based/**: 패턴 기반 커밋 메시지 생성기  
  Pattern-based commit message generator
  
- **gemini/**: Gemini API 기반 커밋 메시지 생성기  
  Commit message generator using Google Gemini API
- **ollama/**: Ollama LLM과 FastAPI를 연동한 커밋 메시지 생성기  
  An API server integrating Ollama LLM with FastAPI to generate commit messages based on Git diff in the Conventional Commits format

---

## 🤝 기여하기 | Contributing

오픈소스 기여는 어렵지 않아요! 오타 수정부터 기능 개선까지, 모든 기여를 환영합니다.  
Contributions of all sizes are welcome — from fixing typos to adding new features.

### 🪜 기여 절차 | How to Contribute

1. 저장소 Fork | Fork the repository
2. 브랜치 생성 후 수정 | Create a branch and make your changes
3. Pull Request 생성 | Open a Pull Request

🔎 [Issues](https://github.com/liminteger/auto-commit-message/issues) 탭에서 `good first issue` 라벨이 붙은 이슈를 확인해보세요!  
Check out [`good first issue`](https://github.com/liminteger/auto-commit-message/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) for beginner-friendly tasks.

### 💡 기여 아이디어 | Ideas to Contribute

- Gemini/Ollama 성능 비교 기능 추가   
  Add Gemini/Ollama performance comparison feature

- Conventional Commits 타입 자동 추론   
  Auto-detection of Conventional Commits types

- 커밋 메시지 다국어 지원 (한국어 ↔ 영어)   
  Multilingual support for commit messages (Korean ↔ English)

- Git hook 자동 연동 기능   
  Automatic Git hook integration

- GUI 버전 개발 (Electron, Web 기반)   
  GUI version development (Electron, Web-based)

- 문서 개선 및 번역   
  Documentation improvement and translation

---

## 📢 블로그 | Blog

자세한 설명과 기여 가이드는 블로그 포스트를 참고하세요   
For detailed explanations and contribution guides, please refer to the blog post  
[liminteger](https://liminteger.github.io/blog/posts/contribute-to-auto-commit-message)

---

## 📄 라이선스 | License

MIT License

