#!/usr/bin/env bash

# check for brew and mackup
if ! [hash brew 2>/dev/null]; then
  echo "Please install homebrew"
  echo '$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  if ! [hash mackup 2>/dev/null]; then
    echo "installing mackup"
    brew install mackup
  fi
else
  echo "Restoring from backup."
  mackup restore
fi