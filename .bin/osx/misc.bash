#!/usr/bin/env bash

# setup ssh key
# if [ [ -d "~/.ssh" ] || [ -L "~/.ssh" ] ]; then
#   echo "Looks like you already have ssh confgs... skipping."
# else
#   echo "Generating ssh keys..."
#   ssh-keygen -t rsa
# fi


# misc
echo "downloading some miscellaneous payloads to the desktop for manual labor..."
wget http://ethanschoonover.com/solarized/files/solarized.zip
wget http://cdn3.brettterpstra.com/downloads/TabLinks.2.0.zip

mkdir ~/Desktop/MANUAL\ LABOR
mv *.zip ~/Desktop/MANUAL\ LABOR

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mv $HERE/app\ presets ~/Desktop/MANUAL\ LABOR


# # Dropbox sym links

# user=sean

# dirs=(
#   active
#   Desktop
#   Documents
#   notes
#   Public
# )

# for dir in "${dirs[@]}"; do
#   mkdir ~/$dir &> /dev/null
#   mv ~/Dropbox/$user/$dir/* ~/$dir
#   rm -rf ~/Dropbox/$user/$dir
#   ln -s ~/$dir ~/Dropbox/$dir
# done
