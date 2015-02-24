#!/usr/bin/env bash

node build --prod

tmp_dir=`mktemp -d /tmp/build-lirsac.me-XXXX`

mv _site/* $tmp_dir
shopt -s extglob
rm -r !(.|..|.git*|node_modules)
git checkout -B gh-pages
mv $tmp_dir/* .
git commit -am "[Auto] gh-pages updated on $(date)"
# git push origin gh-pages --force
rm -r !(.|..|.git*|node_modules)
git checkout master

shopt -u extglob
rm -rf $tmp_dir
