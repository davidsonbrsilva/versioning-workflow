#!/bin/bash

# If there is no tag in the repository, creates the first one.
if [ -z "$LAST_VERSION" ]; then
  new_tag="0.1.0"
  echo "There is no version associated with this program yet."
  echo "version=$new_tag" >> $GITHUB_OUTPUT
  echo "New generated version: $new_tag."
  exit 0
fi

echo "Last stable version: $LAST_VERSION."

# Slice the version into major, minor and patch parts.
regex="([0-9]+)\.([0-9]+)\.([0-9]+)"

if [[ $LAST_VERSION =~ $regex ]]; then
  major_version="${BASH_REMATCH[1]}"
  minor_version="${BASH_REMATCH[2]}"
  patch_version="${BASH_REMATCH[3]}"
else
  echo "The last found version does not match a valid semantic versioning pattern."
  exit 1
fi

# Check if the required parameters were informed.
if [[ -z "$HEAD_COMMIT" ]]; then
    missing_parameter=true
fi

if [[ -z "$BASE_COMMIT" ]]; then
    missing_parameter=true
fi

if [ "$missing_parameter" == true ]; then
  if [[ -z "$COMMIT_MESSAGE" ]]; then
    echo "You need to inform 'HEAD_COMMIT' and 'BASE_COMMIT' or inform 'COMMIT_MESSAGE' to proceed."
    exit 1
  fi

  # Check if the commit message is breaking change.
  breaking_change_regex="^BREAKING CHANGE:.*$|^[^\s]+!:.*$"

  if [[ $COMMIT_MESSAGE =~ breaking_change_regex ]]; then
    major_version=$((major_version + 1))
    new_tag="${major_version}.0.0"
    echo "A breaking change was identified."
    echo "version=$new_tag" >> $GITHUB_OUTPUT
    echo "New generated version: $new_tag."
    exit 0
  fi

  # Check if the commit message is first release.
  if [[ $COMMIT_MESSAGE == 'FIRST RELEASE:'* ]]; then
    if [ "$major_version" == 0 ]; then
      new_tag="1.0.0"
      echo "The initial major version was identified."
      echo "version=$new_tag" >> $GITHUB_OUTPUT
      echo "New generated version: $new_tag."
      exit 0
    fi
  fi

  # Check if the commit message is from a hotfix
  if [[ $COMMIT_MESSAGE == 'fix:'* ]]; then
    patch_version=$((patch_version + 1))
  else
    minor_version=$((minor_version + 1))
    patch_version=0
  fi

  # Create the new tag version.
  new_tag="${major_version}.${minor_version}.${patch_version}"
  echo "version=$new_tag" >> $GITHUB_OUTPUT
  echo "New generated version: $new_tag."
  exit 0
fi

# Search for commits that contains BREAKING CHANGE message to increment the major version.
breaking_change_count=$(git log --format=%B $HEAD_COMMIT...$BASE_COMMIT | grep -c "$breaking_change_regex")
if [[ $breaking_change_count -gt 0 ]]; then
  major_version=$((major_version + 1))
  new_tag="${major_version}.0.0"
  echo "A breaking change was identified."
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
    echo "version=$new_tag" >> $GITHUB_OUTPUT
    echo "New generated version: $new_tag."
    exit 0
  fi
fi

if [[ -z "$ORIGIN_BRANCH" ]]; then
  echo "'ORIGIN_BRANCH' is required."
  exit 1
fi

# Increment the version according to the branch prefix.
if [[ $ORIGIN_BRANCH == "feature/"* ]]; then
  minor_version=$((minor_version + 1))
  patch_version=0
elif [[ $ORIGIN_BRANCH == "hotfix/"* ]]; then
  patch_version=$((patch_version + 1))
else
  echo "Invalid branch to automatically generate version."
  exit 1
fi

# Create the new tag version.
new_tag="${major_version}.${minor_version}.${patch_version}"
echo "version=$new_tag" >> $GITHUB_OUTPUT
echo "New generated version: $new_tag."
