function tree --description "tree w/ color output and indicators"
  if test -n "$COLORLS"
    eval colorls --tree --git-status $argv
  else
    command tree $argv
  end
end
