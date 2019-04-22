function ll --description "long ls w/ color output and indicators"
  if test -n "$COLORLS"
    colorls -l --report --git-status $argv
  else
    command ls -lFGh $argv
  end
end
