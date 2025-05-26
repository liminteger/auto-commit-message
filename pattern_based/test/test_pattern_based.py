#!/usr/bin/env python3
import pytest
import os
import subprocess
import tempfile
import shutil
import re
import time

class TestAutocommit:
    """패턴 기반 autocommit 스크립트의 테스트 클래스"""
    
    @pytest.fixture(autouse=True)
    def setup_teardown(self):
        """테스트 환경 설정 및 정리를 위한 fixture"""
        # 현재 디렉토리 저장
        self.original_dir = os.getcwd()
        
        # 테스트용 임시 디렉토리 생성
        self.test_dir = tempfile.mkdtemp()
        print(f"\n테스트 디렉토리 생성: {self.test_dir}")
        
        # autocommit 스크립트 경로 설정
        self.script_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'autocommit'))
        print(f"스크립트 경로: {self.script_path}")
        
        # Git 리포지토리 초기화
        os.chdir(self.test_dir)
        print("Git 리포지토리 초기화...")
        subprocess.run(["git", "init"], check=True)
        subprocess.run(["git", "config", "--local", "user.email", "test@example.com"], check=True)
        subprocess.run(["git", "config", "--local", "user.name", "Test User"], check=True)
        
        # 테스트 실행
        yield
        
        # 테스트 후 정리
        os.chdir(self.original_dir)
        shutil.rmtree(self.test_dir)
        print(f"테스트 디렉토리 제거: {self.test_dir}")
    
    def run_script(self, input_value=None):
        """스크립트를 bash로 실행하는 헬퍼 함수"""
        cmd = ["bash", self.script_path]
        
        print(f"\n스크립트 실행: {' '.join(cmd)}")
        print(f"입력값: {input_value}")
        
        if input_value:
            process = subprocess.run(cmd, 
                                   input=input_value, 
                                   capture_output=True, 
                                   text=True)
        else:
            process = subprocess.run(cmd, 
                                   capture_output=True, 
                                   text=True)
        
        print(f"반환 코드: {process.returncode}")
        
        if process.stdout:
            print("표준 출력:")
            print(process.stdout)
        
        if process.stderr:
            print("오류 출력:")
            print(process.stderr)
        
        return process
    
    def extract_commit_message(self, output):
        """출력에서 제안된 커밋 메시지 추출"""
        match = re.search(r"제안된 커밋 메시지: (.*?)[\r\n]", output, re.MULTILINE)
        if match:
            return match.group(1)
        return None
    
    def test_no_staged_changes(self):
        """스테이징된 변경 사항이 없는 경우"""
        result = self.run_script()
        
        assert result.returncode != 0
        assert "스테이징된 변경 사항이 없습니다" in (result.stdout + result.stderr)
    
    def test_readme_md_pattern(self):
        """README.md 파일의 커밋 메시지 패턴 테스트"""
        # README.md 파일 생성 및 스테이징
        with open(os.path.join(self.test_dir, "README.md"), "w") as f:
            f.write("# 테스트 프로젝트\n내용")
        
        subprocess.run(["git", "add", "README.md"], check=True)
        
        # 커밋 취소 ('n' 입력)
        result = self.run_script("n\n")
        output = result.stdout + result.stderr
        
        # 커밋 메시지 추출 및 확인
        commit_message = self.extract_commit_message(output)
        print(f"생성된 커밋 메시지: {commit_message}")
        
        # 스크립트 명세에 따른 확인
        assert commit_message is not None
        assert commit_message.startswith("docs:")
        assert "README" in commit_message
        assert "문서" in commit_message
        assert "커밋이 취소되었습니다" in output
    
    def test_markdown_pattern(self):
        """일반 마크다운 파일의 커밋 메시지 패턴 테스트"""
        # 일반 마크다운 파일 생성 및 스테이징
        with open(os.path.join(self.test_dir, "CONTRIBUTING.md"), "w") as f:
            f.write("# 기여 가이드\n내용")
        
        subprocess.run(["git", "add", "CONTRIBUTING.md"], check=True)
        
        # 커밋 취소 ('n' 입력)
        result = self.run_script("n\n")
        output = result.stdout + result.stderr
        
        # 커밋 메시지 추출 및 확인
        commit_message = self.extract_commit_message(output)
        print(f"생성된 커밋 메시지: {commit_message}")
        
        # 스크립트 명세에 따른 확인
        assert commit_message is not None
        assert commit_message.startswith("docs:")
        assert "문서" in commit_message
    
    def test_license_pattern(self):
        """LICENSE 파일의 커밋 메시지 패턴 테스트"""
        # LICENSE 파일 생성 및 스테이징
        with open(os.path.join(self.test_dir, "LICENSE"), "w") as f:
            f.write("MIT License\n\nCopyright (c) 2023")
        
        subprocess.run(["git", "add", "LICENSE"], check=True)
        
        # 커밋 취소 ('n' 입력)
        result = self.run_script("n\n")
        output = result.stdout + result.stderr
        
        # 커밋 메시지 추출 및 확인
        commit_message = self.extract_commit_message(output)
        print(f"생성된 커밋 메시지: {commit_message}")
        
        # 스크립트 명세에 따른 확인
        assert commit_message is not None
        assert commit_message.startswith("chore:")
        assert "라이센스" in commit_message
    
    def test_shell_script_pattern(self):
        """쉘 스크립트 파일의 커밋 메시지 패턴 테스트"""
        # 쉘 스크립트 파일 생성 및 스테이징
        with open(os.path.join(self.test_dir, "deploy.sh"), "w") as f:
            f.write("#!/bin/bash\necho 'Hello'")
        
        subprocess.run(["git", "add", "deploy.sh"], check=True)
        
        # 커밋 취소 ('n' 입력)
        result = self.run_script("n\n")
        output = result.stdout + result.stderr
        
        # 커밋 메시지 추출 및 확인
        commit_message = self.extract_commit_message(output)
        print(f"생성된 커밋 메시지: {commit_message}")
        
        # 스크립트 명세에 따른 확인
        assert commit_message is not None
        assert commit_message.startswith("feat:")
        assert "쉘" in commit_message
    
    def test_multiple_files_pattern(self):
        """여러 파일의 커밋 메시지 패턴 테스트 (6개 이상)"""
        # 여러 파일 생성 및 스테이징
        for i in range(6):
            with open(os.path.join(self.test_dir, f"file{i}.txt"), "w") as f:
                f.write(f"Content for file {i}")
        
        subprocess.run(["git", "add", "."], check=True)
        
        # 커밋 취소 ('n' 입력)
        result = self.run_script("n\n")
        output = result.stdout + result.stderr
        
        # 커밋 메시지 추출 및 확인
        commit_message = self.extract_commit_message(output)
        print(f"생성된 커밋 메시지: {commit_message}")
        
        # 스크립트 명세에 따른 확인
        assert commit_message is not None
        assert commit_message.startswith("feat:")
        assert "여러 파일" in commit_message
    
    def test_javascript_pattern(self):
        """JavaScript 파일의 커밋 메시지 패턴 테스트"""
        # 자바스크립트 파일 생성 및 스테이징
        with open(os.path.join(self.test_dir, "app.js"), "w") as f:
            f.write("console.log('Hello');")
        
        subprocess.run(["git", "add", "app.js"], check=True)
        
        # 커밋 취소 ('n' 입력)
        result = self.run_script("n\n")
        output = result.stdout + result.stderr
        
        # 커밋 메시지 추출 및 확인
        commit_message = self.extract_commit_message(output)
        print(f"생성된 커밋 메시지: {commit_message}")
        
        # 스크립트 명세에 따른 확인
        assert commit_message is not None
        assert commit_message.startswith("feat:")
        assert "JavaScript" in commit_message
    
    def test_css_pattern(self):
        """CSS 파일의 커밋 메시지 패턴 테스트"""
        # CSS 파일 생성 및 스테이징
        with open(os.path.join(self.test_dir, "style.css"), "w") as f:
            f.write("body { color: black; }")
        
        subprocess.run(["git", "add", "style.css"], check=True)
        
        # 커밋 취소 ('n' 입력)
        result = self.run_script("n\n")
        output = result.stdout + result.stderr
        
        # 커밋 메시지 추출 및 확인
        commit_message = self.extract_commit_message(output)
        print(f"생성된 커밋 메시지: {commit_message}")
        
        # 스크립트 명세에 따른 확인
        assert commit_message is not None
        assert commit_message.startswith("style:")
        assert "스타일" in commit_message
    
    def test_html_pattern(self):
        """HTML 파일의 커밋 메시지 패턴 테스트"""
        # HTML 파일 생성 및 스테이징
        with open(os.path.join(self.test_dir, "index.html"), "w") as f:
            f.write("<html><body>Hello</body></html>")
        
        subprocess.run(["git", "add", "index.html"], check=True)
        
        # 커밋 취소 ('n' 입력)
        result = self.run_script("n\n")
        output = result.stdout + result.stderr
        
        # 커밋 메시지 추출 및 확인
        commit_message = self.extract_commit_message(output)
        print(f"생성된 커밋 메시지: {commit_message}")
        
        # 스크립트 명세에 따른 확인
        assert commit_message is not None
        assert commit_message.startswith("feat:")
        assert "HTML" in commit_message
    
    def test_default_pattern(self):
        """기타 파일의 기본 커밋 메시지 패턴 테스트"""
        # 기타 파일 생성 및 스테이징
        file_name = "config.json"
        with open(os.path.join(self.test_dir, file_name), "w") as f:
            f.write('{"key": "value"}')
        
        subprocess.run(["git", "add", file_name], check=True)
        
        # 커밋 취소 ('n' 입력)
        result = self.run_script("n\n")
        output = result.stdout + result.stderr
        
        # 커밋 메시지 추출 및 확인
        commit_message = self.extract_commit_message(output)
        print(f"생성된 커밋 메시지: {commit_message}")
        
        # 스크립트 명세에 따른 확인
        assert commit_message is not None
        assert commit_message.startswith("chore:")
        assert file_name in commit_message
    
    def test_edit_commit_message(self):
        """커밋 메시지 편집 테스트"""
        # 파일 생성 및 스테이징
        with open(os.path.join(self.test_dir, "test.txt"), "w") as f:
            f.write("테스트 내용")
        
        subprocess.run(["git", "add", "test.txt"], check=True)
        
        # 먼저 스크립트가 제안하는 커밋 메시지 확인 (커밋하지 않음)
        check_result = self.run_script("n\n")
        original_commit_msg = self.extract_commit_message(check_result.stdout + check_result.stderr)
        print(f"원래 제안된 커밋 메시지: {original_commit_msg}")
        
        # 다시 스테이징
        subprocess.run(["git", "add", "test.txt"], check=True)
        
        # 메시지 편집 ('e' 선택 후 새 메시지 입력)
        custom_msg = "feat: 커스텀 메시지 입력"
        result = self.run_script(f"e\n{custom_msg}\n")
        
        # 커밋 메시지 확인
        commit_msg = subprocess.run(["git", "log", "-1", "--pretty=%B"], 
                                  capture_output=True, text=True).stdout.strip()
        print(f"편집된 커밋 메시지: {commit_msg}")
        
        # 원래 메시지와 사용자 편집 메시지가 다른지 확인
        assert original_commit_msg != commit_msg
        
        # 입력한 메시지와 동일한지 확인
        assert custom_msg == commit_msg
        assert commit_msg.startswith("feat:")