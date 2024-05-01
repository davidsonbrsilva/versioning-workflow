#!/bin/bash

readonly GITHUB_REPOSITORY
readonly GITHUB_TOKEN
readonly VERSION
readonly TARGET_COMMIT
readonly RELEASE_NAME
readonly PRE_RELEASE

is_missing() {
  [[ -z "${1}" ]]
}

is_pre_release() {
  [[ "${1}" == "true" ]]
}

is_release_created() {
  [ "${1}" -eq "201" ]
}

check_required_parameters() {
  local missing_parameter=false

  if is_missing "${GITHUB_REPOSITORY}"; then
    printf "'GITHUB_REPOSITORY' is required."
    missing_parameter=true
  fi

  if is_missing "${GITHUB_TOKEN}"; then
    printf "'GITHUB_TOKEN' is required."
    missing_parameter=true
  fi

  if is_missing "${VERSION}"; then
    printf "'VERSION' is required."
    missing_parameter=true
  fi

  if is_missing "${TARGET_COMMIT}"; then
    printf "'TARGET_COMMIT' is required."
    missing_parameter=true
  fi

  if [ "${missing_parameter}" == true ]; then
    exit 1
  fi
}

create_release() {
  check_required_parameters

  local release_name="${RELEASE_NAME}"

  if is_missing "${RELEASE_NAME}"; then
    release_name="${VERSION}"
  fi

  local pre_release="${PRE_RELEASE}"

  if ! is_pre_release "${PRE_RELEASE}"; then
    pre_release="false"
  fi

  local url="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases"

  local response_code=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
      \"tag_name\": \"${VERSION}\",
      \"target_commitish\": \"${TARGET_COMMIT}\",
      \"name\": \"${release_name}\",
      \"draft\": false,
      \"prerelease\": ${pre_release},
      \"generate_release_notes\": true
    }" \
    ${url})

  if is_release_created "${response_code}"; then
    printf "version=%s" "${VERSION}" >> "${GITHUB_OUTPUT}"
    printf "New generated release: %s\n" "${VERSION}"
    exit 0
  fi

  printf "Failed to generate release."
  exit 1
}

create_release
