#!/usr/bin/env bash

# Create optimized (read smaller font files)
# Based on https://www.zachleat.com/web/css-tricks-web-fonts/ w/o the second
# stage JS part.

# For the fonts currently in the repo:
# $ LAYOUT_FEATURES=kern,frac,mark ./optimize-font-files.sh fonts/basiersquare static/fonts/basiersquare
# $ LAYOUT_FEATURES=frac,mark ./optimize-font-files.sh fonts/basiersquaremono static/fonts/basiersquaremono

# This can take a while.

set -eu -o pipefail
# set -x

UNICODE_RANGE='U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+2000-206F,U+2074,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD'

# Adapt based on what's available in each font and what you want.
# You can use https://wakamaifondue.com/ to inspect the source files.
LAYOUT_FEATURES=${LAYOUT_FEATURES:-''}
SOURCE_EXT=${SOURCE_EXT:-"woff2"}

pip install fonttools brotli

mkdir -p "${2}"
rm -rf "${2}/*.woff*"

for source_file in "${1}"/*."${SOURCE_EXT}"; do

  name=$(basename "${source_file%.*}")
  echo "Optimizing ${name}"

  pyftsubset \
    "${source_file}" \
    --flavor=woff2 \
    --output-file="${2}/${name}.woff2" \
    --layout-features="${LAYOUT_FEATURES}" \
    --no-hinting \
    --desubroutinize \
    --unicodes=$UNICODE_RANGE

  pyftsubset \
    "${source_file}" \
    --flavor=woff \
    --output-file="${2}/${name}.woff" \
    --layout-features="${LAYOUT_FEATURES}" \
    --no-hinting \
    --desubroutinize \
    --unicodes=$UNICODE_RANGE
done
