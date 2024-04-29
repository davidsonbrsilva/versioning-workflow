#!/bin/bash

if [[ -z "$ORIGIN_BRANCH" ]]; then
  echo "'ORIGIN_BRANCH' is required."
  exit 1
fi

if [[ -z "$MAIN_BRANCH" ]]; then
  $MAIN_BRANCH="main"
fi

# Fetch tags from remote.
git fetch --unshallow origin --tags > /dev/null 2>&1 || { echo "Failed to fetch tags from remote."; exit 1; }

# Get the last repository tag.
origin_branch_last_version=$(git tag --sort=committerdate --merged=$(git rev-parse "origin/$ORIGIN_BRANCH") | grep -v '^v' | tail -n 1)
repository_last_version=$(git tag --sort=committerdate | grep -v '^v' | tail -n 1)

echo "Last branch version: $origin_branch_last_version"
echo "Last repository version: $repository_last_version"

is_origin_branch_version_published=$(git branch -a --contains $origin_branch_last_version | grep "origin/$MAIN_BRANCH")
is_repository_version_published=$(git branch -a --contains $repository_last_version | grep "origin/$MAIN_BRANCH")

last_version=$(echo -e "$origin_branch_last_version\n$repository_last_version" | sort -V | tail -n 1)

if [[ -n "$is_origin_branch_version_published" ]]; then
  last_version=$origin_branch_last_version
  echo "The branch version is already in '$MAIN_BRANCH'."
fi

if [[ -n "$is_repository_version_published" ]]; then
  last_version=$repository_last_version
  echo "The repository version is already in '$MAIN_BRANCH'."
fi

if [[ -z "$last_version" ]]; then
  echo "No found version associated with this branch."
  exit 0
fi

echo "last_version=$last_version" >> $GITHUB_OUTPUT
echo "Choosen version: $last_version"
exit 0
