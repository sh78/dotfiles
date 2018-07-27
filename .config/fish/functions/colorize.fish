function colorize --description "Set light/dark theme based on \$COLOR"
  # set iterm color scheme (iterm shell integration must be loaded)
    if type -q it2setcolor
      if test $COLOR = "light"
        it2setcolor preset "Solarized Light v2"
      else
        it2setcolor preset "Solarized Dark v2"
      end
    # TODO: else if (uname) == Linux
    else
      echo "it2selectcolor is not installed"
    end
end
