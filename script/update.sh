#!/usr/bin/env bash

# Fetch all tags
curl -sL https://api.github.com/repos/haraka/haraka/tags | \
  jq -r '.[]|[.name, .commit.url] | @tsv' | \
  sort | \
  while IFS=$'\t' read -r tag tagurl; do

    if [[ $(curl -sL $tagurl | jq -r "((now - (.commit.author.date | fromdateiso8601) )  / (60*60)  | trunc)") -lt 36 ]]; then
      echo "tag $tag is fresh"
    else
      echo "tag $tag is stale"
    fi
    echo "---"
  done
