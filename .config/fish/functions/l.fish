function l --description "ls w/ color output and git indicators"
  if test -n "$COLORLS"
    eval colorls -1 --git-status $argv
  else
    command ls -F $argv
  end
end
