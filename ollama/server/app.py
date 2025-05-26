import logging # 로깅 모듈 임포트
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
import ollama

app = FastAPI()

# 로거 설정
logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO) # 기본 로깅 레벨 설정 (필요에 따라 조정)

class DiffRequest(BaseModel):
    diff: str

@app.post("/generate-commit-message")
async def generate_commit_message(
    request: DiffRequest,
    model: str = Query("llama3", description="Ollama model to use for generation"),
    lang: str = Query("en", description="Language for the commit message (e.g., en, ko, ja)")
):
    logger.info(f"Received request. Model: {model}, Language: {lang}, Diff snippet: {request.diff[:200]}...") # print 대신 logger 사용 및 diff 내용 일부 로깅
    try:
        language_map = {
            "en": "English",
            "ko": "Korean",
            # 필요에 따라 더 많은 언어 추가
        }
        language_name = language_map.get(lang.lower(), "Korean") # 지원하지 않는 lang 코드의 경우 기본값 영어 사용

        prompt = (
            f"Generate a git commit message in the Conventional Commits format, in {language_name}, based on the following diff:\n\n"
            f"{request.diff}\n\n"
            "The format must be: <type>(<scope>): <description>\n"
            "Where:\n"
            "- type: one of feat, fix, docs, style, refactor, test, chore\n"
            "- scope: a single word describing the module or area affected (e.g., auth, ui)\n"
            f"- description: a concise summary of changes (max 50 characters). If {language_name} is English, use lowercase. For other languages, follow standard capitalization rules for that language.\n"
            f"Example ({language_name}, if English): feat(auth): add user login functionality\n"
            "Return only the commit message, nothing else."
        )
        response = ollama.generate(model=model, prompt=prompt)
        logger.info(f"Generated commit message: {response['response'].strip()}") # 생성된 메시지도 로깅
        return {"commit_message": response["response"].strip()}
    except Exception as e:
        logger.error(f"Error generating commit message: {e}", exc_info=True) # 예외 발생 시 에러 로깅
        raise HTTPException(status_code=500, detail=str(e))
