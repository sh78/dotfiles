if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

if [[ "`uname`" == 'Linux' ]]; then
    xcape -e 'Control_L=Escape'
elif [[ "`uname`" == 'Darwin' ]]; then
    export RBENV_ROOT=/usr/local/var/rbenv
fi

export PATH="$HOME/.cargo/bin:$PATH"
