#!/bin/bash

regex="([0-9]+)\.([0-9]+)\.([0-9]+)-rc-([0-9]+)"

if [[ $VERSION =~ $regex ]]; then
  echo "is_release_candidate=true" >> $GITHUB_OUTPUT
  echo "The last version found is release candidate."
else
  echo "The last version found is not release candidate."
fi
