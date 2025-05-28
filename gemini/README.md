# 📁 gemini/README.md

---

## Gemini-Based Commit Message Generator

Google의 Gemini API를 활용하여 ***git diff***를 분석하고 문맥에 맞는 커밋 메시지를 생성하는 도구입니다.  
This tool uses Google's Gemini API to analyze ***git diff*** and generate meaningful commit messages.

---

## 📦 구성 파일 | Files

- **install-gemini.sh**:
    설치 스크립트 | Install script
- **autocommit-gemini**:
    실행 파일 | Main executable

---

## ⚙️ 설치 및 사용 방법 | Installation & Usage

1. 설치 | Installation
    ```bash
    chmod +x install-gemini.sh
    ```
    ```bash
    sudo ./install-gemini.sh
    ```

2. Gemini API key 발급 | Getting Gemini API key

   [Google Cloud](https://aistudio.google.com/app/apikey)에서 Gemini API 키를 발급받습니다.  
    Get your Gemini API key from [Google Cloud](https://aistudio.google.com/app/apikey).

3. API key 설정 | setting API key

   환경 변수로 API 키를 설정합니다.
   Set the API key as an environment variable:
    ```bash
    echo 'export GEMINI_API_KEY="your_api_key"' >> ~/.bashrc
    source ~/.bashrc
    ```
   `your_api_key` 자리에는 발급받은 API 키를 큰따옴표로 묶어 붙여넣습니다.
   Replace `your_api_key` with your issued API key, wrapped in double quotes.

   API 키를 확인하려면 다음 코드를 입력합니다. To check the API key, enter the following command.
   ```bash
   echo $GEMINI_API_KEY 
   ```
       
4. autocommit 실행 | execution
    ```bash
    autocommit-gemini
    ```
   - `y`:
    제안된 커밋 메시지로 커밋합니다.  
    Commit with the suggested message.
    - `n`:
    커밋을 취소합니다.  
    Cancel the commit.
    - `e`:
    제안된 커밋 메시지를 수정하여 커밋합니다.  
    Edit the suggested message before committing.

---

## 🎉 축하합니다! | Congratulations!

이제 Google Gemini API를 사용하여 Git 커밋 메시지를 생성하는 도구를 설정하고 사용할 준비가 완료되었습니다.  
You're all set up to start generating Git commit messages with the Google Gemini API!

---

## 🛠️ 기여 방법 | How to Contribute

이 프로젝트에 기여하고 싶으시면, [Pull Request](https://github.com/liminteger/auto-commit-message/pulls)를 보내주세요.  
If you'd like to contribute to this project, feel free to send a [Pull Request](https://github.com/liminteger/auto-commit-message/pulls).

---

## 📞 문제나 질문이 있다면 | Issues or Questions

문제나 질문이 있으면 [이슈 페이지](https://github.com/liminteger/auto-commit-message/issues)에서 알려주세요.  
If you encounter any issues or have questions, feel free to raise them on the [Issues page](https://github.com/liminteger/auto-commit-message/issues).

---

## 📄 라이선스 | License

이 프로젝트는 MIT 라이선스를 따릅니다.  
This project is licensed under the MIT License.
