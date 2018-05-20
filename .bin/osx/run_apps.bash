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
