####################
# ENV
####################

# OSX bin
PATH=~/.bin/executables:/usr/local/bin:$PATH

# Use the new iMproved vi
export EDITOR="vim"

# load fasd if lives nearby
# eval "$(fasd --init auto)"

# load hub
# eval "$(hub alias -s)"

# vagrant default provider
export VAGRANT_DEFAULT_PROVIDER=virtualbox

####################
# UNIX - General
####################

alias bashr="$EDITOR ~/.bashrc && reload" # a bash alias for editing your bash aliases, yo
alias bashp="$EDITOR ~/.bash_profile && reload" # same as above, for bash_profile
alias zshr="$EDITOR ~/.zshrc && reload" # zed
alias fishc="$EDITOR ~/.config/fish/config.fish" # fish
alias vimr="$EDITOR ~/.vimrc && reload"
alias Rb="source ~/.bashrc" # reload bash config
alias Rz="source ~/.zshrc" # reload zsh config

alias p='pwd'
alias ..='cd ..' # up one
alias ....='cd ../..' # up two
alias cdd='cd -' # back
# cd then ls
cd() { builtin cd "$@"; ls -HG }
# change dir then clear output
cc() { cd $*; clear }
# change directory, clear output, then list contents
ccl() { cd $*; clear; ls -FG }
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
take() { mkdir -p $1; cd $1 }
mkdirs() { for dir in "$@"; do mkdir "$dir"; done }
# match filenames containing given string and move into a new dir of that name
mvm() { mkdir ./mvmtemp; mv ./*"$@"* ./mvmtemp; mv ./mvmtemp ./"$@" }
# remove matched files recursively
rmvm() { for pattern in $@; do find . -type f -name "$pattern" -exec rm -r {} \ ; done }
# remove unmatched files recursively
rmvm!() { for pattern in $@; do find . -type f ! \( -name "$pattern" \) -exec rm -r {} \ ; done }
alias cpp='cp -p' # preserve attributes
alias cpr='cp -R' # recursive
alias cppr='cp -pR' # preserve attributes and recursive
alias scpr='scp -r' # recursive
alias df='df -h' # uses abbreviated size formats rather than bits
alias duh='du -h' # list disk usage for all files in ./
alias dush='du -sh' # list total disk usage of ./
# list file size of all dirs inside a given dir
dushs() { for i in $1/*; do du -sh $i; done }
alias chx='chmod +x' # make it executable
alias chR='chmod -R' # recursive

export GREP_OPTIONS="--color=auto -E" # use color and regex extended
export GREP_COLOR="33" # yellow

 alias gimg="grep -i '\.png|\.gif|\.jpg|\.jpeg|\.ico|\.tiff'"
 alias gvid="grep -i '\.avi|\.mov|\.mpg|\.wmv|\.mp4|\.m4v'"
 alias gaud="grep -i '\.aiff|\.aac|\.alac|\.flac|\.mp3|\.m4a'"
 alias gtxt="grep -i '\.txt|\.md|\.mdown|\.markdown|\.textile'"
 alias gdoc="grep -i '\.doc|\.docx|\.pdf|\.pages|\.rtf|\.ppt|\.pptx|\.xls|\.xlsx'|\.csv|\.tsv"
 alias gcode="grep -i '\.html|\.css|\.js|\.rb|\.py|\.xml|\.bash|\.sh|\.sass|\.scss|\.less|\.coffee|\.php|\.json|\.erb|\.haml|\.slim'"
 alias gfont="grep -i '\.eot|\.ttf|\.woff|\.svg'"

 alias zp='zip'
 alias zpr='zip -r' # recursive
 alias uz='unzip'
 alias uzd='unzip -d' # unzip to specific dir
 alias tgz='tar -xvzf' # extract .tar.gz
 alias tbz='tar -xvjf' # extract .tar.bz2
 # unzip all to self-titled dirs
 uza() { for f in ./*.zip; do unzip ${f%.zip}; done }
 # unzip all to self-titled dirs, then remove .zip's
 uzar() { for f in ./*.zip; do unzip ${f%.zip}; rm -rf ${f}; done }
 # extract (almost) anything
 extract() {
   if [ -f $1 ] ; then
      case $1 in
         *.tar.bz2)
             tar xvjf $1
             ;;
         *.tar.gz)
             tar xvzf $1
             ;;
         *.bz2)
             bunzip2 $1
             ;;
         *.rar)
             unrar x $1
             ;;
         *.gz)
             gunzip $1
             ;;
         *.tar)
             tar xvf $1
             ;;
         *.tbz2)
             tar xvjf $1
             ;;
         *.tgz)
             tar xvzf $1
             ;;
         *.zip)
             unzip $1
             ;;
         *.Z)
             uncompress $1
             ;;
         *.7z)
             7z x $1
             ;;
         *)
             echo "'$1' cannot be extracted via extract"
             ;;
     esac
   else
       echo "'$1' is not a valid file"
   fi
 }

 alias v='vim'
 alias h='history'
 alias c="clear" # easier on the thumb vs cmd+k
 alias x='exit'

 alias tails="tail -F $(find . -type f -not -name '*.tar' -not -name '*.gz' -not -name '*.zip' -not -path '*.git*' -not -path '*.svn*' -not -path '*node_modules*' | grep -e '/log/' -e '/logs/' -e '\.log')"

 alias lmk="say 'Process complete.'" # pin to the tail of long commands

 # system aliases()
 zzz() { sudo shutdown -s ${1:-now} }
 reboot() { sudo shutdown -r ${1:-now} }
 off() { sudo shutdown -h ${1:-now} }
 alias tu='top -o cpu' # cpu
 alias tm='top -o vsize' # memory

 # Color manpages (Arch style)
 export LESS_TERMCAP_mb=$'\E[01;31m'
 export LESS_TERMCAP_md=$'\E[01;38;5;74m'
 export LESS_TERMCAP_me=$'\E[0m'
 export LESS_TERMCAP_se=$'\E[0m'
 export LESS_TERMCAP_so=$'\E[38;5;246m'
 export LESS_TERMCAP_ue=$'\E[0m'
 export LESS_TERMCAP_us=$'\E[04;38;5;146m'

####################
# CLI's
####################

# sublime text
alias sub='subl -n' # alias the alias

# git
alias gs='git status -sb'
alias gi='git init'
alias gib='git init --bare'
alias gcl='git clone'
alias gd='git diff -M --word-diff'
alias gdc='git diff --cached -M'
alias ga='git add . --all'
alias gau='git add -u'
alias gcm='git commit -v'
alias gcma='git commit -v -a'
alias gcmam='git commit -v -a -m'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcoB='git checkout -B' # auto branch name from ref
alias gp='git push'
alias gpu='git push -u' # push and set the following remote branch as default push location
alias gpom='git push origin master'
alias gpa="git push --all" # push all branches
alias gpar="git remote | xargs -L1 git push --all" # push all branches to all remotes
alias gpl='git pull'
alias gplom='git pull origin master'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gfo='git fetch origin'
alias gfom='git fetch origin master'
alias greb='git rebase'
alias gst='git stash'
alias gstp='git stash pop'
alias gsts='git stash save'
alias gstl='git stash list'
alias gsta='git stash apply'
alias gssc='git stash clear'
alias grmc='git rm --cached'
alias gbr='git branch -v'
alias gbra='git branch -v -a'
alias gbrd='git branch -d'
alias gbrD='git branch -D'
alias gbrt='git branch --track'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias grb='git rebase -p'
alias grm='git remote -v'
alias grma='git remote add'
alias grms='git remote show'
alias grmsu='git remote set-url'
alias grmd='git remote -d'
alias gm='git merge'
alias grs='git reset'
alias grsh='git reset --hard' # undo all staged and unstaged changes
alias grsho='git reset --hard ORIG_HEAD' # undo merge
alias gk='gitk'
alias gka='gitk --all'
alias gl='git log --date-order --pretty="format:%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset"'
alias gla='gl --all'
alias glp='git log -p'
alias gls='git log --stat'
alias glps='git log -p --stat'
alias glpo='git log --pretty=oneline'
alias glg='git log --graph'
alias glpsg='git log -p --stat --graph'
alias glpsgo='git log -p --stat --graph --pretty=oneline'
alias gig="$EDITOR .gitignore"
# git commit and push
## adds everything, prints a status, commits, pushes to default origin/branch
## takes all arguments as commit msg, no quotes required
gacp() { git add --all; git status; git commit -v -m "$*"; git push }
# git commit and push to all branches
gacpa() { git add --all; git status; git commit -v -m "$*"; git push --all }
alias gitrdone="gacpa" # a new mantra for productivity...
# git commit and push to all branches and remotes
gacpar() { git add --all; git status; git commit -v -m "$*"; git remote | xargs -L1 git push --all }

# git-flow
alias gfi='git flow init'
alias gff='git flow feature'
alias gffs='git flow feature start'
alias gffs='git flow feature finish'
alias gfh='git flow hotfix'
alias gfhs='git flow hotfix finish'

# create a new private bitbucket repo from ./
bbcreate() { bb create_from_local --private --protocol=ssh }

 # homebrew
 alias bud='brew update'
 alias bug='brew upgrade'
 alias bi='brew install'
 alias bd='brew doctor'
 alias bs='brew search'
 alias bl='brew list'

 alias bc='brew cask'
 alias bci='brew cask install'
 alias bci='brew cask install'
 alias bcia='brew cask install --appdir="/Applications"'
 alias getapp='brew cask install --appdir="/Applications"'

 _rsync_cmd='rsync --verbose --progress --human-readable --compress --archive --hard-links --one-file-system'

 if grep -q 'xattrs' <(rsync --help 2>&1); then
   _rsync_cmd="${_rsync_cmd} --acls --xattrs"
 fi

 # Mac OS X and HFS+ Enhancements
 # http://help.bombich.com/kb/overview/credits#opensource
 if [[ "$OSTYPE" == darwin* ]] && grep -q 'file-flags' <(rsync --help 2>&1); then
   _rsync_cmd="${_rsync_cmd} --crtimes --fileflags --protect-decmpfs --force-change"
 fi

 alias rsync-copy="${_rsync_cmd}"
 alias rsync-move="${_rsync_cmd} --remove-source-files"
 alias rsync-update="${_rsync_cmd} --update"
 alias rsync-synchronize="${_rsync_cmd} --update --delete"

 unset _rsync_cmd

 # Rails
 alias rn='rails new'
 alias rgs='rails generate scaffold'
 alias r='rake'
 alias rdbm='rake db:migrate'
 alias rs='rails server'
 alias b='bundle'
 alias be='bundle exec'
 alias bl='bundle --local'
 alias ror='ruby -v; rails -v'

 # Sass / Compass
 alias sassw='sass --watch'
 alias compc='compass create'
 alias compw='compass watch'

 # CoffeeScript
 alias cof='coffee'
 alias cofc='coffee --compile'
 alias cofw='coffee --watch'
 alias cofwc='coffee --watch --compile'
 alias cofp='coffee --print'

 # Foreman
 alias fms='foreman start'

 # Vagrant
 alias vag='vagrant'
 alias vagba='vagrant box add'
 alias vagi='vagrant init'
 alias vagu='vagrant up'
 alias vags='vagrant ssh'
 alias vagus='vagrant up; vagrant ssh'
 alias vagh='vagrant halt'
 alias vagr='vagrant reload'
 alias vagd='vagrant destroy'

 # jekyll
 alias jek='jekyll'
 alias jekb='jekyll build'
 alias jekbw='jekyll build --watch'
 alias jeks='jekyll serve'
 alias jeksw='jekyll serve --watch'

 # pianobar (pandora cli)
 alias pb='pianobar'

 # gmailjitsu | https://github.com/thetateal/gmailjitsu
 alias gj='gmailjitsu'

 # youtube-dl | http://rg3.github.io/youtube-dl/
 alias ytdl='youtube-dl'
 alias ytmp3='youtube-dl --extract-audio --audio-format mp3'

 # mps youtube
 alias mpsyt='youtube'

 # tmux
 alias t='tmux'
 alias tl='tmux ls'
 alias ta='tmux attach'
 alias tat='tmux attach -t'
 alias tk='tmux kill-session -t'
 alias tn='tmux new -s'
 tnsn() { tmux new -s $1 -n $2 }
 tf() { tmux -f $1 attach }

 # tmuxinator
 alias mux='tmuxinator'
 alias muxn='tmuxinator new'
 alias muxo='tmuxinator open'
 alias muxl='tmuxinator list'
 alias muxc='tmuxinator copy'

 # IRB
 alias irb='irb --simple-prompt'

 # irssi
 alias ir='irssi'

 # postgresql
 alias pgstart='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
 alias pgstop='pg_ctl -D /usr/local/var/postgres stop -s -m fast'

# mysql
mysqlc() { mysql -u root -p -e "create database $1" }

mysqld() { mysql -u root -p -e "drop database $1" }

# grunt
alias grus='grunt serve'
alias grusf='grunt serve --force'
alias grub='grunt build'
alias grubf='grunt build --force'

# bower
alias bi='bower install'
bis() { bower install "$@" --save }

# wp-cli
alias wpcc="wp core config" # Generate a wp-config.php file.
alias wpcd="wp core download" # Download core WordPress files.
alias wpci="wp core install" # Create the WordPress tables in the database.
alias wpcii="wp core is-installed" # Determine if the WordPress tables are installed.
alias wpcmc="wp core multisite-convert" # Transform a single-site install into a multi-site install.
alias wpcmi="wp core multisite-install" # Install multisite from scratch.
alias wpcu="wp core update" # Update WordPress.
alias wpcudb="wp core update-db" # Update the WordPress database.
alias wpcv="wp core version" # Display the WordPress version.

alias wpdbcli="wp db cli" # Open a mysql console using the WordPress credentials.
alias wpdbc="wp db create" # Create the database, as specified in wp-config.php
alias wpdbd="wp db drop" # Delete the database.
alias wpdbe="wp db export" # Exports the database to a file or to STDOUT.
alias wpdbi="wp db import" # Import database from a file or from STDIN.
alias wpdbo="wp db optimize" # Optimize the database.
alias wpdbq="wp db query" # Execute a query against the database.
alias wpdbrp="wp db repair" # Repair the database.
alias wpdbrs="wp db reset" # Remove all tables from the database.
alias wpdbt="wp db tables" # List the database tables.

alias wppa="wp plugin activate" # Activate a plugin.
alias wppda="wp plugin deactivate" # Deactivate a plugin.
alias wppd="wp plugin delete" # Delete plugin files.
alias wppg="wp plugin get" # Get a plugin.
alias wppi="wp plugin install" # Install a plugin.
alias wppii="wp plugin is-installed" # Check if the plugin is installed.
alias wppl="wp plugin list" # Get a list of plugins.
alias wppp="wp plugin path" # Get the path to a plugin or to the plugin directory.
alias "wpp?"="wp plugin search" # Search the wordpress.org plugin repository.
alias wpps="wp plugin status" # See the status of one or all plugins.
alias wppt="wp plugin toggle" # Toggle a plugin's activation state.
alias wppu="wp plugin uninstall" # Uninstall a plugin.
alias wppu="wp plugin update" # Update one or more plugins.

alias wpta="wp theme activate" # Activate a theme.
alias wptd="wp theme delete" # Delete a theme.
alias wptda="wp theme disable" # Disable a theme in a multisite install.
alias wpte="wp theme enable" # Enable a theme in a multisite install.
alias wptg="wp theme get" # Get a theme
alias wpti="wp theme install" # Install a theme.
alias wptii="wp theme is-installed" # Check if the theme is installed.
alias wptl="wp theme list" # Get a list of themes.
alias wptm="wp theme mod" # Manage theme mods.
alias wptp="wp theme path" # Get the path to a theme or to the theme directory.
alias "wpt?"="wp theme search" # Search the wordpress.org theme repository.
alias wpts="wp theme status" # See the status of one or all themes.
alias wptu="wp theme update" # Update one or more themes.
alias wpmig="wp wpmdb migrate" # wp migrate db pro cli

####################
# UNIX - Nifties
####################

alias getwebsite="wget -r --no-parent" # download entire directory of web site
# the new NValt alternate. works with all online sync services on any platform
n() { mkdir ~/notes; touch ~/notes/first.txt; cd ~/notes/; vim ~/notes; cd - ; }
alias getheaders="curl --head" # get http headers of a website
# check gzip compression of a website
gzipchk() { curl -I -H 'Accept-Encoding: gzip,deflate' "$@" | grep --color 'Content-Encoding:'; }
# display available emacs games
alias emacsgames='ls /usr/share/emacs/22.1/lisp/play'
wait() { sleep $1; eval $2}

####################
# OSX - Nifties
####################

# Quick-look a file (^C or space to close)
alias ql='qlmanage -p 2>/dev/null'
# open with [/Applications/App.app]
alias opa='open -a'
# lock screen
alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
# Save a screen shot to current directory. 1s delay provided for app switching.
alias snap='screencapture -T 1 "Screen Shot $(date +'%Y-%m-%d') at $(date +"%I.%M.%S %p").png"'
# silent ninja snap
alias snapx='screencapture -T 1 -x "Screen Shot $(date +'%Y-%m-%d') at $(date +"%I.%M.%S %p").png"'
alias mute="osascript -e 'set volume output muted true'"
alias unmute="osascript -e 'set volume output muted false'"
# spool a local server | thanks Paul Irish
server() {
  local port="${1:-8000}"
  python -m SimpleHTTPServer "$port"
  open "http://localhost:${port}"
}
# ngrok localhost server - url subdomain [user] [pass]
serve() {
  open "http://$2.ngrok.com/"
  open "http://localhost:4040/"
  ngrok -subdomain="$2" -httpauth="$3:$4" $1
}
# fix persmissions of local wordpress install to allow internet functions
fixlocalwp() { sudo chown -R _www ./; sudo chmod -R g+w ./; }

####################
## WEB (OSX)
####################

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

findphone() {
  open "https://www.icloud.com#find"
  open "https://panel.preyproject.com/app"
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


####################
# Bling
####################

if hash lolcat 2>/dev/null; then
  alias cat="lolcat"
fi

#  day/night auto colorizer for iterm
# colorize() {
#   osascript ~/.bin/executables/itermcolors.applescript
# }
export VISUAL=vim
export EDITOR="$VISUAL"
