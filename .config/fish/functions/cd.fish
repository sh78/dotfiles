if test -n "$COLORLS"
    set ls_command colorls -1 --git-status
else
    set ls_command ls -1
end
function cd --description "cd w/ auto (color)ls"
  if count $argv > /dev/null
    builtin cd $argv[1]
    and eval $ls_command
  else
    builtin cd ~
    and eval $ls_command
  end
end
