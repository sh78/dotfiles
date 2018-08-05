function cd --description "cd w/ auto auto (color)ls"
  if count $argv > /dev/null
    builtin cd $argv[1]
    and l
  else
    builtin cd ~
    and l
  end
end
