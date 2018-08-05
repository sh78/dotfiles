function rcolor --description "Pick a random base16 colorscheme ['dark'|'light']"
  if count $argv > 1
    set color (ls ~/.config/base16-shell/scripts/ | grep "$argv[1]" | sort -R | tail -1 | string replace '.sh' '')
  else
    set color (ls ~/.config/base16-shell/scripts/ | sort -R | tail -1 | string replace '.sh' '')
  end
  echo $color
  eval $color
end
