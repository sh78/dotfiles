function l --description "ls w/ color output and indicators"
  if test -n "$COLORLS"
    eval colorls --sort-dirs --git-status $argv
  else
    command ls -F $argv
  end
end
