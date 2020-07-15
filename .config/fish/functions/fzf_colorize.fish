# FIXME: calling the base16 function from --preview by itself returns 'command
# not found'. Sourcing the bsae16 profile_helper.fish script from inside the
# --preview just returns a bunch of ansi codes and doesn't run the command.
function fzf_colorize --description "Pick a base16 color scheme with FZF"
  set color (ls ~/.config/base16-shell/scripts/ | sort -R | string replace '.sh' '' | \
    fzf --ansi --preview='set -gx BASE16_SHELL "$HOME/.config/base16-shell/"; \
        source "$BASE16_SHELL/profile_helper.fish"; \
        eval {}')
  echo
  eval $color
  echo "Theme set to: $color"
end
