import logging
import re
import json
import os
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
import ollama

app = FastAPI()

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


# --- 1. 설정 파일 (예: .autocommitrc.json) 구조 정의 ---
# 프로젝트 루트에 .autocommitrc.json 파일을 생성하여 템플릿을 정의합니다.
# 예시 .autocommitrc.json 파일 내용:
# {
#   "commit_template": "feat({scope}): {summary}\n\n{body}\n\nRefs: {issue_refs}",
#   "template_instructions": {
#     "type": "Conventional Commits 사양에 따른 커밋 타입 (예: feat, fix, docs).",
#     "scope": "변경 사항의 범위를 나타내는 선택적 영역입니다 (예: auth, ui, api).",
#     "summary": "변경 사항을 간결하게 요약하는 제목 (50자 이내).",
#     "body": "변경 사항에 대한 더 자세한 설명입니다. 필요시 여러 줄로 작성합니다.",
#     "issue_refs": "관련된 이슈나 참조 (예: #123, Closes #456). 없으면 생략합니다."
#   }
# }
# 커밋 형식을 대략적으로라도 지정하게 할 수 있으면 좋겠다고 생각했습니다.

# --- 2. 설정 파일 로드 함수 ---
# 앱 시작 시 한 번만 로드하도록 전역 변수 또는 FastAPI의 startup 이벤트에서 로드
CONFIG_FILE_PATH = os.path.join(os.getcwd(), '.autocommitrc.json')

def load_config(config_path: str = CONFIG_FILE_PATH) -> dict:
    """
    지정된 경로에서 설정 파일을 로드합니다.
    파일이 없거나 JSON 형식이 올바르지 않으면 기본 설정(빈 딕셔너리)을 반환합니다.
    """
    if os.path.exists(config_path):
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except json.JSONDecodeError:
            logger.warning(f"경고: '{config_path}' 파일의 JSON 형식이 올바르지 않습니다. 사용자 정의 템플릿 없이 진행합니다.")
            return {}
        except Exception as e:
            logger.error(f"오류: '{config_path}' 파일 로딩 중 예기치 않은 오류 발생: {e}. 사용자 정의 템플릿 없이 진행합니다.")
            return {}
    logger.info(f"정보: '{config_path}' 설정 파일을 찾을 수 없습니다. 기본 템플릿을 사용합니다.")
    return {}

# 앱 시작 시 설정 로드
app_config = load_config()

class DiffRequest(BaseModel):
    diff: str

# 모델별 프롬프트 템플릿
# 기존 프롬프트 템플릿은 유지하되, 사용자 정의 템플릿을 통합할 수 있도록 수정합니다.
# {commit_message_template}과 {template_instructions_text} 플레이스홀더를 추가합니다.
BASE_PROMPT_TEMPLATE = (
    "You are an expert in writing high-quality Git commit messages. Create a concise, professional commit message "
    "that strictly follows the Conventional Commits specification, in {language_name}.\n\n"
    "The commit message MUST conform to the following structure:\n"
    "```\n{commit_message_template}\n```\n\n"
    "{template_instructions_text}\n\n"
    "--- Example 1 Begin ---\n"
    "Diff:\n"
    "```diff\n"
    "--- a/src/utils.py\n"
    "+++ b/src/utils.py\n"
    "@@ -10,3 +10,6 @@\n"
    " def get_user_data(user_id):\n"
    "      # ... fetch user data\n"
    "      return data\n"
    "+\n"
    "+def is_admin(user_id):\n"
    "+    return user_id == 0 # Simplified admin check\n"
    "```\n\n"
    "Step 1: Analyze the Diff.\n"
    "The diff adds a new function `is_admin` to `utils.py`. This function checks if a `user_id` corresponds to an admin (ID 0).\n\n"
    "Step 2: Determine Commit Message Components.\n"
    " a. <type>: `feat` (a new function is added, which is a new feature for checking admin status).\n"
    " b. <scope>: `utils` (the change is in `utils.py`, which is a utility module).\n"
    " c. <description> (for English): `add is_admin function for admin checks` (Concise summary of the new feature).\n\n"
    "Step 3: Construct the Commit Message.\n"
    "feat(utils): add is_admin function for admin checks\n\n"
    "Step 4: Final Output.\n"
    "feat(utils): add is_admin function for admin checks\n"
    "--- Example 1 End ---\n\n"
    "Now, apply the same steps to the following diff:\n\n"
    "Diff:\n"
    "{diff_content}\n\n"
    "Step 1: Analyze the Diff.\n"
    "[Your analysis here]\n\n"
    "Step 2: Determine Commit Message Components.\n"
    " a. <type>: [Your chosen type]\n"
    " b. <scope>: [Your chosen scope or omit]\n"
    " c. <description> (for {language_name}): [Your description, following language rules for capitalization and length]\n\n"
    "Step 3: Construct the Commit Message.\n"
    "[Your constructed commit message]\n\n"
    "Step 4: Final Output.\n"
    "YOUR FINAL RESPONSE MUST BE ONLY THE COMMIT MESSAGE CONSTRUCTED IN STEP 3. DO NOT INCLUDE ANY OTHER TEXT, EXPLANATIONS, OR PREAMBLES."
)

# QWEN3_PROMPT_TEMPLATE는 BASE_PROMPT_TEMPLATE와 유사하게 템플릿 정보를 받을 수 있도록 수정하거나
# BASE_PROMPT_TEMPLATE를 모든 모델의 기본으로 사용하도록 단순화할 수 있습니다.
# 여기서는 BASE_PROMPT_TEMPLATE를 사용하도록 통합합니다.
MODEL_PROMPTS = {
    "llama3": BASE_PROMPT_TEMPLATE,
    "qwen3:8b": BASE_PROMPT_TEMPLATE, # Qwen3도 이제 동일한 템플릿 기반 프롬프트를 사용
    # 다른 모델을 위한 프롬프트 추가 가능
}


def generate_template_instructions_text(template: str, custom_instructions: dict) -> str:
    """
    템플릿에서 플레이스홀더를 추출하고 LLM을 위한 지시 텍스트를 생성합니다.
    """
    placeholders = re.findall(r'\{(\w+)\}', template)
    instructions_list = []
    
    # 기본 지시사항 (custom_instructions에 없는 경우를 대비)
    default_instruction_map = {
        "type": "Conventional Commits 사양에 따른 커밋 타입 (예: feat, fix, docs, style, refactor, test, chore).",
        "scope": "변경 사항의 범위를 나타내는 선택적 영역입니다 (예: auth, ui, api, core). 변경 사항이 특정 범위에 국한되지 않으면 생략하세요.",
        "summary": "변경 사항을 간결하게 요약하는 제목 (50자 이내).",
        "body": "변경 사항에 대한 더 자세한 설명입니다. 필요시 여러 줄로 작성합니다. 여러 줄일 경우 각 줄은 72자 이내로 래핑하세요.",
        "issue_refs": "관련된 이슈나 참조 (예: #123, Closes #456). 없으면 생략합니다.",
    }

    if placeholders:
        instructions_list.append("각 플레이스홀더에 대한 지침:")
        for p in sorted(list(set(placeholders))): # 중복 제거 및 정렬
            instruction = custom_instructions.get(p, default_instruction_map.get(p, f"- `{p}`: 이 필드에 적절한 내용을 채우세요."))
            instructions_list.append(f"- `{p}`: {instruction}")
    
    return "\n".join(instructions_list) if instructions_list else ""


def extract_commit_message(response_text: str, commit_template: str) -> str:
    """
    모델 출력에서 최종 커밋 메시지를 추출합니다.
    템플릿 기반 출력은 일반적으로 Step 3 또는 Final Output 이후에 위치합니다.
    """
    # 응답에서 'Final Output' 또는 'Step 3' 이후의 첫 번째 유효한 라인을 찾습니다.
    lines = response_text.strip().splitlines()
    start_parsing = False
    
    # Conventional Commit 패턴을 엄격하게 따르는 정규식 (옵션 스코프 포함)
    conventional_commit_pattern = re.compile(
        r"^(feat|fix|docs|style|refactor|test|chore|build|ci|perf|revert)(\([\w.-]+\))?:\s+.+",
        re.IGNORECASE
    )

    for line in lines:
        stripped_line = line.strip()
        # 프롬프트 예시에 따라 "Final Output." 또는 "Step 3:" 이후의 내용을 찾습니다.
        if "Final Output." in line or "Step 3: " in line:
            start_parsing = True
            continue # 다음 줄부터 실제 메시지를 찾음
        
        if start_parsing:
            # 첫 번째로 Conventional Commit 패턴에 맞는 라인을 찾으면 반환
            if conventional_commit_pattern.match(stripped_line):
                return stripped_line
            # 만약 모델이 템플릿의 일부만 반환했다면, 최대한 맞추도록 시도 (fallback)
            # 이는 LLM의 응답이 항상 완벽하지 않을 수 있기 때문에 필요합니다.
            # 이 로직은 더욱 정교하게 개선될 수 있습니다.
            if stripped_line and not stripped_line.startswith(("[Your", "Step")):
                return stripped_line

    # 그래도 찾지 못했다면 응답의 마지막 유의미한 부분을 반환 시도
    # 예시 프롬프트에 따르면 최종 출력은 항상 마지막에 있으므로 마지막 라인 반환
    final_line = lines[-1].strip()
    if conventional_commit_pattern.match(final_line):
        return final_line
    
    # 마지막 시도로, 템플릿의 플레이스홀더를 제거한 형태로 반환 시도
    # 이는 LLM이 플레이스홀더를 채우지 않고 템플릿만 반환하는 경우를 위한 매우 약한 fallback
    clean_template = re.sub(r'\{(\w+)\}', lambda m: f"<{m.group(1)}>", commit_template)
    if clean_template == final_line: # LLM이 템플릿만 돌려준 경우
        logger.warning(f"LLM이 템플릿을 채우지 않고 반환했습니다. 임시로 플레이스홀더를 채워 반환: {clean_template}")
        return clean_template.replace("<type>", "chore").replace("<summary>", "update files").replace("<scope>", "").strip()

    logger.warning(f"모델 출력에서 유효한 커밋 메시지를 추출할 수 없습니다. 원본 응답의 마지막 부분을 반환합니다: {response_text[:100]}...")
    return response_text.splitlines()[-1].strip() # 최악의 경우 마지막 라인 반환


@app.post("/generate-commit-message")
async def generate_commit_message(
    request: DiffRequest,
    model: str = Query("llama3", description="Ollama model to use for generation"),
    lang: str = Query("ko", description="Language for the commit message (e.g., en, ko, ja)")
):
    logger.info(f"Received request. Model: {model}, Language: {lang}, Diff snippet: {request.diff[:200]}...")
    try:
        language_map = {
            "en": "English",
            "ko": "Korean",
            "ja": "Japanese",
            # 필요에 따라 더 많은 언어 추가
        }
        language_name = language_map.get(lang.lower(), "Korean")

        # 사용자 정의 템플릿 및 지시사항 로드
        custom_commit_template = app_config.get('commit_template')
        custom_template_instructions = app_config.get('template_instructions', {})

        # 사용할 커밋 템플릿 결정
        # Conventional Commits의 기본 구조를 사용하지만, 사용자가 정의한 템플릿이 있다면 그것을 사용
        actual_commit_template = custom_commit_template if custom_commit_template else "feat({scope}): {summary}"

        # 템플릿 지시사항 텍스트 생성
        template_instructions_text = generate_template_instructions_text(
            actual_commit_template, custom_template_instructions
        )

        # 모델에 따른 기본 프롬프트 선택 (없으면 BASE_PROMPT_TEMPLATE 사용)
        prompt_template_base = MODEL_PROMPTS.get(model, BASE_PROMPT_TEMPLATE)

        # 최종 프롬프트 구성
        # 이제 프롬프트에 {commit_message_template}과 {template_instructions_text}를 추가로 포매팅합니다.
        prompt = prompt_template_base.format(
            language_name=language_name,
            diff_content=request.diff,
            commit_message_template=actual_commit_template,
            template_instructions_text=template_instructions_text
        )

        logger.debug(f"Generated prompt:\n{prompt}") # 디버깅을 위해 프롬프트 전체 로깅

        response = ollama.generate(model=model, prompt=prompt)
        
        # Ollama API 응답 구조 확인 및 실제 응답 텍스트 추출
        raw_response_text = response.get("response", "").strip()
        
        generated_message = extract_commit_message(raw_response_text, actual_commit_template)
        
        logger.info(f"Generated commit message: {generated_message}")
        return {"commit_message": generated_message}
    except ollama.ResponseError as e:
        logger.error(f"Ollama API 오류 발생: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Ollama API 오류: {e.error}")
    except Exception as e:
        logger.error(f"커밋 메시지 생성 중 예기치 않은 오류 발생: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"서버 오류: {e}")

