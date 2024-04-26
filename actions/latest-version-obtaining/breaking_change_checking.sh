#!/bin/bash

regex="([0-9]+)\.([0-9]+)\.([0-9]+)"

if [[ $VERSION =~ $regex ]]; then
  major_version="${BASH_REMATCH[1]}"
  minor_version="${BASH_REMATCH[2]}"
  patch_version="${BASH_REMATCH[3]}"

  if [[ $major_version > 0 ]]; then
    if [[ $minor_version == 0 && $patch_version == 0 ]]; then
      echo "is_breaking_change=true" >> $GITHUB_OUTPUT
      echo "The last found version is breaking change."
      exit 0
    fi
  fi
fi

echo "The last found version is not breaking change."
exit 0
