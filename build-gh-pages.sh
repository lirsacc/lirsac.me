#!/usr/bin/env bash

echo "Building gh-pages branch"

[[ $TRAVIS_BUILD_NUMBER ]] && build_id=$TRAVIS_BUILD_NUMBER || build_id="LOCAL"

node build --prod

shopt -s extglob

revision=`git rev-parse HEAD`

tmp_dir=`mktemp -d /tmp/build-lirsac.me-XXXX`
mv _site/* $tmp_dir

git checkout -B gh-pages origin/gh-pages > /dev/null 2>&1

rm -r !(.|..|.git*|node_modules)
mv -f $tmp_dir/* .
git status -s
git add -A .  > /dev/null 2>&1
git commit --allow-empty -m "[BUILD $build_id] gh-pages updated on $(date) @ $revision"  > /dev/null 2>&1

shopt -u extglob
rm -rf $tmp_dir

echo "Finished building gh-pages branch"
