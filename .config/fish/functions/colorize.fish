function colorize --description "Set light/dark theme based on \$COLOR"
  if [ $COLOR = 'light' ]
    base16-solarized-light
  else
    base16-solarized-dark
  end
end
