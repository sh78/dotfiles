# custom greeting
function fish_greeting
  if type -q fortune
    fortune -a
  else
    # enjoy the silence
  end
end

# load user confs
source $HOME/.config/omf/env.load
source $HOME/.config/omf/aliases.load
source $HOME/.config/omf/clorox.load
if test $OSTYPE = "Darwin"
  source $HOME/.config/omf/macos.load
end
# for file in $HOME/.config/omf/*.load
#     source $file
# end
# Monday, May 14 2018 19:24
## not much slower than one giant file. it's what's inside that counts
## 3 files, 2015 MBP i3 8GB

# >
set -gx __fish_prompt_char ""

# enable vi mode!
fish_vi_key_bindings
# and now restore ctrl+f for autocomplete
# https://github.com/fish-shell/fish-shell/issues/3541
function fish_user_key_bindings
	for mode in insert default visual
		bind -M $mode \cf forward-char
	end
end

# export a color scheme var based on time of day
if test (date +%H) -gt 8; and test (date +%H) -lt 18
  set -gx COLOR light
else
  set -gx COLOR dark
end

# set iterm color scheme (iterm shell integration must be loaded)
if type -q it2setcolor
  if test $COLOR = "light"
    it2setcolor preset "Solarized Light v2"
  else
    it2setcolor preset "Solarized Dark v2"
  end
end

# set some useful environment variables
set -gx $OSTYPE (uname)
switch $OSTYPE
  case "Linux"
    set -gx $CLIPBOARD xclip -selection clipboard
  case "Darwin"
    set -gx $CLIPBOARD pbcopy
end
