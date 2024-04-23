#!/bin/bash

# Fetch tags from remote.
git fetch --unshallow origin --tags > /dev/null 2>&1 || { echo "Failed to fetch tags from remote."; exit 1; }

# Check if there is a tag associated to HEAD commit.
if git tag --points-at HEAD 2>/dev/null | grep -q .; then
  echo "should_create_version=false" >> $GITHUB_OUTPUT
  echo "Conflict: there is already a version associated to HEAD commit."
  exit 1
fi

# Get the last repository tag.
last_tag=$(git describe --tags --abbrev=0 2>/dev/null)

# If there is no tag in the repository, creates the first one.
if [ -z "$last_tag" ]; then
  new_tag="0.1.0"
  echo "There is no version associated with this program yet."
  echo "should_create_version=true" >> $GITHUB_OUTPUT
  echo "version=$new_tag" >> $GITHUB_OUTPUT
  echo "New generated version: $new_tag."
  exit 0
fi

echo "Last stable version: $last_tag."
echo "last_stable_version=$last_tag" >> $GITHUB_OUTPUT

# Slice the version into major, minor and patch parts.
regex="([0-9]+)\.([0-9]+)\.([0-9]+)"
if [[ $last_tag =~ $regex ]]; then
  major_version="${BASH_REMATCH[1]}"
  minor_version="${BASH_REMATCH[2]}"
  patch_version="${BASH_REMATCH[3]}"
fi

# Check if the required parameters were informed.
if [[ -z "$HEAD_COMMIT" ]]; then
    echo "'HEAD_COMMIT' is required."
    missing_parameter=true
fi

if [[ -z "$BASE_COMMIT" ]]; then
    echo "'BASE_COMMIT' is required."
    missing_parameter=true
fi

if [ "$missing_parameter" == true ]; then
  echo "should_create_version=false" >> $GITHUB_OUTPUT
  exit 1
fi

# Search for commits that contains BREAKING CHANGE message to increment the major version.
breaking_change_count=$(git log --format=%B $HEAD_COMMIT...$BASE_COMMIT | grep -c '^BREAKING CHANGE:.*')
if [[ $breaking_change_count -gt 0 ]]; then
  major_version=$((major_version + 1))
  new_tag="${major_version}.0.0"
  echo "A breaking change was identified."
  echo "should_create_version=true" >> $GITHUB_OUTPUT
  echo "version=$new_tag" >> $GITHUB_OUTPUT
  echo "New generated version: $new_tag."
  exit 0
fi

# Search for commits that contains FIRST RELEASE message to increment the major version.
if [ "$major_version" == 0 ]; then
  first_release_count=$(git log --format=%B $HEAD_COMMIT...$BASE_COMMIT | grep -c '^FIRST RELEASE:.*')
  if [[ $first_release_count -gt 0 ]]; then
    new_tag="1.0.0"
    echo "The initial major version was identified."
    echo "should_create_version=true" >> $GITHUB_OUTPUT
    echo "version=$new_tag" >> $GITHUB_OUTPUT
    echo "New generated version: $new_tag."
    exit 0
  fi
fi

if [[ -z "$ORIGIN_BRANCH" ]]; then
  echo "'ORIGIN_BRANCH' is required."
  echo "should_create_version=false" >> $GITHUB_OUTPUT
  exit 1
fi

# Increment the version according to the branch prefix.
if [[ $ORIGIN_BRANCH == "feature/"* ]]; then
  minor_version=$((minor_version + 1))
elif [[ $ORIGIN_BRANCH == "hotfix/"* ]]; then
  patch_version=$((patch_version + 1))
else
  echo "Invalid branch to automatically generate version."
  echo "should_create_version=false" >> $GITHUB_OUTPUT
  exit 1
fi

# Create the new tag version.
new_tag="${major_version}.${minor_version}.${patch_version}"
echo "should_create_version=true" >> $GITHUB_OUTPUT
echo "version=$new_tag" >> $GITHUB_OUTPUT
echo "New generated version: $new_tag."
