# export GDK_SCALE=2
# export GDK_DPI_SCALE=0.5
# export QT_AUTO_SCREEN_SCALE_FACTOR=1

export PATH="$HOME/.cargo/bin:$PATH"

# dump dconf settings to backup
if command -v dconf >/dev/null; then
    dconf dump /org/gnome/ > ~/.dconf/gnome
fi

# remap control to escape if pressed once
xcape -e 'Control_L=Escape'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
