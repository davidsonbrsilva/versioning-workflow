#!/bin/bash

if [[ -z "$ORIGIN_BRANCH" ]]; then
  echo "'ORIGIN_BRANCH' is required."
  exit 1
fi

# Fetch tags from remote.
git fetch --unshallow origin --tags > /dev/null 2>&1 || { echo "Failed to fetch tags from remote."; exit 1; }

# Get the last repository tag.
last_version=$(git tag --sort=committerdate --merged=$(git rev-parse "origin/$ORIGIN_BRANCH") | grep -v '^v' | tail -n 1)
last_version=$(git tag -l "$last_version*" | sort -V | tail -n 1)

if [[ -z "$last_version" ]]; then
  echo "No found version associated with this branch."
  exit 0
fi

echo "last_version=$last_version" >> $GITHUB_OUTPUT
echo "Last found version: $last_version"
exit 0
