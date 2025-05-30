#!/bin/bash

# Silently copy /host-pwd to /workspace
echo "Cloning git repo into new/isolated branch $BRANCH_NAME..."
rsync -a /host-pwd/ /workspace/ 

cd /workspace

if [ -n "$BRANCH_NAME" ]; then
  git checkout -b "$BRANCH_NAME"
  # Only store the commit hash if HEAD exists
  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    export ORIGINAL_COMMIT_HASH=$(git rev-parse HEAD)
  else
    export ORIGINAL_COMMIT_HASH=""
    echo "Warning: No commits found in the repository at branch creation."
  fi
else
  echo "Warning: BRANCH_NAME is not set. Something has gone wrong." >&2
  exit 1
fi

"$@"
exit_code=$?

# After the command exits: only push if there are new commits on $BRANCH_NAME compared to the original commit
if [ -n "$BRANCH_NAME" ]; then
  CURRENT_COMMIT_HASH=$(git rev-parse "$BRANCH_NAME")
  if [ -z "$ORIGINAL_COMMIT_HASH" ]; then
    # No original commit, so any commit is new
    echo "Repository was empty at branch creation. Pushing any new commits to host git checkout under $BRANCH_NAME..."
    git remote add hostrepo /host-pwd 2>/dev/null || true
    git push hostrepo "$BRANCH_NAME"
  elif [ "$CURRENT_COMMIT_HASH" != "$ORIGINAL_COMMIT_HASH" ]; then
    echo "New commits detected on $BRANCH_NAME. Pushing to host git checkout under $BRANCH_NAME..."
    git remote add hostrepo /host-pwd 2>/dev/null || true
    git push hostrepo "$BRANCH_NAME"
  else
    echo "No new commits to push; original git checkout is untouched."
  fi
fi

exit $exit_code
