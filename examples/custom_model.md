# 커스텀 모델 사용하기

다양한 로컬 LLM 모델을 AutoCommit과 함께 사용하는 방법을 설명합니다.

## 지원되는 모델

Ollama를 통해 다음과 같은 다양한 모델을 사용할 수 있습니다:

- llama3 (기본값)
- phi3:mini
- mistral:7b
- llama2
- stablelm:zephyr
- vicuna:13b
- orca-mini

## 모델 변경 방법

`autocommit` 스크립트를 열고 다음 부분을 수정합니다:

```bash
# Ollama API 호출
RESPONSE=$(curl -s -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"llama3\",\"prompt\":$(cat "$TEMP_FILE"),\"stream\":false}")
```

여기서 `llama3`를 원하는 모델명으로 바꿉니다:

```bash
# Ollama API 호출
RESPONSE=$(curl -s -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"phi3:mini\",\"prompt\":$(cat "$TEMP_FILE"),\"stream\":false}")
```

## 모델 설치

새 모델을 사용하기 전에 먼저 설치해야 합니다:

```bash
ollama pull phi3:mini
```

## 모델별 성능 비교

모델마다 커밋 메시지 품질이 다를 수 있습니다:

- **llama3**: 일반적으로 균형 잡힌 성능, 대부분의 코드 타입에 적합
- **phi3:mini**: 가볍고 빠르지만 컨텍스트 이해력이 다소 떨어짐
- **mistral:7b**: 복잡한 코드 변경에 더 나은 이해도 제공
- **orca-mini**: 매우 빠르고 가벼우나 품질은 다소 떨어질 수 있음

자신의 코딩 스타일과 프로젝트에 맞는 모델을 선택하세요.