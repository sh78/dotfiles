source ~/.profile
if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if [[ "`uname`" == 'Darwin' ]]; then
    export RBENV_ROOT=/usr/local/var/rbenv
fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
