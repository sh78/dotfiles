# ff - fuzzy cd from anywhere
# default scope is $HOME
# USAGE: ff [NAME] [PATH]
# inspired by
# https://github.com/junegunn/fzf/wiki/examples#changing-directory
function ff --description "Fuzzy cd to anywhere with preview"
    if [ "x$argv[1]" != "x" ]
        set name "$argv[1]"
    else
        set name '*'
    end

    if [ "x$argv[2]" != "x" ]; then
        set path "$argv[2]"
    else
        set path "$HOME"
    end

    set dir (find "$HOME" -type d -name "$name" | fzf --ansi --preview="ls -lAFhG (echo {+1})" --preview-window="up:60%")
    cd "$dir"; or exit 1
end
