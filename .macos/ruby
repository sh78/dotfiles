#!/usr/bin/env bash

user_gems=(
	bropages
	bundler
	compass
	foreman
	lolcat
	pg
	pry
	rails
	sass
	thin
	tmuxinator
)

# get the lastest stable ruby build through rbenv
rubyv=$(rbenv install -l | grep -v - | tail -1)
rbenv install $rubyv
rbenv init
# source ~/.bash_profile
rbenv global $rubyv

# install gems
echo "installing gems..."
gem install "${user_gems[@]}" --no-document
