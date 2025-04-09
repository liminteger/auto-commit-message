# AutoCommit

로컬 LLM(Large Language Model)을 활용하여 자동으로 Git 커밋 메시지를 생성하는 CLI 도구입니다.

## 개요

AutoCommit은 `git diff`의 내용을 분석하고 로컬에서 실행되는 LLM을 활용하여 적절한 커밋 메시지를 자동으로 생성합니다. Conventional Commits 형식을 준수하며, 무료로 사용할 수 있습니다.

## 특징

- 🧠 로컬 LLM을 활용하여 API 비용 없이 무료로 사용
- 📝 Conventional Commits 형식에 맞는 커밋 메시지 생성
- 🔍 파일 변경 패턴 인식을 통한 백업 메커니즘 제공
- 🚀 간단한 설치 및 사용법

## 설치 요구사항

- [Ollama](https://ollama.ai) - 로컬 LLM 실행을 위한 도구
- llama3 모델 (또는 다른 호환 가능한 모델)
- cURL
- Bash 쉘

## 설치 방법

1. 저장소 클론
```bash
git clone https://github.com/yourusername/autocommit.git
cd autocommit
```

2. 실행 권한 부여
```bash
chmod +x autocommit
```

3. 시스템 경로에 설치
```bash
sudo cp autocommit /usr/local/bin/
```

4. Ollama 및 LLM 모델 설치
```bash
# Ollama 설치 (https://ollama.ai 참조)
# 모델 다운로드
ollama pull llama3
```

## 사용 방법

1. 변경 사항을 스테이징합니다:
```bash
git add file1.js file2.js
```

2. AutoCommit 실행:
```bash
autocommit
```

3. 제안된 커밋 메시지를 확인하고 수락/편집/거부 선택:
   - `y`: 제안된 메시지로 커밋
   - `n`: 커밋 취소
   - `e`: 메시지 직접 편집 후 커밋

## 모델 변경

기본적으로 이 스크립트는 `llama3` 모델을 사용합니다. 다른 모델을 사용하려면 스크립트 내의 `llama3`를 원하는 모델명(예: `phi3`, `mistral` 등)으로 변경하세요.

## 문제 해결

- Ollama가 실행 중인지 확인: `curl http://localhost:11434/api/tags`
- 모델이 설치되어 있는지 확인: `ollama list`
- 모델이 없다면 설치: `ollama pull llama3`

## 기여 방법

기여는 언제나 환영합니다! [CONTRIBUTING.md](CONTRIBUTING.md)를 참조하세요.

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.