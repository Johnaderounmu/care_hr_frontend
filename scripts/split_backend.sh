#!/usr/bin/env bash
# Split the `backend/` directory into its own Git repository (preserving history)
# Usage:
#   1) From the repo root run:
#        chmod +x scripts/split_backend.sh
#        scripts/split_backend.sh <new-repo-git-url>
#   2) The script will create a split branch and push it to the provided remote as `main`.
#
# Notes:
# - This script uses `git subtree split` which is suitable for many workflows and
#   preserves the `backend/` subdirectory history into a single branch. For very
#   large repos or advanced filtering, prefer `git filter-repo` (not included here).
# - The script does not remove the `backend/` directory from the current repo. After
#   verifying the new remote contains the backend repo, you can remove the `backend/`
#   directory and commit the change to this repo if desired.

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <new-repo-git-url>"
  echo "Example: $0 git@github.com:your-org/care-hr-backend.git"
  exit 1
fi

NEW_REMOTE=$1
SPLIT_BRANCH=backend-split-$(date +%Y%m%d%H%M%S)

if [ ! -d backend ]; then
  echo "Error: backend/ directory not found in this repo. Aborting." >&2
  exit 2
fi

echo "Creating subtree split branch for backend/ -> ${SPLIT_BRANCH}"
git subtree split -P backend -b "${SPLIT_BRANCH}"

echo "Pushing split branch to new remote (${NEW_REMOTE}) as main"
git push "${NEW_REMOTE}" "refs/heads/${SPLIT_BRANCH}:refs/heads/main"

echo "Push complete. The backend history has been pushed to ${NEW_REMOTE} on branch 'main'."
echo "If you want to remove backend/ from this repo (after verifying), run:" \
     "  git rm -r backend && git commit -m 'Remove backend after splitting into separate repo'"

echo "Cleanup local split branch:"
echo "  git branch -D ${SPLIT_BRANCH}"

echo "Done."
