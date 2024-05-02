#!/bin/bash

readonly LAST_VERSION
readonly HEAD_COMMIT
readonly BASE_COMMIT
readonly ORIGIN_BRANCH
readonly FEATURE_BRANCHES
readonly RELEASE_BRANCHES
readonly HOTFIX_BRANCHES
readonly COMMIT_MESSAGE

is_missing() {
  [[ -z "${1}" ]]
}

is_valid_version() {
  [[ "${1}" =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]
}

is_breaking_change() {
  local regex='^BREAKING CHANGE:.*$|^.*[^[:space:]]+!:.*$'
  [[ "${1}" =~ $regex ]]
}

is_first_release() {
  local regex='^FIRST RELEASE:.*'
  [[ "${1}" =~ $regex ]]
}

is_non_public_version() {
  [[ "${1}" -eq 0 ]]
}

is_fix() {
  [[ "${1}" == 'fix:'* ]]
}

is_minor_change() {
  [[ $(is_in_branches_list "${2[@]}" "${1}") || $(is_in_branches_list "${3[@]}" "${1}") ]]
}

contains() {
  [[ "${1}" == "${2}/"*  ]]
}

check_commit_for_breaking_change() {
  if is_breaking_change "${1}"; then
    local major_version="${2}"
    major_version=$((major_version + 1))

    local new_tag="${major_version}.0.0"

    printf "A breaking change was identified.\n"
    printf "version=%s" "${new_tag}" >> "${GITHUB_OUTPUT}"
    printf "New generated version: %s.\n" "${new_tag}"
    exit 0
  fi
}

check_commit_for_first_release() {
  if is_first_release "${1}"; then
    if is_non_public_version "${2}"; then
      printf "The initial major version was identified.\n"
      printf "version=1.0.0" >> "${GITHUB_OUTPUT}"
      printf "New generated version: 1.0.0.\n"
      exit 0
    fi
  fi
}

check_commit_for_patch_change() {
  if is_fix "${1}"; then
    local patch_version="${4}"
    patch_version=$((patch_version + 1))

    local new_tag="${2}.${3}.${patch_version}"

    printf "A fix was identified.\n"
    printf "version=%s" "${new_tag}" >> "${GITHUB_OUTPUT}"
    printf "New generated version: %s.\n" "${new_tag}"
    exit 0
  fi
}

do_minor_change() {
  local minor_version="${2}"
  minor_version=$((minor_version + 1))
  local new_tag="${1}.${minor_version}.0"

  printf "A minor change was identified.\n"
  printf "version=%s" "${new_tag}" >> "${GITHUB_OUTPUT}"
  printf "New generated version: %s.\n" "${new_tag}"
  exit 0
}

check_pull_request_breaking_change() {
  breaking_change_count=$(git log --format=%B ${1}...${2} | grep -c "^BREAKING CHANGE:.*$|^.*[^[:space:]]+!:.*$")
  if [[ "${breaking_change_count}" -gt 0 ]]; then
    major_version="${3}"
    major_version=$((major_version + 1))
    new_tag="${major_version}.0.0"

    printf "A breaking change was identified.\n"
    printf "version=%s" "${new_tag}" >> "${GITHUB_OUTPUT}"
    printf "New generated version: %s.\n" "${new_tag}"
    exit 0
  fi
}

check_pull_request_for_first_release() {
  if is_non_public_version "${3}"; then
    local first_release_count=$(git log --format=%B ${1}...${2} | grep -c '^FIRST RELEASE:.*')
    if [[ "${first_release_count}" -gt 0 ]]; then
      printf "The initial major version was identified.\n"
      printf "version=1.0.0" >> "${GITHUB_OUTPUT}"
      printf "New generated version: 1.0.0.\n"
      exit 0
    fi
  fi
}

check_pull_request_for_minor_changes() {
  local feature_branches=("${2[@]}")

  if is_missing "${2}"; then
    feature_branches=("feature")
    printf "Feature branch names not found. Using default value: feature.\n"
  fi

  local release_branches=("${3[@]}")

  if is_missing "${3}"; then
    release_branches=("release")
    printf "Release branch names not found. Using default value: release.\n"
  fi

  if is_minor_change "${1}" "${feature_branches}" "${release_branches}"; then
    local minor_version="${4}"
    minor_version=$((minor_version + 1))

    local new_tag="${4}.${5}.0"
    printf "version=%s" "${new_tag}" >> "${GITHUB_OUTPUT}"
    printf "New generated version: %s.\n" "${new_tag}"
    exit 0
  fi
}

check_pull_request_for_patch_changes() {
  local hotfix_branches=("${2[@]}")

  if is_missing "${2}"; then
    hotfix_branches=("hotfix")
    printf "Hotfix branch names not found. Using default value: hotfix.\n"
  fi

  if $(is_in_branches_list "${hotfix_branches[@]}" "${1}"); then
    local patch_version="${5}"
    patch_version=$((patch_version + 1))

    local new_tag="${4}.${5}.${patch_version}"
    printf "version=%s" "${new_tag}" >> "${GITHUB_OUTPUT}"
    printf "New generated version: %s.\n" "${new_tag}"
    exit 0
  fi
}

is_in_branches_list() {
  local branches_list=("${1}")
  local is_feature_branch=false

  for i in "${branches_list[@]}"; do
    if contains "${2}" "${i}"; then
      return 0
    fi
  done

  return 1
}

get_version() {
  if is_missing "${LAST_VERSION}"; then
    printf "There is no version associated with this program yet.\n"
    printf "version=0.1.0" >> "${GITHUB_OUTPUT}"
    printf "New generated version: 0.1.0.\n"
    exit 0
  fi

  printf "Last stable version: %s.\n" "${LAST_VERSION}"

  if ! is_valid_version "${LAST_VERSION}"; then
    printf "The last found version does not match a valid semantic versioning pattern.\n"
    exit 1
  fi
  
  local major_version="${BASH_REMATCH[1]}"
  local minor_version="${BASH_REMATCH[2]}"
  local patch_version="${BASH_REMATCH[3]}"

  local missing_commit_sha=false

  if is_missing "${HEAD_COMMIT}"; then
    missing_commit_sha=true
  fi

  if is_missing "${BASE_COMMIT}"; then
    missing_commit_sha=true
  fi

  if [[ "${missing_commit_sha}" && $(is_missing "${COMMIT_MESSAGE}") ]]; then
    printf "You need to inform 'HEAD_COMMIT' and 'BASE_COMMIT' or inform 'COMMIT_MESSAGE' to proceed.\n"
    exit 1
  fi

  if [[ "${missing_commit_sha}" ]]; then
    check_commit_for_breaking_change "${COMMIT_MESSAGE}" "${major_version}"
    check_commit_for_first_release "${COMMIT_MESSAGE}" "${major_version}"
    check_commit_for_patch_change "${COMMIT_MESSAGE}" "${major_version}" "${minor_version}" "${patch_version}"
    do_minor_change "${major_version}" "${minor_version}"
  fi

  check_pull_request_for_breaking_change "${HEAD_COMMIT}" "${BASE_COMMIT}" "${major_version}"
  check_pull_request_for_first_release "${HEAD_COMMIT}" "${BASE_COMMIT}" "${major_version}"

  if is_missing "${ORIGIN_BRANCH}"; then
    printf "'ORIGIN_BRANCH' is required.\n"
    exit 1
  fi

  check_pull_request_for_minor_changes "${ORIGIN_BRANCH}" "${FEATURE_BRANCHES}" "${RELEASE_BRANCHES}" "${major_version}" "${minor_version}"
  check_pull_request_for_patch_changes "${ORIGIN_BRANCH}" "${HOTFIX_BRANCHES}" "${major_version}" "${minor_version}" "${patch_version}"

  printf "Invalid branch to automatically generate version.\n"
  exit 1
}

get_version
