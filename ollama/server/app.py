import logging
import re
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
    "Follow these steps to generate a git commit message in the Conventional Commits format, in {language_name}, based on the provided diff. I will give you an example first.\n\n"
    "--- Example 1 Begin ---\n"
    "Diff:\n"
    "```diff\n"
    "--- a/src/utils.py\n"
    "+++ b/src/utils.py\n"
    "@@ -10,3 +10,6 @@\n"
    " def get_user_data(user_id):\n"
    "     # ... fetch user data\n"
    "     return data\n"
    "+\n"
    "+def is_admin(user_id):\n"
    "+    return user_id == 0 # Simplified admin check\n"
    "```\n\n"
    "Step 1: Analyze the Diff.\n"
    "The diff adds a new function `is_admin` to `utils.py`. This function checks if a `user_id` corresponds to an admin (ID 0).\n\n"
    "Step 2: Determine Commit Message Components.\n"
    "  a. <type>: `feat` (a new function is added, which is a new feature for checking admin status).\n"
    "  b. <scope>: `utils` (the change is in `utils.py`, which is a utility module).\n"
    "  c. <description> (for English): `add is_admin function for admin checks` (Concise summary of the new feature).\n\n"
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
    "  a. <type>: [Your chosen type]\n"
    "  b. <scope>: [Your chosen scope or omit]\n"
    "  c. <description> (for {language_name}): [Your description, following language rules for capitalization and length]\n\n"
    "Step 3: Construct the Commit Message.\n"
    "[Your constructed commit message]\n\n"
    "Step 4: Final Output.\n"
    "YOUR FINAL RESPONSE MUST BE ONLY THE COMMIT MESSAGE CONSTRUCTED IN STEP 3. DO NOT INCLUDE ANY OTHER TEXT, EXPLANATIONS, OR PREAMBLES."
)

QWEN3_PROMPT_TEMPLATE = (
    "You are an expert in version control and software development. Your task is to meticulously analyze the code changes (diff) and generate a concise git commit message in the Conventional Commits format, in {language_name}. Follow the Chain-of-Thought process demonstrated in the example below.\n\n"
    "--- Example Analysis (for a hypothetical diff) ---\n"
    "Hypothetical Diff Content (illustrative):\n"
    "```diff\n"
    "--- a/src/authentication.py\n"
    "+++ b/src/authentication.py\n"
    "@@ -50,7 +50,7 @@\n"
    " class AuthService:\n"
    "     def login(self, username, password):\n"
    "         # ... existing login logic ...\n"
    "-        if not user.is_active:\n"
    "+        if not user.is_active or user.is_locked:\n"
    "             raise AuthenticationError(\"User account is inactive or locked.\")\n"
    "         # ... rest of the logic ...\n"
    "```\n\n"
    "1.  **Understand the Changes**:\n"
    "    *   The diff modifies the login logic in `AuthService` within `authentication.py`.\n"
    "    *   Primary intent: It enhances security by adding a check for locked accounts in addition to inactive accounts during login.\n"
    "    *   Significant modification: The conditional statement for raising an `AuthenticationError` is expanded.\n\n"
    "2.  **Identify Conventional Commit Components**:\n"
    "    *   **Type**: `fix` (It's correcting a potential security loophole or improving an existing login feature's robustness, which can be seen as a fix or a security enhancement classified as a fix).\n"
    "    *   **Scope**: `auth` (The change is within the `authentication.py` module, clearly related to authentication).\n"
    "    *   **Description** (for English): `prevent login for locked accounts` (Summarizes the change concisely).\n\n"
    "3.  **Formulate the Commit Message**:\n"
    "    *   `fix(auth): prevent login for locked accounts`\n\n"
    "4.  **Provide the Output**:\n"
    "    *   YOUR FINAL RESPONSE MUST BE ONLY THE FULLY FORMATTED COMMIT MESSAGE FROM STEP 3. DO NOT INCLUDE ANY OTHER TEXT, EXPLANATIONS, OR MARKDOWN FORMATTING."
)

MODEL_PROMPTS = {
    "llama3": DEFAULT_PROMPT_TEMPLATE,
    "qwen3:8b": QWEN3_PROMPT_TEMPLATE,
    # 다른 모델을 위한 프롬프트 추가 가능
}

def extract_commit_message(response_text: str) -> str:
    """
    Extract only the valid Conventional Commit message from possibly verbose model output.
    """
    pattern = re.compile(
        r"^(feat|fix|docs|style|refactor|test|chore)(\([^\n\r()]+\))?:\s+.{5,80}",
        re.IGNORECASE
    )
    for line in response_text.splitlines():
        line = line.strip()
        if pattern.match(line):
            return line
    # fallback: try to extract from the last paragraph
    lines = response_text.strip().splitlines()
    return lines[-1]


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
        generated_message = extract_commit_message(response["response"].strip())
        logger.info(f"Generated commit message: {generated_message}")
        return {"commit_message": generated_message}
    except Exception as e:
        logger.error(f"Error generating commit message: {e}", exc_info=True) # 예외 발생 시 에러 로깅
        raise HTTPException(status_code=500, detail=str(e))
