#!/usr/bin/env bash

# Apps that need some manual loving
apps=(
    "1Password"
    "Bartender 3"
    "iTerm"
    "Sublime Text"
    "TextExpander"
)

for app in ${apps[@]}; do
    open "/Applications/$app.app"
done

open "https://packagecontrol.io/installation"

echo "opening chunkwm tiling window manager and khd..."
brew services start crisidev/chunkwm/chunkwm
brew services start koekeishiya/formulae/khd

echo "Installing bundles in vim..."
vim +PlugInstall
nvim +PlugInstall

echo "Setting up phpcd linting..."
# TODO: change to appropriate plugin/path
# pushd ~/.vim/bundle/phpcd.vim/ && composer update && pushd
# pushd ~/.vim/bundle/phpcd.vim/vendor/lvht/msgpack-rpc/ && and composer update && pushd
