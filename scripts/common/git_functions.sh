#!/bin/bash

git_config() {
  local email=$1
  local username=$2
  git config --global user.email "$email"
  git config --global user.name "$username"
}

git_list_tags() {
  git_tags=$(git tag --sort=version:refname)
  git_latest_tag=$(echo "$git_tags" | tail -n 1)

  if [ -z "$git_latest_tag" ]; then
    git_latest_tag="v0.0.0"
  fi

  git_latest_tag=$(echo "$git_latest_tag" | sed 's/^v//')
}

git_patch_type() {
  version_type="${1-}"
  version_next=""

  if [ "$version_type" = "patch" ]; then
    version_next="$(echo "$git_latest_tag" | awk -F. '{$NF++; print $1"."$2"."$NF}')"

  elif [ "$version_type" = "minor" ]; then
    version_next="$(echo "$git_latest_tag" | awk -F. '{$2++; $3=0; print $1"."$2"."$3}')"

  elif [ "$version_type" = "major" ]; then
    version_next="$(echo "$git_latest_tag" | awk -F. '{$1++; $2=0; $3=0; print $1"."$2"."$3}')"

  else
    printf "\nError: invalid version_type arg passed, must be 'patch', 'minor' or 'major'\n\n"
    exit 1

  fi
}

git_publish_tag() {
  commit_id_short=$(git rev-parse --short HEAD) || echo "Failed to get commit ID"
  commit_message=$(git log --format=%s -n 1 "${commit_id_short}") || echo "Failed to get commit message"

  git tag -a "v$version_next" "${commit_id_short}" -m "${commit_message}"
  git push origin "v$version_next"
}