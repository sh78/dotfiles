function lla --description "sir list-alot has secrets"
  if test -n "$COLORLS"
    colorls -lA --report --git-status $argv
  else
    command ls -lAFGh $argv
  end
end
