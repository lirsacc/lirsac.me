#!/usr/bin/env bash

node build --prod

tmp_dir=`mktemp -d /tmp/build-lirsac.me-XXXX`

mv _site/* $tmp_dir
shopt -s extglob
rm -r !(.|..|.git*|node_modules)
git checkout gh-pages
mv $tmp_dir/* .
git add .
git commit -m "[Auto] gh-pages updated on $(date)"
git push origin gh-pages --force
rm -r !(.|..|.git*|node_modules)
git checkout master

shopt -u extglob
rm -rf $tmp_dir
