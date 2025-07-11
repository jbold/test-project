#!/bin/bash

# Advanced security scan with pattern-based whitelisting
# Distinguishes between legitimate code patterns and actual security risks

set -e

# Ensure we're in the project directory
cd "$(dirname "$0")/.."

echo "🔒 Running advanced security scan..."

WARNINGS=0
ERRORS=0

# Safe patterns - legitimate code that should NOT trigger warnings
SAFE_PATTERNS=(
    # Variable declarations without string values
    "(const|let|var|def)\\s+\\w*(password|token|api_key|secret)\\w*\\s*[=:]?\\s*[^'\"]*$"
    
    # Property access patterns
    "\\w+\\.(password|token|api_key|secret)\\w*"
    
    # Environment variable references
    "process\\.env\\.\\w*(PASSWORD|TOKEN|API_KEY|SECRET)\\w*"
    "os\\.environ\\.\\w*(PASSWORD|TOKEN|API_KEY|SECRET)\\w*"
    "\\$\\{?\\w*(PASSWORD|TOKEN|API_KEY|SECRET)\\w*\\}?"
    
    # Function parameters
    "fn\\s+\\w*\\([^)]*\\b(password|token|api_key|secret)\\w*\\b"
    "function\\s+\\w*\\([^)]*\\b(password|token|api_key|secret)\\w*\\b"
    
    # Comments and documentation
    "^\\s*(//|#|\\*|/\\*).*"
    
    # Configuration object keys (without hardcoded values)
    "[\'\"]?(password|token|api_key|secret)\\w*[\'\"]?\\s*:\\s*(null|undefined|\\w+\\(\\)|await\\s+\\w+)"
)

# Risky patterns - these should still trigger warnings/errors
RISKY_PATTERNS=(
    # Hardcoded string values (8+ characters)
    "(password|token|api_key|secret)\\w*\\s*[=:]\\s*['\"][^'\"]{8,}['\"]"
    
    # Base64-encoded values
    "(password|token|api_key|secret)\\w*\\s*[=:]\\s*['\"][A-Za-z0-9+/]{20,}={0,2}['\"]"
    
    # JWT tokens
    "(password|token|api_key|secret)\\w*\\s*[=:]\\s*['\"]eyJ[A-Za-z0-9-_]+\\."
    
    # AWS/API key patterns
    "(password|token|api_key|secret)\\w*\\s*[=:]\\s*['\"](?:AKIA|sk-|sk_|pk_|rk_)[A-Za-z0-9]{16,}['\"]"
    
    # Stripe keys
    "sk_test_[A-Za-z0-9]{24,}"
    "sk_live_[A-Za-z0-9]{24,}"
    
    # Common default passwords
    "(password|secret)\\w*\\s*[=:]\\s*['\"](?:admin|password|123456|secret|test)['\"]"
)

# Check for actual security risks
check_risky_patterns() {
    local file_path="$1"
    local is_auth_file="$2"
    
    for pattern in "${RISKY_PATTERNS[@]}"; do
        if rg -q "$pattern" "$file_path" 2>/dev/null; then
            local matches=$(rg -n "$pattern" "$file_path" 2>/dev/null || echo "")
            if [ -n "$matches" ]; then
                echo "🚨 SECURITY RISK in $file_path:"
                echo "$matches"
                ((ERRORS++))
            fi
        fi
    done
}

# Check if a line matches any safe pattern
is_safe_pattern() {
    local line="$1"
    
    for safe_pattern in "${SAFE_PATTERNS[@]}"; do
        if echo "$line" | rg -q "$safe_pattern" 2>/dev/null; then
            return 0  # Safe pattern found
        fi
    done
    
    return 1  # No safe pattern matched
}

# Determine if file is authentication-related (more lenient)
is_auth_file() {
    local file_path="$1"
    
    if [[ "$file_path" =~ (auth|login|password|security|credential) ]]; then
        return 0
    fi
    
    return 1
}

# Main security scan
echo "  📋 Scanning for security risks..."

# Find all code files
while IFS= read -r -d '' file; do
    # Skip certain file types
    if [[ "$file" =~ \.(md|txt|log|json|yml|yaml)$ ]]; then
        continue
    fi
    
    # Skip hook scripts to prevent recursive scanning
    if [[ "$file" =~ scripts/.*\.sh$ ]]; then
        continue
    fi
    
    # Check if this is an auth-related file
    auth_file=false
    if is_auth_file "$file"; then
        auth_file=true
    fi
    
    # Check for risky patterns
    check_risky_patterns "$file" "$auth_file"
    
    # For non-auth files, check for any suspicious patterns
    if [ "$auth_file" = false ]; then
        # Look for potential secrets in non-auth files
        suspicious_lines=$(rg -n "(password|token|api_key|secret).*[=:].*['\"][^'\"]{8,}['\"]" "$file" 2>/dev/null || echo "")
        
        if [ -n "$suspicious_lines" ]; then
            # Check if these match safe patterns
            while IFS= read -r line; do
                if ! is_safe_pattern "$line"; then
                    echo "⚠️  SUSPICIOUS in $file:"
                    echo "$line"
                    ((WARNINGS++))
                fi
            done <<< "$suspicious_lines"
        fi
    fi
    
done < <(find . -type f -name "*.rs" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.svelte" -print0)

# Check for hardcoded IPs and URLs (still relevant)
if rg -q "http://[0-9]" . --type-not=md 2>/dev/null; then
    echo "⚠️  WARNING: Found hardcoded HTTP URLs"
    ((WARNINGS++))
fi

# Check for TODO security items (still relevant)
if rg -q "TODO.*security|FIXME.*security|XXX.*security" . --type-not=md 2>/dev/null; then
    echo "⚠️  INFO: Found security-related TODO items"
    # Don't count TODOs as warnings for blocking
fi

# Summary and exit logic
echo ""
echo "📊 Security scan summary:"
echo "  🚨 Errors (blocking): $ERRORS"
echo "  ⚠️  Warnings (review): $WARNINGS"

if [ "$ERRORS" -gt 0 ]; then
    echo "🛑 Security scan found $ERRORS critical issues. Please fix before proceeding."
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo "⚠️  Security scan found $WARNINGS potential issues. Review recommended but not blocking."
    exit 0
else
    echo "✅ Security scan passed - no issues found"
    exit 0
fi