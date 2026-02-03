#!/bin/bash

set -e

BRANCH=$(git branch --show-current)
MSG="auto-commit $(date '+%Y-%m-%d %H:%M:%S')"

echo "📦 Stashing local changes..."
git stash push -u -m "auto-stash" >/dev/null || true

echo "🔄 Pulling latest..."
git pull origin "$BRANCH" --rebase

echo "📤 Applying stash..."
git stash pop >/dev/null || true

echo "➕ Adding changes..."
git add .

echo "📝 Committing..."
git commit -m "$MSG" || echo "ℹ️ Nothing to commit"

echo "🚀 Pushing..."
git push origin "$BRANCH"

echo "✅ Auto Git done"


