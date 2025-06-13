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
    ```
    sudo ./install.sh
    ```

2. 실행 | Run
    ```bash
    autocommit
    ```
    
3. 사용 예시 | Usage Example

* 스테이징된 변경 사항이 없는 경우
    ```bash
    스테이징된 변경 사항이 없습니다. git add 명령어로 파일을 스테이징하세요.
    ```

* 작업을 수행하고 파일을 스테이징한 경우
     ```bash
    변경된 파일 : [파일이름]
    변경 요약 : 1 file changed, 4 deletions(-)
    변경 사항을 분석하여 커밋 메시지를 생성 중...
    제안된 커밋 메시지 : [변경 사항을 분석하여 적절한 커밋 메시지가 표현됩니다.]
    이 메시지로 커밋하시겠습니까? : (y/n/e-편집): 
    ```
    * y 입력 시 : 제안된 메시지로 커밋이 수행됩니다.
    * n 입력 시 : 커밋이 취소됩니다.
    * e 입력 시 : 편집기(기본값 : vi)가 열리고 메시지를 작성 후 저장하고 종료하면 해당 메시지로 커밋이 수행됩니다.
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

Git 커밋 메시지를 생성하는 도구를 설정하고 사용할 준비가 완료되었습니다.  
You're all set up to start generating Git commit messages based on document patterns!

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
