#!/usr/bin/env bash

target="lirsacc/lirsac.me.git"

if [ "$TRAVIS" == "true" ]; then
  echo "Deploying from Travis..."
  git config user.name "lirsacc (travis ci)"
  git config user.email "c.lirsac@gmail.com"
  repo=https://$GITHUB_TOKEN@github.com/$target
  git remote rename origin origin.bak > /dev/null 2>&1
  git remote add origin $repo > /dev/null 2>&1
  git remote remove origin.bak > /dev/null 2>&1
  git fetch --all > /dev/null 2>&1
fi

./build-gh-pages.sh > /dev/null 2>&1

if [ "$TRAVIS" == "true" ]; then
  git push --force --quiet $repo gh-pages:gh-pages > /dev/null 2>&1
else
  read -p "Manually push changes to GitHub Pages branch? [y/N] " response
  if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
    git push --force origin gh-pages
  fi
fi

echo "Deployed gh-pages"
