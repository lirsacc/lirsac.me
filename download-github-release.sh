#!/usr/bin/env bash
#
# Download the latest release archive from a github project.
# ==========================================================
#
# Credit: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8,
# adapted to use only curl and use predictable filenames.
#

# Specific to the project you are downloading, with most projects
# binaries 'windows', 'darwin' and 'gnu' or 'linux' should do the trick.
# If this markers matches multiple entries, the script only considers the first
# one.
if uname | grep -qi darwin; then
  ARCHIVE_MARKER=darwin
else
  ARCHIVE_MARKER=linux
fi

url=$(\
  curl -s "https://api.github.com/repos/${1?Missing first argument REPO}/releases/${2:-latest}" | \
  grep -i "browser_download_url.*${ARCHIVE_MARKER}" | \
  cut -d '"' -f 4 | \
  head -n 1)

# Assumes that the Content-Disposition header and
# the last part of the url match
filename=$(echo "${url}" | rev | cut -s -d "/" -f 1 | rev)

rm -rf "${filename}"

curl -sOJL "${url}"

# In case you want to do something with the archive,
# just pipe the output of this script
echo "${filename}"
