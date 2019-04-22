#
# UNIX - General
#

alias v='nvim'
alias h='history'
alias c="clear" # easier on the thumb vs cmd+k
alias x='exit 0'

alias p='pwd'
alias ..='cd ..' # up one
alias ....='cd ../..' # up two
alias cdd='cd -' # back
# cd then ls
cd() { builtin cd "$@"; ls -HG; }
# change dir then clear output
cc() { cd $*; clear; }
# change directory, clear output, then list contents
ccl() { cd $*; clear; ls -FG; }
alias l="tree -C -L 1" # show a quick tree of files
alias la='tree -C -a -L 1' # also list hidden files (think "list all")
alias ls="ls -FGh" # color list output with directory markers by default
alias ll='ls -lhFGh | cut -c 2-11,27-34,48-' # show permissions, filesize, name
alias lal="ls -alhFG | cut -c 2-11,28-34,48-" # show permissions, filesize, name for all files
alias lg="ls | grep" # pass in  string to get specific ls results
alias lns="ln -s" # symlink in 2 less characters
alias cl="clear; tree -C -L 1" # clear and show a quick tree
alias cla="clear; tree -C -a -L 1" # clear and show a quick tree of all files
alias op="open ./" # open your current dir in Finder and accept defeat
alias rmrf="rm -rf" # as if bricking your machine wasn't easy enough
alias rmrfp="rm -rfp" # you could say that again
alias mkdirp='mkdir -p' # nesting
take() { mkdir -p $1; cd $1; }
alias chx='chmod +x' # make it executable
alias chR='chmod -R' # recursive

if [ $OSNAME == 'Linux' ]; then
    if [ command -v xsel >/dev/null ]; then
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'
    elif [ command -v xclip >/dev/null ]; then
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    fi
fi


alias tails='tail -F $(find . -type f -not -name '*.tar' -not -name '*.gz' -not -name '*.zip' -not -path '*.git*' -not -path '*.svn*' -not -path '*node_modules*' | grep -e '/log/' -e '/logs/' -e '\.log')'

alias lmk="say 'Process complete.'" # pin to the tail of long commands

#
# UNIX - Nifties
#

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias getwebsite="wget -r --no-parent" # download entire directory of web site

#
# programs
#

alias ai="sudo apt install"
alias aud="sudo apt update"
alias aug="sudo apt upgrade"

#
# OSX - Nifties
#

# Quick-look a file (^C or space to close)
alias ql='qlmanage -p 2>/dev/null'
# lock screen
alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
# Save a screen shot to current directory. 1s delay provided for app switching.
alias snap='screencapture -T 1 "Screen Shot $(date +'%Y-%m-%d') at $(date +"%I.%M.%S %p").png"'
# silent ninja snap
alias snapx='screencapture -T 1 -x "Screen Shot $(date +'%Y-%m-%d') at $(date +"%I.%M.%S %p").png"'
alias mute="osascript -e 'set volume output muted true'"
alias unmute="osascript -e 'set volume output muted false'"

#
# WEB (OSX)
#

pagespeed() { open "https://developers.google.com/speed/pagespeed/insights/?url=$1"; }

# search websites
yt() {
  IFS='+' # make + the default space char
  open https\://www.youtube.com/results\?search_query="$*"&oq="$*"
  unset IFS # back to normal mode
}
ggl() {
  IFS='+' # make + the default space char
  open https\://www.google.com/\?\&q\="$*"
  unset IFS # back to normal mode
}
gith() {
  IFS='+' # make + the default space char
  open https\://github.com/search\?q="$*"
  unset IFS # back to normal mode
}
amaz() {
  IFS='+' # make + the default space char
  open http\://www.amazon.com/s/\?field\-keywords\="$*"
  unset IFS # back to normal mode
}

# set timers
timer() {
  if [ "$1" -gt 0 ]
    then
      open "http\://e.ggtimer.com/"$1"%20minutes"
    else
      echo "Please enter an integer greater than 0."
  fi
}
morning() {
  open http\://e.ggtimer.com/morning
  # (can help get your blood pumping)
}
pomodoro() {
  open http\://e.ggtimer.com/pomodoro
  # (does one 25/5 minute cycle)
}
tabata() {
  open http\://e.ggtimer.com/tabata
  # (8 reps of 20/10 second intervals)
}
brushteeth() {
  open http\://e.ggtimer.com/brushteeth
  # (for healthy teeth)
}

meditate() {
  open "http://www.getsomeheadspace.com/pages/account/myheadspace.aspx"
}

# 2048() {
#   open "http://gabrielecirulli.github.io/2048/"
# }

# lookup a command at explainshell.com
explain() {
  CMD=$(python -c "import urllib, sys; print urllib.quote_plus(sys.argv[1])" "$*")
  open "http://explainshell.com/explain?cmd=$CMD"
}

# ff - fuzzy cd from anywhere
# default scope is $HOME
# USAGE: ff [NAME] [PATH]
# inspired by
# https://github.com/junegunn/fzf/wiki/examples#changing-directory
ff() {
    if [ "x$1" != "x" ]; then
        name="$1"
    else
        name='*'
    fi

    if [ "x$2" != "x" ]; then
        path="$2"
    else
        path="$HOME"
    fi

    dir=$(find "$HOME" -type d -name "$name" |
        fzf --ansi --preview="ls -lAFhG $(echo {+1})" --preview-window="up:60%")
    cd "$dir" || exit 1
}


