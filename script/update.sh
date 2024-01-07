#!/usr/bin/env bash

# Fetch all tags
curl -sL https://api.github.com/repos/haraka/haraka/tags | \
  jq -r '.[]|[.name, .commit.url] | @tsv' | \
  sort | \
  while IFS=$'\t' read -r tag tagurl; do

    if [[ $(curl -sL $tagurl | jq -r "((now - (.commit.author.date | fromdateiso8601) )  / (60*60)  | trunc)") -gt 36 ]]; then
      echo "tag $tag is stale, skipping"
      # continue
    fi


    minortag=${tag%.*}
    majortag=${minortag%.*}

    echo "Processing $tag, $minortag, $majortag"
  done
