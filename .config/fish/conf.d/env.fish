set -g TERM xterm-256color-italic

# Language Default
set -x LC_ALL en_US.UTF-8
set -x LC_CTYPE en_US.UTF-8

set -gx GOPATH $HOME/.go
set -gx PATH $HOME/.composer/vendor/bin $PATH
set -gx PATH $GOPATH/bin $PATH
set -gx PATH .local/bin $PATH
set -gx PATH /snap/bin $PATH
set -gx PATH /usr/local/opt/ruby/bin $PATH

set -gx PATH $HOME/.bin $PATH
set -gx PATH $HOME/.terminus/vendor/bin $PATH

# editor
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SVN_EDITOR 'nvim'
# set -gx SVN_EDITOR "cat $HOME/.svnmessage > svn-commit.tmp && svn diff >> svn-commit.tmp && nvim +'set ft=diff' +'set nowrap'"
set -gx GIT_EDITOR 'nvim'
set -gx WWW_HOME 'https://www.duckduckgo.com/'

# os-specific stuff
set -gx OSTYPE (uname)
switch $OSTYPE
  case "Linux"
    # figure out which clipboard to use
    if command -v xsel >/dev/null
        set -gx CLIPBOARD xsel --clipboard --input
        set -gx PASTEBOARD xsel --clipboard --output
    else if command -v xclip >/dev/null; then
        set -gx CLIPBOARD xclip -selection clipboard
        set -gx PASTEBOARD xclip -selection clipboard -o
    end
    abbr pbcopy $CLIPBOARD
    abbr pbpaste $PASTEBOARD

    # add .local to path (used by pip/pip3)
    set -gx PATH ~/.local/bin $PATH
  case "Darwin"
    set -gx CLIPBOARD pbcopy
    set -gx PASTEBOARD pbcopy

    # add homebrew to the beginning of PATH
    set -gx PATH /usr/local/bin $PATH
    set -gx PATH /usr/local/sbin $PATH
end

# FZF fuzzy finder
set -gx FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!{.git,.svn,*.map,*.min*,**/min/**,**/js/build/**,**/node_modules/**,**/bower_components/**}"'

# vagrant
set -x VAGRANT_DEFAULT_PROVIDER "virtualbox"

# rbenv
if which rbenv >> /dev/null
	status --is-interactive; and . (rbenv init -|psub)
    set -x PATH $HOME/.rbenv/bin $PATH
	rbenv init - | source
end

# Colorful man pages
# from http://pastie.org/pastes/206041/text
set -gx LESS_TERMCAP_mb (set_color -o red)
set -gx LESS_TERMCAP_md (set_color -o red)
set -gx LESS_TERMCAP_me (set_color normal)
set -gx LESS_TERMCAP_se (set_color normal)
set -gx LESS_TERMCAP_so (set_color -b blue -o yellow)
set -gx LESS_TERMCAP_ue (set_color normal)
set -gx LESS_TERMCAP_us (set_color -o green)

# grep colors
# setenv -x GREP_OPTIONS "--color=auto"

# Android SDK
# set -gx JAVA_HOME (/usr/libexec/java_home -v 1.8)
# set -gx ANDROID_HOME /usr/local/share/android-sdk
