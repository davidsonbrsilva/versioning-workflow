#!/bin/bash

readonly ORIGIN_BRANCH
readonly MAIN_BRANCH

is_missing() {
  [[ -z "${1}" ]]
}

fail_to_fetch() {
  printf "Failed to fetch tags from remote.\n"
  exit 1
}

fetch_tags_from_remote() {
  git fetch --unshallow origin --tags > /dev/null 2>&1 || fail_to_fetch
}

get_last_origin_branch_version() {
  git tag --sort=committerdate --merged=$(git rev-parse "origin/${1}") | grep -v '^v' | tail --lines 1
}

get_last_repository_version() {
  git tag --sort=committerdate | grep -v '^v' | tail --lines 1
}

is_version_published() {
  result=$(git branch --all --contains "${1}" | grep "origin/${2}")
  [[ -n "${result}" ]]
}

get_newest_version_between() {
  printf "%s\n%s\n" "${1}" "${2}" | sort --version-sort | tail --lines 1
}

get_last_version() {
  local origin_branch="${1}"
  local main_branch="${2}"

  if is_missing "${origin_branch}"; then
    printf "Origin branch is required.\n"
    exit 1
  fi

  if is_missing "${main_branch}"; then
    main_branch="main"
  fi

  fetch_tags_from_remote

  local last_origin_branch_version=$(get_last_origin_branch_version "${origin_branch}")
  local last_repository_version=$(get_last_repository_version)

  printf "Last branch version: ${last_origin_branch_version}\n"
  printf "Last repository version: ${last_repository_version}\n"

  local version=$(get_newest_version_between "${last_origin_branch_version}" "${last_repository_version}")

  if is_version_published "${last_origin_branch_version}" "${main_branch}"; then
    version="${last_origin_branch_version}"
    printf "The origin branch version is in '%s'.\n" "${main_branch}"
  fi

  if is_version_published "${last_repository_version}" "${main_branch}"; then
    version="${last_repository_version}"
    printf "The repository version is in '%s'.\n" "${main_branch}"
  fi

  if is_missing "${version}"; then
    printf "No found version associated with this branch.\n"
    exit 0
  fi

  printf "last_version=%s\n" "${version}" >> "${GITHUB_OUTPUT}"
  printf "Choosen version: %s.\n" "${version}"
  exit 0
}

get_last_version "${ORIGIN_BRANCH}" "${MAIN_BRANCH}"
