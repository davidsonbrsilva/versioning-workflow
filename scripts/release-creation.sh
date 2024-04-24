#!/bin/bash

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "'GITHUB_TOKEN' is required."
  missing_parameter=true
fi

if [[ -z "$VERSION" ]]; then
  echo "'VERSION' is required."
  missing_parameter=true
fi

if [[ -z "$TARGET_COMMIT" ]]; then
  echo "'TARGET_COMMIT' is required."
  missing_parameter=true
fi

if [ "$missing_parameter" == true ]; then
  exit 1
fi

if [[ -z "$RELEASE_NAME" ]]; then
  RELEASE_NAME=$VERSION
fi

if [[ "$PRE_RELEASE" != "true" ]]; then
  PRE_RELEASE="false"
fi

# URL da API de releases
URL="https://api.github.com/repos/$GITHUB_REPOSITORY/releases"

# Criar uma release
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"tag_name\": \"$VERSION\",
    \"target_commitish\": \"$TARGET_COMMIT\",
    \"name\": \"$RELEASE_NAME\",
    \"draft\": false,
    \"prerelease\": $PRE_RELEASE,
    \"generate_release_notes\": true
  }" \
  $URL)

if [ "$RESPONSE_CODE" -eq "201" ]; then
  echo "New generated release: $RELEASE_NAME"
  exit 0
fi

echo "Failed to generate release."
exit 1
