#!/usr/bin/env bash

set -e

PRODUCT_VERSION=$1
DOWNLOAD_FOLDER="$(mktemp -d)"

VALIDATE_IF_OPENSEARCH_IS_ALREADY_INSTALLED() {
  if [[ -f "opensearch" ]] ; then
    exit 0
  fi
}

DOWNLOAD_OPENSEARCH_MODULES() {
  local URL="https://releases.liferay.com/opensearch2/dxp/${PRODUCT_VERSION}"

  if curl -sL -f \
    --output-dir "${DOWNLOAD_FOLDER}" \
    -O \
    --retry 5 \
    --retry-delay 2 \
    --retry-all-errors \
    "$URL"; then
      echo "Success: Product version ${PRODUCT_VERSION} installed."
  else
    local EXIT_CODE=$?
    echo "Error: Failed to download Opensearch modules (Exit code: ${EXIT_CODE})."
    exit 1
  fi
}

MAIN() {
  VALIDATE_IF_OPENSEARCH_IS_ALREADY_INSTALLED "$PRODUCT_VERSION"
  DOWNLOAD_OPENSEARCH_MODULES "$PRODUCT_VERSION"

  mv "${DOWNLOAD_FOLDER}"/* "/mnt/deploy"
}

MAIN "$PRODUCT_VERSION"