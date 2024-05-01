#!/bin/bash

readonly VERSION

is_breaking_change() {
  [[ "${1}" -gt 0 && "${2}" -eq 0 && "${3}" -eq 0 ]]
}

is_valid_version() {
  [[ "${1}" =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]
}

check() {
  local version="${1}"
  readonly version

  if is_valid_version "${version}"; then
    local major_version="${BASH_REMATCH[1]}"
    local minor_version="${BASH_REMATCH[2]}"
    local patch_version="${BASH_REMATCH[3]}"

    if is_breaking_change "${major_version}" "${minor_version}" "${patch_version}"; then
      echo "is_breaking_change=true" >> "${GITHUB_OUTPUT}"
      printf "Version %s is breaking change.\n" "${version}"
      exit 0
    fi
  fi

  printf "Version %s is not breaking change.\n" "${version}"
  exit 0
}

check "${VERSION}"
