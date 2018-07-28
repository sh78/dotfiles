#!/usr/bin/env bash

echo "setting preferences..."
sleep 1
bash ./prefs.bash

echo "running cleanup..."
sleep 1
bash ./cleanup.bash

echo "running installers..."
sleep 1
bash ./installers.bash

echo "opening Drive, start sync process now and press [Enter] key when fully syned..."
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

read -p "restoring from mackup backup (sym links). press [Enter] to continue when Google Drive is fully synced..."
sleep 1
bash ./mackup.bash

echo "opening some apps for manual setup..."
sleep 1
bash ./run_apps.bash

echo "running some miscellany..."
sleep 1
bash ./misc.bash

