import logging
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
import ollama

app = FastAPI()

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

class DiffRequest(BaseModel):
    diff: str

# 모델별 프롬프트 템플릿
DEFAULT_PROMPT_TEMPLATE = (
    "Generate a git commit message in the Conventional Commits format, in {language_name}, based on the following diff:\n\n"
    "{diff_content}\n\n"
    "The format must be: <type>(<scope>): <description>\n"
    "Where:\n"
    "- type: one of feat, fix, docs, style, refactor, test, chore\n"
    "- scope: a single word describing the module or area affected (e.g., auth, ui)\n"
    "- description: a concise summary of changes (max 50 characters). If {language_name} is English, use lowercase. For other languages, follow standard capitalization rules for that language.\n"
    "Example ({language_name}, if English): feat(auth): add user login functionality\n"
    "Return only the commit message, nothing else."
)

QWEN3_PROMPT_TEMPLATE = (
    "As an expert in version control and software development, analyze the following code changes (diff) and generate a concise git commit message in the Conventional Commits format, in {language_name}:\n\n"
    "```diff\n"
    "{diff_content}\n"
    "```\n\n"
    "The commit message must strictly follow this format: <type>(<scope>): <description>\n"
    "Available types: feat, fix, docs, style, refactor, test, chore.\n"
    "The scope should be a single word identifying the affected area (e.g., api, parser, utils).\n"
    "The description should be a brief summary of the changes, under 50 characters. For {language_name} (if English), use lowercase. Otherwise, use standard capitalization for {language_name}.\n"
    "Example for {language_name} (if English): fix(parser): correct handling of edge cases in input parsing\n"
    "Output only the generated commit message."
)

MODEL_PROMPTS = {
    "llama3": DEFAULT_PROMPT_TEMPLATE,
    "qwen3:8b": QWEN3_PROMPT_TEMPLATE,
    # 다른 모델을 위한 프롬프트 추가 가능
}

@app.post("/generate-commit-message")
async def generate_commit_message(
    request: DiffRequest,
    model: str = Query("llama3", description="Ollama model to use for generation"),
    lang: str = Query("ko", description="Language for the commit message (e.g., en, ko, ja)")
):
    logger.info(f"Received request. Model: {model}, Language: {lang}, Diff snippet: {request.diff[:200]}...") # print 대신 logger 사용 및 diff 내용 일부 로깅
    try:
        language_map = {
            "en": "English",
            "ko": "Korean",
            # 필요에 따라 더 많은 언어 추가
        }
        language_name = language_map.get(lang.lower(), "Korean") # 사용자 수정 유지 (기본 한국어)

        # 모델에 따른 프롬프트 선택 (없으면 기본 프롬프트 사용)
        prompt_template = MODEL_PROMPTS.get(model, DEFAULT_PROMPT_TEMPLATE)
        
        prompt = prompt_template.format(language_name=language_name, diff_content=request.diff)

        response = ollama.generate(model=model, prompt=prompt)
        generated_message = response["response"].strip()
        logger.info(f"Generated commit message: {generated_message}")
        return {"commit_message": generated_message}
    except Exception as e:
        logger.error(f"Error generating commit message: {e}", exc_info=True) # 예외 발생 시 에러 로깅
        raise HTTPException(status_code=500, detail=str(e))
