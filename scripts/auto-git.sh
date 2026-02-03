#!/bin/bash

set -e

BRANCH=$(git branch --show-current)
MSG="auto-commit $(date '+%Y-%m-%d %H:%M:%S')"

echo "Ì¥Ñ Pulling latest..."
git pull origin "$BRANCH" --rebase

echo "‚ûï Adding changes..."
git add .

echo "Ì≥ù Committing..."
git commit -m "$MSG" || echo "‚ÑπÔ∏è Nothing to commit"

echo "Ì∫Ä Pushing..."
git push origin "$BRANCH"

echo "‚úÖ Auto Git done"

