function cd --description "auto ls for each cd"
  if [ -n $argv[1] ]
    builtin cd $argv[1]
    and ls -F
  else
    builtin cd ~
    and ls -F
  end
end
