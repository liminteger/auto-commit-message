# Pattern-Based Commit Message Generator

Git diff를 분석하여 기본적인 **패턴 기반 커밋 메시지**를 자동으로 생성하는 도구입니다.  
A lightweight tool that generates **pattern-based commit messages** using Git diff—without relying on LLMs.

---

## 📁 파일 구성 | File Structure


| 파일명 (Filename)   | 설명 (Description)                                          |
|--------------------|-------------------------------------------------------------|
| `install.sh`       | 설치 스크립트 (Linux/MacOS) / Install script for Linux/MacOS  |
| `install.ps1`      | 설치 스크립트 (Windows) / Install script for Windows          |
| `autocommit`       | 실행 파일 (Linux/MacOS) / Execution file for Linux/MacOS      |

---

## ⚙️ 설치 및 사용법 | Installation & Usage

### 🔸 Linux / macOS

1. 설치 | Installation
    ```bash
    chmod +x install.sh
    ```
    ```ㅠㅁ노
    sudo ./install.sh
    ```

2. 실행 | Run
    ```bash
    autocommit
    ```

---

### 🔹 Windows

1. 설치 | Installation
    ```powershell
    powershell -ExecutionPolicy Bypass -File .\install.ps1
    ```

2. 실행 | Run
    ```powershell
    autocommit
    ```

3. 제거 방법 | Uninstallation
    ```powershell
    Remove-Item -Path "$env:LOCALAPPDATA\AutoCommit" -Recurse -Force
    ```

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
