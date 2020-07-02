#!/usr/bin/env bash

_exit() {
  echo "$1" >&2
  exit "${2:-1}"
}

REPO=getzola/zola
VERSION=latest

# Guess Zola location,
# prefers globally installed Zola and falls back to local install.
find_command() {
  if command zola; then
    echo "Using zola install from \$PATH..." >&2
    cmd="zola"
  else
    echo "No zola install found in \$PATH, attempting to load local binary..." >&2
    if [[ ! -f ./zola ]]; then
      echo 'Downloading from Github...' >&2
      archive="$(./download-github-release.sh ${REPO} ${VERSION})"
      echo 'Extracting archive...' >&2
      tar -xf "${archive}"
      [[ -f ./zola ]] || _exit "zola binary not found after download!"
      chmod +x ./zola
    else
      echo "Found existing local binary at '$(realpath ./zola)'..." >&2
    fi
    cmd="./zola"
  fi
  echo "${cmd}"
}

cmd=$(find_command)
${cmd} --version

[[ -n "${cmd}" ]] || _exit "Zola is not available!"

echo

if [ "$1" = "--watch" ]; then
  "${cmd}" serve "${@:2}"
else
  "${cmd}" build "${@}"
fi
