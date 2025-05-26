from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import ollama

app = FastAPI()

class DiffRequest(BaseModel):
    diff: str

@app.post("/generate-commit-message")
async def generate_commit_message(request: DiffRequest):
    print(request)
    try:
        prompt = (
            "Generate a git commit message in the Conventional Commits format based on the following diff:\n\n"
            f"{request.diff}\n\n"
            "The format must be: <type>(<scope>): <description>\n"
            "Where:\n"
            "- type: one of feat, fix, docs, style, refactor, test, chore\n"
            "- scope: a single word describing the module or area affected (e.g., auth, ui)\n"
            "- description: a concise summary of changes (max 50 characters, lowercase)\n"
            "Example: feat(auth): add user login functionality\n"
            "Return only the commit message, nothing else."
        )
        response = ollama.generate(model="llama3", prompt=prompt)
        return {"commit_message": response["response"].strip()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))