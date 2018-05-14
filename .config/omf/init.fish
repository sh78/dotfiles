for file in $HOME/.config/omf/*.load
    source $file
end

# http://www.fileformat.info/search/google.htm?q=unicode+face
set -gx __fish_prompt_char ""

# set color scheme based on time of day
if test (date +%H) -gt 8; and test (date +%H) -lt 18
  set -gx COLOR light
else
  set -gx COLOR dark
end
