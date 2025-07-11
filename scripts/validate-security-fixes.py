#!/usr/bin/env python3
"""
Security Fixes Validation Script
Validates that all critical security issues have been addressed.
"""

import os
import re
import sys
from pathlib import Path

def validate_hardcoded_urls():
    """Validate that hardcoded API URLs have been removed"""
    print("🔍 Validating hardcoded API URLs...")
    
    auth_rs_path = Path("src/auth.rs")
    if not auth_rs_path.exists():
        print("❌ src/auth.rs not found")
        return False
    
    with open(auth_rs_path) as f:
        content = f.read()
    
    # Check for hardcoded localhost URLs (not as fallback)
    hardcoded_patterns = [
        r'const\s+API_BASE_URL\s*:\s*&str\s*=\s*"http://localhost:8000"',
    ]
    
    for pattern in hardcoded_patterns:
        if re.search(pattern, content):
            print(f"❌ Found hardcoded API URL: {pattern}")
            return False
    
    # Check for environment configuration
    if "env::var(\"API_BASE_URL\")" not in content:
        print("❌ Environment variable API_BASE_URL not used")
        return False
    
    print("✅ Hardcoded API URLs fixed - using environment variables")
    return True

def validate_secure_token_storage():
    """Validate that secure token storage is implemented"""
    print("🔍 Validating secure token storage...")
    
    auth_rs_path = Path("src/auth.rs")
    if not auth_rs_path.exists():
        print("❌ src/auth.rs not found")
        return False
    
    with open(auth_rs_path) as f:
        content = f.read()
    
    # Check for keyring usage
    security_features = [
        "use keyring::Entry",
        "keyring_entry: Entry",
        ".set_password",
        ".get_password",
        ".delete_password",
    ]
    
    for feature in security_features:
        if feature not in content:
            print(f"❌ Missing secure storage feature: {feature}")
            return False
    
    print("✅ Secure token storage implemented using OS keyring")
    return True

def validate_stripe_test_mode():
    """Validate that Stripe test mode is used instead of development bypass"""
    print("🔍 Validating Stripe test mode implementation...")
    
    main_py_path = Path("web-portal/backend/main.py")
    if not main_py_path.exists():
        print("❌ web-portal/backend/main.py not found")
        return False
    
    with open(main_py_path) as f:
        content = f.read()
    
    # Check for dangerous bypass patterns
    dangerous_patterns = [
        r'if\s+os\.getenv\(["\']DEVELOPMENT_MODE["\'].*\):\s*pass\s*#\s*Skip.*check',
        r'DEVELOPMENT_MODE.*true.*:\s*pass',
        r'os\.getenv\(["\']DEVELOPMENT_MODE["\']',
    ]
    
    for pattern in dangerous_patterns:
        if re.search(pattern, content, re.IGNORECASE):
            print(f"❌ Found dangerous development bypass: {pattern}")
            return False
    
    # Check for proper Stripe test mode implementation
    required_patterns = [
        r'stripe_secret_key.*startswith\(["\']sk_test_["\']\)',
        r'is_stripe_test_mode',
        r'test_subscription',
    ]
    
    for pattern in required_patterns:
        if not re.search(pattern, content, re.IGNORECASE):
            print(f"❌ Missing Stripe test mode feature: {pattern}")
            return False
    
    print("✅ Stripe test mode properly implemented")
    return True

def validate_secure_token_storage_only():
    """Validate that only secure token storage is used (no plaintext fallback)"""
    print("🔍 Validating secure-only token storage...")
    
    auth_rs_path = Path("src/auth.rs")
    if not auth_rs_path.exists():
        print("❌ src/auth.rs not found")
        return False
    
    with open(auth_rs_path) as f:
        content = f.read()
    
    # Check for proper error types
    error_features = [
        "pub struct AuthError",
        "Result<AuthResult, AuthError>",
        "eprintln!(\"[AUTH_ERROR]",
        "AuthError::new",
    ]
    
    for feature in error_features:
        if feature not in content:
            print(f"❌ Missing error handling feature: {feature}")
            return False
    
    # Check for removal of error masking
    if "Err(e) => Ok(AuthResult {" in content:
        print("❌ Still found error masking patterns")
        return False
    
    # Check for removal of plaintext token fallback
    dangerous_patterns = [
        r'DEVELOPMENT_MODE.*file.*fallback',
        r'fs::write.*token.*development',
        r'fs::read_to_string.*token.*development',
    ]
    
    for pattern in dangerous_patterns:
        if re.search(pattern, content, re.IGNORECASE):
            print(f"❌ Found plaintext token fallback: {pattern}")
            return False
    
    print("✅ Secure-only token storage implemented")
    return True

def validate_environment_configuration():
    """Validate that environment configuration is properly set up"""
    print("🔍 Validating environment configuration...")
    
    # Check for .env files
    env_files = [".env", ".env.production"]
    for env_file in env_files:
        if not Path(env_file).exists():
            print(f"❌ Missing environment file: {env_file}")
            return False
    
    # Check that DEVELOPMENT_MODE is removed from .env files
    for env_file in env_files:
        with open(env_file) as f:
            env_content = f.read()
        
        if "DEVELOPMENT_MODE" in env_content:
            print(f"❌ Found DEVELOPMENT_MODE in {env_file} - should be removed")
            return False
    
    # Check for proper Stripe key configuration
    backend_env_path = Path("web-portal/backend/.env")
    if backend_env_path.exists():
        with open(backend_env_path) as f:
            backend_env_content = f.read()
        
        if "sk_test_" not in backend_env_content:
            print("❌ Missing Stripe test key configuration")
            return False
    
    # Check Cargo.toml for dependencies
    cargo_path = Path("Cargo.toml")
    if not cargo_path.exists():
        print("❌ Cargo.toml not found")
        return False
    
    with open(cargo_path) as f:
        cargo_content = f.read()
    
    required_deps = ["keyring", "dotenv"]
    for dep in required_deps:
        if dep not in cargo_content:
            print(f"❌ Missing dependency: {dep}")
            return False
    
    # Check main.rs for dotenv loading
    main_rs_path = Path("src/main.rs")
    if main_rs_path.exists():
        with open(main_rs_path) as f:
            main_content = f.read()
        
        if "dotenv::dotenv()" not in main_content:
            print("❌ Missing dotenv loading in main.rs")
            return False
    
    print("✅ Environment configuration properly set up")
    return True

def main():
    """Run all security validation checks"""
    print("🛡️  Legal AI Toolkit - Security Fixes Validation\n")
    
    os.chdir(Path(__file__).parent.parent)
    
    checks = [
        validate_hardcoded_urls,
        validate_secure_token_storage,
        validate_stripe_test_mode,
        validate_secure_token_storage_only,
        validate_environment_configuration,
    ]
    
    passed = 0
    total = len(checks)
    
    for check in checks:
        if check():
            passed += 1
        print()
    
    print(f"🎯 Security Validation Results: {passed}/{total} checks passed")
    
    if passed == total:
        print("🎉 All critical security issues have been addressed!")
        print("✅ Ready for production deployment")
        sys.exit(0)
    else:
        print("❌ Some security issues remain - please review and fix")
        sys.exit(1)

if __name__ == "__main__":
    main()