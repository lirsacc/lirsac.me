#!/usr/bin/env bash

_exit() {
  echo "$1" >&2
  exit "${2:-1}"
}

REPO=keats/gutenberg
VERSION=latest

# Guess gutenberg location,
# prefers globally installed gutenberg and falls back to local install.
find_gutenberg_command() {
  if which gutenberg; then
    echo "Using gutenber install from \$PATH..." >&2
    cmd="gutenberg"
  else
    echo "No gutenberg install found in \$PATH, attempting to load local binary..." >&2
    if [[ ! -f ./gutenberg ]]; then
      echo 'Downloading from Github...' >&2
      archive="$(./download-github-release.sh ${REPO} ${VERSION})"
      echo 'Extracting archive...' >&2
      tar -xf "${archive}"
      [[ -f ./gutenberg ]] || _exit "Gutenberg binary not found after download!"
      chmod +x ./gutenberg
    else
      echo "Found existing local binary at '$(realpath ./gutenberg)'..." >&2
    fi
    cmd="./gutenberg"
  fi
  echo "${cmd}"
}

cmd=$(find_gutenberg_command)
${cmd} --version

[[ ! -z "${cmd}" ]] || _exit "Gutenberg is not available!"

echo

if [ "$1" = "--watch" ]; then
  "${cmd}" serve "${@:2}"
else
  "${cmd}" build "${@}"
fi
