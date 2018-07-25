#!/usr/bin/env bash

# check for fish and potentially install it
if test ! $(which fish); then
  echo "Installing fish shell..."
  brew install fish
fi

# add fish to shells and set as default
echo "Setting Fish shell as default..."
echo "/usr/local/bin/fish" | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish

# Set up oh-my-fish
# curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish
curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install > install_omf

# remove line in success block that starts a fish shell and interrupts the remaining processes
sed -i '.original' 's/.*or exec fish.*/\# removed line that starts fish on tty./' install_omf
fish install_omf

# set up themes
fish -c "omf install cbjohnson clearance fox lambda simple-ass-prompt tomita agnoster"
fish -c "omf theme cbjohnson"
