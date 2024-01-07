#!/usr/bin/env bash

set -ex

BASE=$(realpath $(dirname $0)/..)
BUILDDIR=${BASE}/build
IMAGE=finwo/haraka

function install_versioned {
  export PATCH=$1
  export MINOR=${PATCH%.*}
  export MAJOR=${MINOR%.*}
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
    echo "Processing $tag"

    # Reset build dir
    # Side-effect: defined MAJOR,MINOR,PATCH
    rm -rf ${BUILDDIR}
    mkdir -p ${BUILDDIR}/config
    install_versioned ${tag} Dockerfile
    install_versioned ${tag} entrypoint.sh

    # Fetch deps for the dockerfile
    curl -sL https://raw.githubusercontent.com/haraka/Haraka/${tag}/config/plugins   > ${BUILDDIR}/config/plugins
    curl -sL https://raw.githubusercontent.com/haraka/Haraka/${tag}/config/host_list > ${BUILDDIR}/config/host_list

    cd ${BUILDDIR}
    docker build -t ${IMAGE}:${MAJOR} -t ${IMAGE}:${MINOR} -t ${IMAGE}:${PATCH} -t ${IMAGE}:latest . || continue
    docker push ${IMAGE}:${PATCH} || continue
    docker push ${IMAGE}:${MINOR} || continue
    docker push ${IMAGE}:${MAJOR} || continue
    docker push ${IMAGE}:latest || continue
    cd ${BASE}

    cat ${BUILDDIR}/Dockerfile

  done
