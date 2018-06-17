# TODO
function gitrdone --description "Build up a commit message incrementally"
  if git status | grep .gitrdone
    echo ".gitrdone" >> .gitignore
  end
  if test -n "$argv[1]"
    if [ ("$argv[1]" sub -l 1 $i) = "h" ]
      echo -n "gitrdone - edit entire commit message file with default $EDITOR"
      echo -n "gitrdone [message (the change you just made)]"
      echo -n "gitrdone now - commit all staged changes with messages as template"
      echo -n "gitrdone all - add *all* changes and commit with messages as template"
    else if [ "$argv[1]" = "now" ]
      git commit --template=.gitrdone; and rm .gitrdone
    else
      echo "$argv" >> .gitrdone
    end
  else
    eval $EDITOR .gitrdone
  end
end
