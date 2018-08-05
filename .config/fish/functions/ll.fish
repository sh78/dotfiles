function ll --description "long ls w/ color output and indicators"
  if test -n "$COLORLS"
    eval colorls -l --report --sort-dirs --git-status $argv
  else
    command ls -lFGh $argv
  end
end
