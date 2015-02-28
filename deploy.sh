#!/usr/bin/env bash

target="lirsacc/lirsac.me.git"

if [ "$TRAVIS" == "true" ]; then
  echo "Deploying from Travis..."
  git config user.name "lirsacc (travis ci)"
  git config user.email "c.lirsac@gmail.com"
  repo=https://$GITHUB_TOKEN@github.com/$target
fi

./build-gh-pages.sh

if [ "$TRAVIS" == "true" ]; then
  git push -fq $repo gh-pages:gh-pages > /dev/null
else
  read -p "Manually push changes to GitHub Pages branch? [y/N] " response
  if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
    git push -f origin gh-pages
  fi
fi

echo "Deployed gh-pages"
