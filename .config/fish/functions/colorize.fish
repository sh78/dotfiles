function colorize --description "Grep for a base16 theme or set random based on \$COLOR"
  if count $argv > 1
    set color (ls ~/.config/base16-shell/scripts/ | grep "$argv[1]" | sort -R | tail -1 | string replace '.sh' '')
  else if [ $COLOR = 'light' ]
    set color (ls ~/.config/base16-shell/scripts/ | grep "light" | sort -R | tail -1 | string replace '.sh' '')
  else
    set color (ls ~/.config/base16-shell/scripts/ | grep "dark" | sort -R | tail -1 | string replace '.sh' '')
  end
  echo "Theme set to: $color"
  echo
  eval $color
end
