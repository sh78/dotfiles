# iTerm fish shell integration
test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

# custom greeting
function fish_greeting
  if type -q fortune
    fortune
  else
    # enjoy the silence
  end
end

# if not set -q abbrs_initialized
# 	set -U abbrs_initialized
# 	source $HOME/.config/omf/aliases.load
# end

set -gx __fish_prompt_char ""

# enable vi mode!
# fish_vi_key_bindings
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

# Base16 Shell
set -gx BASE16_SHELL "$HOME/.config/base16-shell/"
if test -e $BASE16_SHELL; and status --is-interactive
    source "$BASE16_SHELL/profile_helper.fish"
end

# check for colorls
if type -q colorls
    set -gx COLORLS 'true'
end

set -gx GPG_TTY (tty)

# map trick escape key if needed
# TODO: it starts xcape, but doesn't work for the session. Maybe because not
# interactive.
# if type -q xcape
#     set xcapep (ps aux | grep xcape | wc -l)
#     if test $xcapep -lt 2
#         xcape -e 'Control_L=Escape'
#     end
# end
