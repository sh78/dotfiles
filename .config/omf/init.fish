# load user confs
for file in $HOME/.config/omf/*.load
    source $file
end
# less files == faster load

# http://www.fileformat.info/search/google.htm?q=unicode+face
set -gx __fish_prompt_char ""

# vi mode!
fish_vi_key_bindings

# set color scheme based on time of day
if test (date +%H) -gt 8; and test (date +%H) -lt 18
  set -gx COLOR light
else
  set -gx COLOR dark
end

# set iterm color scheme (iterm shell integration must be loaded
if test $TERM_PROGRAM = "iTerm.app"; and test $COLOR = "light"
  it2setcolor preset "Solarized Light v2"
else
  it2setcolor preset "Solarized Dark v2"
end

