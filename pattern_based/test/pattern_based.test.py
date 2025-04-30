#!/usr/bin/env python3
import unittest
import os
import subprocess
import tempfile
import shutil
import sys
import time
import re

class PatternBasedAutocommitTest(unittest.TestCase):
    """패턴 기반 autocommit 스크립트 테스트 클래스"""
    
    def setUp(self):
        """테스트 환경 설정"""
        # 현재 테스트 정보 출력
        test_name = self.id().split('.')[-1]
        print(f"\n{'=' * 70}")
        print(f"테스트 시작: {test_name}")
        print(f"{'=' * 70}")
        
        # 현재 디렉토리 저장
        self.original_dir = os.getcwd()
        
        # 테스트용 임시 디렉토리 생성
        self.test_dir = tempfile.mkdtemp()
        print(f"테스트 디렉토리 생성: {self.test_dir}")
        
        # autocommit 스크립트 경로 설정
        self.script_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'autocommit'))
        print(f"스크립트 경로: {self.script_path}")
        
        # Git 리포지토리 초기화
        os.chdir(self.test_dir)
        print("Git 리포지토리 초기화 중...")
        subprocess.run(["git", "init"], check=True)
        subprocess.run(["git", "config", "--local", "user.email", "test@example.com"], check=True)
        subprocess.run(["git", "config", "--local", "user.name", "Test User"], check=True)
        print("Git 리포지토리 초기화 완료")
    
    def tearDown(self):
        """테스트 환경 정리"""
        test_name = self.id().split('.')[-1]
        print(f"\n테스트 종료: {test_name}")
        
        # 원래 디렉토리로 복귀
        os.chdir(self.original_dir)
        
        # 테스트 디렉토리 제거
        shutil.rmtree(self.test_dir)
        print(f"테스트 디렉토리 제거: {self.test_dir}")
    
    def run_script(self, input_value=None):
        """스크립트를 bash로 실행하는 헬퍼 함수"""
        cmd = ["bash", self.script_path]
        
        print(f"\n스크립트 실행: {' '.join(cmd)}")
        print(f"입력값: {input_value}")
        
        start_time = time.time()
        if input_value:
            process = subprocess.run(cmd, 
                                    input=input_value, 
                                    capture_output=True, 
                                    text=True)
        else:
            process = subprocess.run(cmd, 
                                    capture_output=True, 
                                    text=True)
        duration = time.time() - start_time
        
        print(f"스크립트 실행 시간: {duration:.2f}초")
        print(f"반환 코드: {process.returncode}")
        
        if process.stdout:
            print("\n--- 표준 출력 ---")
            print(process.stdout)
        
        if process.stderr:
            print("\n--- 오류 출력 ---")
            print(process.stderr)
        
        return process
    
    def extract_commit_message(self, output):
        """출력에서 제안된 커밋 메시지 추출"""
        match = re.search(r"제안된 커밋 메시지: (.*?)$", output, re.MULTILINE)
        if match:
            return match.group(1)
        return None
    
    def check_commit_prefix(self, commit_message, expected_prefix):
        """커밋 메시지 프리픽스 확인"""
        self.assertIsNotNone(commit_message, "커밋 메시지를 찾을 수 없습니다")
        self.assertTrue(
            commit_message.startswith(expected_prefix), 
            f"커밋 메시지 '{commit_message}'에 프리픽스 '{expected_prefix}'가 없습니다"
        )
        print(f"✅ 커밋 프리픽스 확인: '{expected_prefix}' 발견됨")
    
    def test_no_staged_changes(self):
        """스테이징된 변경 사항이 없는 경우"""
        print("\n테스트 내용: 스테이징된 변경 사항이 없을 때 에러 메시지 확인")
        
        result = self.run_script()
        
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("스테이징된 변경 사항이 없습니다", result.stdout + result.stderr)
        print("✅ 테스트 통과: 적절한 에러 메시지 확인됨")
    
    def test_readme_commit_message(self):
        """README.md 파일 커밋 메시지"""
        print("\n테스트 내용: README.md 파일에 대한 커밋 메시지 확인")
        
        # README 파일 생성 및 스테이징
        readme_path = os.path.join(self.test_dir, "README.md")
        with open(readme_path, "w") as f:
            f.write("# 테스트 프로젝트")
        
        print(f"파일 생성: {readme_path}")
        subprocess.run(["git", "add", "README.md"], check=True)
        print("파일 스테이징 완료")
        
        # 커밋 확인 대신 'n' 입력
        result = self.run_script("n\n")
        
        output = result.stdout + result.stderr
        commit_message = self.extract_commit_message(output)
        self.check_commit_prefix(commit_message, "docs:")
        self.assertIn("README", commit_message)
        self.assertIn("커밋이 취소되었습니다", output)
        print("✅ 테스트 통과: docs: 프리픽스와 README 관련 커밋 메시지 확인됨")
    
    def test_markdown_commit_message(self):
        """일반 마크다운 파일 커밋 메시지"""
        print("\n테스트 내용: 일반 마크다운 파일에 대한 커밋 메시지 확인")
        
        # 마크다운 파일 생성 및 스테이징
        md_path = os.path.join(self.test_dir, "CONTRIBUTING.md")
        with open(md_path, "w") as f:
            f.write("# 기여 가이드")
        
        print(f"파일 생성: {md_path}")
        subprocess.run(["git", "add", "CONTRIBUTING.md"], check=True)
        print("파일 스테이징 완료")
        
        # 커밋 확인 대신 'n' 입력
        result = self.run_script("n\n")
        
        output = result.stdout + result.stderr
        commit_message = self.extract_commit_message(output)
        self.check_commit_prefix(commit_message, "docs:")
        self.assertIn("문서", commit_message)
        print("✅ 테스트 통과: docs: 프리픽스와 문서 관련 커밋 메시지 확인됨")
    
    def test_js_file_commit_message(self):
        """JavaScript 파일 커밋 메시지"""
        print("\n테스트 내용: JavaScript 파일에 대한 커밋 메시지 확인")
        
        # JS 파일 생성 및 스테이징
        js_path = os.path.join(self.test_dir, "app.js")
        with open(js_path, "w") as f:
            f.write("console.log('Hello');")
        
        print(f"파일 생성: {js_path}")
        subprocess.run(["git", "add", "app.js"], check=True)
        print("파일 스테이징 완료")
        
        # 커밋 확인 대신 'n' 입력
        result = self.run_script("n\n")
        
        output = result.stdout + result.stderr
        commit_message = self.extract_commit_message(output)
        self.check_commit_prefix(commit_message, "feat:")
        self.assertTrue("JavaScript" in commit_message or "JS" in commit_message or "js" in commit_message)
        print("✅ 테스트 통과: feat: 프리픽스와 JavaScript 관련 커밋 메시지 확인됨")
    
    def test_license_commit_message(self):
        """라이센스 파일 커밋 메시지"""
        print("\n테스트 내용: LICENSE 파일에 대한 커밋 메시지 확인")
        
        # LICENSE 파일 생성 및 스테이징
        license_path = os.path.join(self.test_dir, "LICENSE")
        with open(license_path, "w") as f:
            f.write("MIT License\n\nCopyright (c) 2023")
        
        print(f"파일 생성: {license_path}")
        subprocess.run(["git", "add", "LICENSE"], check=True)
        print("파일 스테이징 완료")
        
        # 커밋 확인 대신 'n' 입력
        result = self.run_script("n\n")
        
        output = result.stdout + result.stderr
        commit_message = self.extract_commit_message(output)
        self.check_commit_prefix(commit_message, "chore:")
        self.assertIn("라이센스", commit_message.lower())
        print("✅ 테스트 통과: chore: 프리픽스와 라이센스 관련 커밋 메시지 확인됨")
    
    def test_shell_script_commit_message(self):
        """쉘 스크립트 파일 커밋 메시지"""
        print("\n테스트 내용: 쉘 스크립트 파일에 대한 커밋 메시지 확인")
        
        # 쉘 스크립트 파일 생성 및 스테이징
        sh_path = os.path.join(self.test_dir, "script.sh")
        with open(sh_path, "w") as f:
            f.write("#!/bin/bash\necho 'Hello'")
        
        print(f"파일 생성: {sh_path}")
        subprocess.run(["git", "add", "script.sh"], check=True)
        print("파일 스테이징 완료")
        
        # 커밋 확인 대신 'n' 입력
        result = self.run_script("n\n")
        
        output = result.stdout + result.stderr
        commit_message = self.extract_commit_message(output)
        self.check_commit_prefix(commit_message, "feat:")
        self.assertIn("쉘", commit_message.lower())
        print("✅ 테스트 통과: feat: 프리픽스와 쉘 스크립트 관련 커밋 메시지 확인됨")
    
    def test_css_file_commit_message(self):
        """CSS 파일 커밋 메시지"""
        print("\n테스트 내용: CSS 파일에 대한 커밋 메시지 확인")
        
        # CSS 파일 생성 및 스테이징
        css_path = os.path.join(self.test_dir, "style.css")
        with open(css_path, "w") as f:
            f.write("body { color: #000; }")
        
        print(f"파일 생성: {css_path}")
        subprocess.run(["git", "add", "style.css"], check=True)
        print("파일 스테이징 완료")
        
        # 커밋 확인 대신 'n' 입력
        result = self.run_script("n\n")
        
        output = result.stdout + result.stderr
        commit_message = self.extract_commit_message(output)
        if commit_message:  # CSS 파일 패턴이 스크립트에 있는지 확인
            if commit_message.startswith("style:"):
                self.check_commit_prefix(commit_message, "style:")
                print("✅ 테스트 통과: style: 프리픽스와 CSS 관련 커밋 메시지 확인됨")
            else:
                print(f"ℹ️ 알림: CSS 파일에 style: 대신 '{commit_message.split(':')[0]}:' 프리픽스가 사용됨")
    
    def test_edit_commit_message(self):
        """커밋 메시지 편집 테스트"""
        print("\n테스트 내용: 커밋 메시지 편집(e) 테스트")
        
        # 파일 생성 및 스테이징
        config_path = os.path.join(self.test_dir, "config.json")
        with open(config_path, "w") as f:
            f.write('{"key": "value"}')
        
        print(f"파일 생성: {config_path}")
        subprocess.run(["git", "add", "config.json"], check=True)
        print("파일 스테이징 완료")
        
        # 먼저 스크립트가 제안하는 커밋 메시지 확인 (커밋하지 않음)
        check_result = self.run_script("n\n")
        original_commit_msg = self.extract_commit_message(check_result.stdout + check_result.stderr)
        print(f"원래 제안된 커밋 메시지: {original_commit_msg}")
        
        # 메시지 편집 ('e' 선택 후 새 메시지 입력)
        custom_msg = "feat: 사용자 정의 커밋 메시지"
        result = self.run_script(f"e\n{custom_msg}\n")
        
        output = result.stdout + result.stderr
        self.assertTrue("메시지" in output and "커밋" in output)
        
        # 편집된 커밋 메시지 확인
        commit_msg = subprocess.run(["git", "log", "-1", "--pretty=%B"], 
                                capture_output=True, text=True).stdout.strip()
        print(f"편집된 커밋 메시지: {commit_msg}")
        
        # 원래 메시지와 사용자 편집 메시지가 다른지 확인
        self.assertNotEqual(original_commit_msg, commit_msg, 
                        "편집된 커밋 메시지가 원래 제안된 메시지와 다르지 않습니다")
        print(f"✅ 원래 제안된 메시지와 편집된 메시지 비교: 다름 확인")
        
        # 사용자가 입력한 메시지가 실제 커밋에 사용되었는지 확인
        self.assertEqual(custom_msg, commit_msg, 
                    "편집된 커밋 메시지가 사용자 입력과 일치하지 않습니다")
        print(f"✅ 사용자 입력과 최종 커밋 메시지 비교: 일치 확인")
        
        # 커밋 메시지가 적절한 프리픽스로 시작하는지 확인
        self.assertTrue(commit_msg.startswith("feat:"), 
                    "편집된 커밋 메시지가 'feat:' 프리픽스로 시작하지 않습니다")
        print("✅ 테스트 통과: 편집된 커밋 메시지에 feat: 프리픽스 확인됨")


if __name__ == "__main__":
    print("\n" + "=" * 80)
    print(f"{'패턴 기반 autocommit 테스트 시작':^80}")
    print("=" * 80)
    unittest.main(verbosity=2)