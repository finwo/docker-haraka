#!/usr/bin/env bash

curl https://api.github.com/repos/haraka/haraka/tags | \
  jq -r '.[]|[.name, .commit.url] | @tsv' \
  while IFS=$'\t' read -r tag tagurl; do
    echo "tag   : $tag"
    echo "tagurl: $tagurl"
    echo "---"
  done
