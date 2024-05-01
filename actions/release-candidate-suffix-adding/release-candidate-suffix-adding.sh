readonly VERSION

is_release_candidate() {
  [[ "${1}" =~ ([0-9]+)\.([0-9]+)\.([0-9]+)-rc-([0-9]+) ]]
}

fail_to_fetch() {
  printf "Failed to fetch tags from remote.\n"
  exit 1
}

fetch_tags_from_remote() {
  git fetch --unshallow origin --tags > /dev/null 2>&1 || fail_to_fetch
}

get_last_among_release_candidates() {
  git tag -l "${1}*" | sort -V | tail -n 1
}

add_release_candidate_suffix() {
  fetch_tags_from_remote

  version=$(get_last_among_release_candidates "${1}")

  local new_tag="${version}-rc-1"

  if is_release_candidate "${version}"; then
    local major_version="${BASH_REMATCH[1]}"
    local minor_version="${BASH_REMATCH[2]}"
    local patch_version="${BASH_REMATCH[3]}"
    local rc_version="${BASH_REMATCH[4]}"

    rc_version=$((rc_version + 1))

    new_tag=${major_version}.${minor_version}.${patch_version}-rc-${rc_version}
  fi

  printf "version=%s" "${new_tag}" >> "${GITHUB_OUTPUT}"
  printf "New generated version: %s.\n" "${new_tag}"
}

add_release_candidate_suffix "${VERSION}"
