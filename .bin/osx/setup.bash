#!/usr/bin/env bash

echo "running prefs..."
sleep 1
bash ./prefs.bash

echo "running cleanup..."
sleep 1
bash ./cleanup.bash

echo "running installers..."
sleep 1
bash ./installers.bash

echo "opening Drive, start sync process now..."
open /Applications/Google \ Drive.app

echo "setting up fish..."
sleep 1
bash ./fish.bash

echo "setting up ruby, rbenv, and gems..."
sleep 1
bash ./ruby.bash

echo "setting up mysql..."
sleep 1
bash ./mysql.bash

read -p "Set up up dropbox. Press [Enter] key when fully synced..."

echo "restoring from mackup..."
sleep 1
bash ./mackup.bash

echo "running misc..."
sleep 1
bash ./misc.bash

echo "opening some apps..."
sleep 1
bash ./apps.bash
