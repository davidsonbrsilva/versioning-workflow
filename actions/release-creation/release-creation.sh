#!/bin/bash

readonly GITHUB_REPOSITORY
readonly GITHUB_TOKEN
readonly VERSION
readonly TARGET_COMMIT
readonly RELEASE_NAME
readonly PRE_RELEASE
readonly USE_V_PREFIX
readonly RELEASE_NAME
readonly RELEASE_NAME_PREFIX

is_missing() {
  [[ -z "${1}" ]]
}

is_to_use_v_prefix() {
  [[ "${1}" == "true" ]]
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

  local version="${VERSION}"

  if is_to_use_v_prefix "${USE_V_PREFIX}"; then
    version="v${VERSION}"
  fi

  local release_name="${RELEASE_NAME}"

  if is_missing "${RELEASE_NAME}"; then
    release_name="${version}"
  fi

  if ! is_missing "${RELEASE_NAME_PREFIX}"; then
    release_name="${RELEASE_NAME_PREFIX} ${release_name}"
  fi

  local pre_release="${PRE_RELEASE}"

  if ! is_pre_release "${PRE_RELEASE}"; then
    pre_release="false"
  fi

  local url="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases"

  local response_code=$(curl -s -o -w "%{http_code}" \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
      \"tag_name\": \"${version}\",
      \"target_commitish\": \"${TARGET_COMMIT}\",
      \"name\": \"${release_name}\",
      \"draft\": false,
      \"prerelease\": ${pre_release},
      \"generate_release_notes\": true
    }" \
    ${url})

  if is_release_created "${response_code}"; then
    printf "version=%s" "${version}" >> "${GITHUB_OUTPUT}"
    printf "New generated release: %s\n" "${version}"
    exit 0
  fi

  printf "Failed to generate release."
  exit 1
}

create_release
