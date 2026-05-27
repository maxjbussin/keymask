#!/usr/bin/env bash
# Tests keymask against synthetic keys of known shapes.
# All "secrets" below are FAKE — generated for testing only.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEYMASK="$SCRIPT_DIR/../keymask"

if [ ! -x "$KEYMASK" ]; then
    echo "FAIL: $KEYMASK not found or not executable"
    exit 1
fi

PASS=0
FAIL=0

assert_redacts() {
    local label="$1"
    local input="$2"
    local pattern_name="$3"
    local output
    output=$(echo "$input" | "$KEYMASK" 2>/dev/null)
    if echo "$output" | grep -qE "REDACTED:($pattern_name)"; then
        echo "PASS: $label"
        PASS=$((PASS+1))
    else
        echo "FAIL: $label"
        echo "  input:  $input"
        echo "  output: $output"
        echo "  expected: REDACTED:$pattern_name"
        FAIL=$((FAIL+1))
    fi
}

assert_unchanged() {
    local label="$1"
    local input="$2"
    local output
    output=$(echo "$input" | "$KEYMASK" 2>/dev/null)
    if [ "$output" = "$input" ]; then
        echo "PASS: $label (no false positive)"
        PASS=$((PASS+1))
    else
        echo "FAIL: $label (false positive)"
        echo "  input:  $input"
        echo "  output: $output"
        FAIL=$((FAIL+1))
    fi
}

echo "=== keymask pattern tests ==="

assert_redacts "Anthropic"        "sk-ant-api03-FAKEabc1234567890fakedef"              "Anthropic"
assert_redacts "OpenRouter"       "sk-or-v1-FAKEabc1234567890fakedef1234567890abc"     "OpenRouter"
assert_redacts "OpenAI legacy"    "sk-FAKE1234567890abcdef1234567890abcdef1234567890"  "OpenAI"
assert_redacts "OpenAI project"   "sk-proj-FAKEabc1234567890fakedef"                   "OpenAI"
assert_redacts "xAI"              "xai-FAKEabc1234567890fakedef"                       "xAI"
assert_redacts "Stripe live"      "sk_live_FAKEFAKEFAKEFAKEFAKEab"                   "Stripe"
assert_redacts "Stripe test"      "sk_test_FAKEFAKEFAKEFAKEFAKEab"                   "Stripe"
assert_redacts "GitHub PAT"       "ghp_FAKE1234567890abcdef1234567890abcdef12"         "GitHub"
assert_redacts "GitLab PAT"       "glpat-FAKEFAKEFAKEFAKEFAKE"                         "GitLab"
assert_redacts "Google OAuth"     "ya29.FAKEabc1234567890fakedef"                      "GoogleOAuth"
assert_redacts "AWS access key"   "AKIAIOSFODNN7EXAMPLE"                               "AWS-AccessKey"
assert_redacts "Twilio SID"       "ACabababababababababababababababab"                 "TwilioSID"
assert_redacts "Telegram bot"     "123456789:AAH-FAKE12345678901234567890123456789"    "TelegramBot"
assert_redacts "JWT"              "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ4eHgifQ.FAKE12345678901234" "JWT"
assert_redacts "Slack"            "xoxb-FAKE1234567890-abcdef"                         "Slack"
assert_redacts "Bearer header"    "Authorization: Bearer FAKEabc1234567890fakedef12345" "JWT|BearerHeader"
assert_redacts "Generic env var"  "MY_SECRET_KEY=somerandomvaluethatislong"            "EnvVar"

assert_unchanged "Plain log line"     "Request completed in 234ms"
assert_unchanged "Hex color"          "color: #FF5733;"
assert_unchanged "UUID"               "request-id: 550e8400-e29b-41d4-a716-446655440000"
assert_unchanged "Short token-like"   "id=abc123"

echo ""
echo "=== Results ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -gt 0 ]; then
    exit 1
fi
