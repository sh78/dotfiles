# Path to Oh My Fish install.
set -gx OMF_PATH "$HOME/.local/share/omf"

# iTerm fish shell integration
test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish

# custom greeting
function fish_greeting
  if type -q fortune
    fortune
  else
    # enjoy the silence
  end
end

# load user confs
source $HOME/.config/omf/env.load

if not set -q abbrs_initialized
	set -U abbrs_initialized
	source $HOME/.config/omf/aliases.load
end

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
colorize

