function la --description "show me your secrets"
  if test -n "$COLORLS"
    eval colorls -A --sort-dirs --git-status $argv
  else
    command ls -Ah $argv
  end
end


