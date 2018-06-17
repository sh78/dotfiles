function cat --description "cat the rainbow"
  if type -q lolcat
    lolcat $argv
  else
    cat $argv
  end
end
