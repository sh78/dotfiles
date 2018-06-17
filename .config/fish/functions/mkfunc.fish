# TODO: make it read in a skeleton
function mkfunction --description "add a new fish function file"
  set name $argv
  eval $EDITOR ~/.config/fish/functions/$name
end
