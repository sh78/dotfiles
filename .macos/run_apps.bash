#!/usr/bin/env bash

apps=(
    "1Password"
    "Bartender 3"
    "Chrome"
    "iTerm"
    "mac2imgur"
    "Utilities/NoSleep"
    "Spectacle"
    "Sublime Text"
    "TextExpander"
    "System Preferences"
)

for app in ${apps[@]}; do
    open "/Applications/$app.app"
done

open "https://packagecontrol.io/installation"

echo "opening chunkwm tiling window manager and khd..."
brew services start crisidev/chunkwm/chunkwm
brew services start koekeishiya/formulae/khd

echo "Installing bundles in vim..."
vim +BundleInstall
nvim +BundleInstall

echo "Setting up phpcd linting..."
pushd ~/.vim/bundle/phpcd.vim/ && composer update && pushd
pushd ~/.vim/bundle/phpcd.vim/vendor/lvht/msgpack-rpc/ && and composer update && pushd
