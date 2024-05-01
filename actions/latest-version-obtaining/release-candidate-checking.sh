#!/bin/bash

readonly VERSION

is_release_candidate() {
  [[ "${1}" =~ ([0-9]+)\.([0-9]+)\.([0-9]+)-rc-([0-9]+) ]]
}

check() {
  if is_release_candidate "${1}"; then
    printf "is_release_candidate=true" >> "${GITHUB_OUTPUT}"
    printf "The last version found is release candidate.\n"
    exit 0
  fi

  printf "The last version found is not release candidate."
  exit 0
}

check "${VERSION}"
