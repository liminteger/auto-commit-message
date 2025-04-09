# AutoCommit

Git diff를 분석하여 자동으로 커밋 메시지를 생성하는 CLI 도구입니다.

## 개요

AutoCommit은 `git diff`의 내용을 분석하여 적절한 커밋 메시지를 자동으로 생성합니다. Conventional Commits 형식을 준수하며, 무료로 사용할 수 있습니다.

## 현재 구현 상태

> **중요**: 현재 버전은 패턴 매칭 기반으로 작동합니다. 파일 타입과 변경 내용을 분석하여 적절한 커밋 메시지를 생성합니다.
> 
> LLM(Large Language Model) 통합은 현재 구현되어 있지 않으며, 향후 개발 계획에 포함되어 있습니다.

## 특징

- 📝 Conventional Commits 형식에 맞는 커밋 메시지 생성
- 🔍 파일 변경 패턴 인식을 통한 메시지 생성 메커니즘 제공
- 🚀 간단한 설치 및 사용법
- 💻 크로스 플랫폼 지원 (Linux, macOS, Windows)

## 설치 요구사항

### Linux/macOS
- Bash 쉘
- Git

~~### Windows~~
~~- PowerShell 5.1 이상~~
~~- Git for Windows~~

## 설치 방법

### Linux/macOS

1. 저장소 클론
```bash
git clone https://github.com/yourusername/autocommit.git
cd autocommit
```

2. 설치 스크립트 실행
```bash
chmod +x install.sh
./install.sh
```

~~### Windows~~

~~1. 저장소 클론~~
~~```powershell~~
~~git clone https://github.com/yourusername/autocommit.git~~
~~cd autocommit\windows~~
~~```~~

~~2. PowerShell을 관리자 권한으로 실행하고 정책 설정~~
~~```powershell~~
~~Set-ExecutionPolicy RemoteSigned -Scope CurrentUser~~
~~```~~

~~3. 설치 스크립트 실행~~
~~```powershell~~
~~.\install.ps1~~
~~```~~

~~4. 새 터미널 창을 열고 `autocommit` 명령 확인~~

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

## 향후 개발 계획

1. **더 정확한 패턴 인식**: 다양한 프로그래밍 언어와 프레임워크에 대한 패턴 인식 개선
2. **LLM 통합 고려**: 로컬 LLM 기반 메시지 생성 옵션 검토
3. **커스텀 패턴 설정**: 사용자 정의 패턴 및 규칙 지원

## 문제 해결

### 공통 문제 해결
- 기본 패턴 매칭 시스템은 외부 의존성 없이 작동합니다

### Windows 관련 문제
~~- Windows에서 특별한 문제가 있는 경우 [windows/README.md](windows/README.md)를 참조하세요.~~
- WSL(Windows Subsystem for Linux)에서도 Linux 버전 스크립트 사용 가능

## 기여 방법

기여는 언제나 환영합니다! [CONTRIBUTING.md](CONTRIBUTING.md)를 참조하세요.

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.