#!/bin/bash

if [[ -z "$ORIGIN_BRANCH" ]]; then
  echo "'ORIGIN_BRANCH' is required."
  exit 1
fi

# Fetch tags from remote.
git fetch --unshallow origin --tags > /dev/null 2>&1 || { echo "Failed to fetch tags from remote."; exit 1; }

# Get the last repository tag.
origin_branch_last_version=$(git tag --sort=committerdate --merged=$(git rev-parse "origin/$ORIGIN_BRANCH") | grep -v '^v' | tail -n 1)
repository_last_version=$(git tag --sort=committerdate | grep -v '^v' | tail -n 1)

echo "Origin branch last version: $origin_branch_last_version"
echo "Main branch last version: $repository_last_version"

is_published=$(git branch --contains $repository_last_version | grep "main")

echo "Was published: $is_published"

last_version=$repository_last_version

if [[ -z "$is_published" ]]; then
  echo "The tag version was not published in production."
  last_version=$(echo -e "$origin_branch_last_version\n$repository_last_version" | sort -V | tail -n 1)
fi

echo "Choosed version: $last_version"

if [[ -z "$last_version" ]]; then
  echo "No found version associated with this branch."
  exit 0
fi

echo "last_version=$last_version" >> $GITHUB_OUTPUT
echo "Last found version: $last_version"
exit 0
