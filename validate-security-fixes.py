#!/usr/bin/env python3
"""
Security validation script for Legal AI Toolkit
Validates that all critical security fixes are in place
"""

import os
import re
import sys
from pathlib import Path

def check_file_contains(file_path, pattern, description):
    """Check if file contains expected pattern"""
    try:
        with open(file_path, 'r') as f:
            content = f.read()
            if re.search(pattern, content, re.MULTILINE):
                print(f"✅ {description}")
                return True
            else:
                print(f"❌ {description}")
                return False
    except FileNotFoundError:
        print(f"❌ {description} - File not found: {file_path}")
        return False

def check_file_not_contains(file_path, pattern, description):
    """Check if file does NOT contain pattern"""
    try:
        with open(file_path, 'r') as f:
            content = f.read()
            if not re.search(pattern, content, re.MULTILINE):
                print(f"✅ {description}")
                return True
            else:
                print(f"❌ {description}")
                return False
    except FileNotFoundError:
        print(f"✅ {description} - File not found (good)")
        return True

def main():
    print("🔒 Legal AI Toolkit - Security Validation")
    print("=" * 45)
    
    all_passed = True
    
    # 1. Development mode default check
    result = check_file_contains(
        "web-portal/backend/main.py",
        r'os\.getenv\("DEVELOPMENT_MODE", "false"\)',
        "Development mode defaults to 'false'"
    )
    all_passed = all_passed and result
    
    # 2. Environment variable requirements
    result = check_file_contains(
        "web-portal/backend/auth.py",
        r'if not SECRET_KEY:\s*raise ValueError',
        "SECRET_KEY validation requires environment variable"
    )
    all_passed = all_passed and result
    
    result = check_file_contains(
        "web-portal/backend/database.py",
        r'if not DATABASE_URL:\s*raise ValueError',
        "DATABASE_URL validation requires environment variable"
    )
    all_passed = all_passed and result
    
    # 3. Password validation
    result = check_file_contains(
        "web-portal/backend/schemas.py",
        r'len\(v\) < 12',
        "Password minimum length validation (12 characters)"
    )
    all_passed = all_passed and result
    
    result = check_file_contains(
        "web-portal/backend/schemas.py",
        r'@validator\([\'"]password[\'"]\)',
        "Password validation decorator"
    )
    all_passed = all_passed and result
    
    # 4. CORS restrictions
    result = check_file_contains(
        "web-portal/backend/main.py",
        r'allow_methods=\["GET", "POST", "PUT", "DELETE", "OPTIONS"\]',
        "CORS methods restricted to specific verbs"
    )
    all_passed = all_passed and result
    
    result = check_file_contains(
        "web-portal/backend/main.py",
        r'allow_headers=\["Authorization", "Content-Type"',
        "CORS headers restricted to specific headers"
    )
    all_passed = all_passed and result
    
    # 5. Rate limiting
    result = check_file_contains(
        "web-portal/backend/main.py",
        r'@limiter\.limit\("3/minute"\)',
        "Rate limiting on registration endpoint"
    )
    all_passed = all_passed and result
    
    result = check_file_contains(
        "web-portal/backend/main.py",
        r'@limiter\.limit\("5/minute"\)',
        "Rate limiting on login endpoint"
    )
    all_passed = all_passed and result
    
    # 6. Logging implementation
    result = check_file_contains(
        "web-portal/backend/main.py",
        r'logger\.info\(f"Registration attempt for email',
        "Logging implemented for registration"
    )
    all_passed = all_passed and result
    
    # 7. .env file not in repo
    result = check_file_not_contains(
        ".gitignore",
        r'web-portal/backend/\.env',
        ".env files added to .gitignore"
    )
    # Actually check if gitignore contains the pattern
    result = check_file_contains(
        ".gitignore",
        r'web-portal/backend/\.env',
        ".env files properly excluded in .gitignore"
    )
    all_passed = all_passed and result
    
    # 8. CLAUDE.md in gitignore
    result = check_file_contains(
        ".gitignore",
        r'CLAUDE\.md',
        "CLAUDE.md added to .gitignore"
    )
    all_passed = all_passed and result
    
    # 9. Production configuration exists
    result = os.path.exists("docker-compose.prod.yml")
    if result:
        print("✅ Production Docker configuration exists")
    else:
        print("❌ Production Docker configuration missing")
        all_passed = False
    
    # 10. Testing framework
    result = os.path.exists("web-portal/backend/tests/test_auth.py")
    if result:
        print("✅ Testing framework implemented")
    else:
        print("❌ Testing framework missing")
        all_passed = False
    
    print("\n" + "=" * 45)
    if all_passed:
        print("🎉 ALL SECURITY FIXES VALIDATED SUCCESSFULLY!")
        print("The authentication system is ready for testing.")
        return 0
    else:
        print("⚠️  SOME SECURITY ISSUES REMAIN")
        print("Please address the failed checks above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())