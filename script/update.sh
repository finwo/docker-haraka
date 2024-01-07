#!/usr/bin/env bash

# Fetch all tags
curl -sL https://api.github.com/repos/haraka/haraka/tags | \
  jq -r '.[]|[.name, .commit.url] | @tsv' | \
  sort | \
  while IFS=$'\t' read -r tag tagurl; do
    echo "tag   : $tag"
    echo "tagurl: $tagurl"
    echo "---"
  done
