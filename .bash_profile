source ~/.profile
if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

export RBENV_ROOT=/usr/local/var/rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export PATH="$HOME/.cargo/bin:$PATH"
