function lla --description "sir list-alot has secrets"
  if test -n "$COLORLS"
    eval colorls -lA --report --sort-dirs --git-status $argv
  else
    command ls -lAFGh $argv
  end
end
