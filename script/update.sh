#!/usr/bin/env bash

BASE=$(realpath $(dirname $0)/..)
BUILDDIR=${BASE}/build

function install_versioned {
  PATCH=$1
  MINOR=${TAG%.*}
  MAJOR=${MINOR%.*}
  FILENAME=$2
  mkdir -p $(dirname "${BUILDDIR}/${FILENAME}")

  if [ -d "${BASE}/dckr/${PATCH}/${FILENAME}" ]; then
    cp -r "${BASE}/dckr/${PATCH}/${FILENAME}" "${BUILDDIR}/${FILENAME}"
  elif [ -f "${BASE}/dckr/${PATCH}/${FILENAME}" ]; then
    cat "${BASE}/dckr/${PATCH}/${FILENAME}" | envsubst '${MAJOR},${MINOR},${PATCH}' > "${BUILDDIR}/${FILENAME}"

  elif [ -d "${BASE}/dckr/${MINOR}/${FILENAME}" ]; then
    cp -r "${BASE}/dckr/${MINOR}/${FILENAME}" "${BUILDDIR}/${FILENAME}"
  elif [ -f "${BASE}/dckr/${MINOR}/${FILENAME}" ]; then
    cat "${BASE}/dckr/${MINOR}/${FILENAME}" | envsubst '${MAJOR},${MINOR},${PATCH}' > "${BUILDDIR}/${FILENAME}"

  elif [ -d "${BASE}/dckr/${PATCH}/${FILENAME}" ]; then
    cp -r "${BASE}/dckr/${PATCH}/${FILENAME}" "${BUILDDIR}/${FILENAME}"
  elif [ -f "${BASE}/dckr/${PATCH}/${FILENAME}" ]; then
    cat "${BASE}/dckr/${PATCH}/${FILENAME}" | envsubst '${MAJOR},${MINOR},${PATCH}' > "${BUILDDIR}/${FILENAME}"

  elif [ -d "${BASE}/dckr/default/${FILENAME}" ]; then
    cp -r "${BASE}/dckr/default/${FILENAME}" "${BUILDDIR}/${FILENAME}"
  elif [ -f "${BASE}/dckr/default/${FILENAME}" ]; then
    cat "${BASE}/dckr/default/${FILENAME}" | envsubst '${MAJOR},${MINOR},${PATCH}' > "${BUILDDIR}/${FILENAME}"

  else
    echo "${FILENAME} could not be found" >&2
    exit 1
  fi

}

# Fetch all tags
curl -sL https://api.github.com/repos/haraka/haraka/tags | \
  jq -r '.[]|[.name, .commit.url] | @tsv' | \
  sort | \
  while IFS=$'\t' read -r tag tagurl; do

    # Skip tag if it's older than 36 hours
    # Will push a tag twice, should fix later
    if [[ $(curl -sL $tagurl | jq -r "((now - (.commit.author.date | fromdateiso8601) )  / (60*60)  | trunc)") -gt 36 ]]; then
      echo "tag $tag is stale, skipping"
      # continue
    fi

    # # Destructure tag into major/minor/patch
    # minortag=${tag%.*}
    # majortag=${minortag%.*}

    # Reset build dir
    rm -rf ${BUILDDIR}
    mkdir -p ${BUILDDIR}
    install_versioned ${tag} Dockerfile
    install_versioned ${tag} haraka.sh

    tree ${BUILDDIR}

    cat ${BUILDDIR}/Dockerfile

    echo "Processing $tag"
  done
