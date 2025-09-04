#!/bin/sh
if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/git/repo"
  exit 1
fi

REPO_DIR="$1"
HOOKS_DIR="$REPO_DIR/.git/hooks"
TARGET_HOOK="$HOOKS_DIR/prepare-commit-msg"
if [ ! -d "$HOOKS_DIR" ]; then
  echo "Error: '$REPO_DIR' is not a valid Git repository."
  exit 1
fi

if [ -f "hook.txt" ]; then
  echo "📄 Found 'hook.txt', using it as the hook source."
  cp "hook.txt" "$TARGET_HOOK"
else
  echo "⚠️ 'hook.txt' not found. Creating default prepare-commit-msg hook."

  cat > "$TARGET_HOOK" << 'EOF'
#!/bin/sh

echo "Running prepare commit msg"
COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2
SHA1=$3

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

echo "Prefix Invoked"

JIRA_TICKET=$(echo "$BRANCH_NAME" | grep -oE '[A-Z]+-[0-9]+' | tail -1)

if [ -n "$JIRA_TICKET" ]; then
    if ! grep -q "^$JIRA_TICKET" "$COMMIT_MSG_FILE"; then
        sed -i.bak "1s/^/$JIRA_TICKET: /" "$COMMIT_MSG_FILE"
    fi
fi
EOF

fi

chmod +x "$TARGET_HOOK"

echo "✅ prepare-commit-msg hook installed to '$TARGET_HOOK'"
