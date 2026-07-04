#!/usr/bin/env bash

set -eu -o pipefail

declare -r target_dir="${1:?missing target_dir}"

if [[ -z "$(git status --porcelain "${target_dir}/")" ]]; then
  echo >&2 "OK: No modifications detected in the target path"
  exit 0
fi

echo "Error: Working directory is dirty! The generation command introduced
unexpected modifications or untracked files. Run the generator locally, commit
the resulting changes, and try again."

git diff "${target_dir}/"
git status --porcelain "${target_dir}/"

exit 1
