function rcolor --description "Pick a random base16 colorscheme"
  set color (ls ~/.config/base16-shell/scripts/ | sort -R | tail -1 | string replace '.sh' '')
  echo $color
  eval $color
end
