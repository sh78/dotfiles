#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# install command line tools
xcode-select --install

# set up git cred caching
git config --global credential.helper osxkeychain

# define app arrays

brew_taps=(
  "homebrew/dupes"
  "homebrew/services"
  "thoughtbot/formulae"
  "homebrew/php"
  "risidev/homebrew-chunkwm"
  "koekeishiya/formulae"
)

user_brews=(
  ack
  cheat
  chumkwm
  cmatrix
  cmus
  composer
  cowsay
  ctags
  dnsmasq
  exiftool
  feh
  ffmpeg
  figlet
  fortune
  git
  git-flow
  gitsh
  gtypist
  httrack
  hub
  imagemagick
  khd
  mackup
  mercurial
  mplayer
  mysql
  neofetch
  neovim
  ngrep
  nmap
  node
  pianobar
  postgresql
  rbenv
  rename
  rigrep
  ruby-build
  selecta
  sloccount
  speedtest_cli
  spidermonkey
  ssh-copy-id
  the_silver_searcher
  tmux
  tmuxinator-completion
  todo-txt
  tor
  trash
  wp-cli
  youtube-dl
  zsh
  zsh-completions
)

system_brews=(
  "homebrew/dupes/grep"
  "vim --with-features=huge --with-python3 --with-ruby --with-perl"
  apple-gcc42
  bash
  cmake
  coreutils
  findutils
  python
  python3
  rsync
  tree
  wget
)

qlexts=(
  betterzipql
  qlcolorcode
  qlimagesize
  qlmarkdown
  qlprettypatch
  qlstephen
  quicklook-csv
  quicklook-json
  suspicious-package
  webpquicklook
)

npm_packages=(
  bower
  css-loader
  csslint
  ember-cli
  extract-loader
  fb-messenger-cli
  file-loader
  generator-assemble
  generator-reveal
  generator-webapp
  grunt-cli
  gulp
  http-server
  jshint
  lighthouse
  node-sass
  sass-lint
  sass-loader
  sloc
  spot
  surge
  webpack-dev-server@2
  webpack@3
  yo
)

pip_packages=(
  bitbucket-cli
  python-dateutil
  requests
  neovim
  terminal_velocity
)

pip3_packages=(
  mps-youtube
  neovim
)

user_apps=(
  1password
  airtable
  bartender3
  carbon-copy-cloner
  coconutbattery
  cool-retro-term
  cyberduck
  firefox
  flash
  franz
  gas-mask
  google-chrome
  google-drive
  iexplorer
  imageoptim
  iterm2
  java
  karabiner-elements
  keyboard-maestro
  mac2imgur
  # marked
  nosleep
  # nvalt
  # parallels-desktop
  qutebrowser
  # skype
  slack
  spectacle
  sublime-text
  teamviewer
  textexpander
  torbrowser
  tunnelbear
  vagrant
  virtualbox
  vlc
  # xld
)

user_fonts=(
  font-anonymous-pro
  font-source-code-pro
  font-source-code-pro-for-powerline
  font-source-sans-pro
  font-source-serif-pro
  font-hack-nerd-font
)


# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Setting up homebrew..."
brew doctor
brew update

# What's on tap?
brew install ${brew_taps[@]}

# echo "Installing system brews & dupes - GNU utils, dupes, cmake..."
brew install ${system_brews[@]}

echo "Installing user brews..."
brew install ${user_brews[@]}

# update pip stuff for the newly installed python
echo "Updating pip..."
pip install --upgrade setuptools
pip install --upgrade pip
easy_install iso8601


# install python packages
echo "Installing pip packages..."
pip install ${pip_packages[@]}
echo "Installing pip3 packages..."
pip3 install ${pip3_packages[@]}


# install composer packages
composer global require "asm89/twig-lint" "@stable" # dep of SublimeLinter-twig

# install npm packages
echo "Installing npm packages..."
npm install -g ${npm_packages[@]}

# install the cask
# echo "Making room for the cask..."
brew tap phinze/homebrew-cask
brew install brew-cask
brew tap caskroom/versions

# install user_apps
echo "Installing apps..."
brew cask install --appdir=/Applications ${user_apps[@]}

# add `subl` command
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl

# install Prey with API key prompt
read -p "Enter Prey API key from https://panel.preyproject.com/settings/user-profile:" prey_api_key
API_KEY="$prey_api_key" brew cask install --appdir="/Applications" install prey

# echo "installing quicklook extensions..."
brew cask install ${qlexts[@]}

# echo "pulling the font cask..."
brew tap caskroom/fonts

# # install fonts
echo "installing fonts..."
brew cask install ${user_fonts[@]}


# set up POW! | http://pow.cx/
## Create the required host directories:
# mkdir -p ~/Library/Application\ Support/Pow/Hosts
#ln -s ~/Library/Application\ Support/Pow/Hosts ~/.pow
## Setup port 80 forwarding and launchd agents:
#sudo pow --install-system
#pow --install-local
## Load launchd agents:
#sudo launchctl load -w /Library/LaunchDaemons/cx.pow.firewall.plist
#launchctl load -w ~/Library/LaunchAgents/cx.pow.powd.plist

# Install vagrant & Parallels provider
## http://parallels.github.io/vagrant-parallels/
# brew cask install vagrant
# vagrant plugin install vagrant-parallels