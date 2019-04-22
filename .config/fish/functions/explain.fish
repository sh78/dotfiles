# TODO: this should be a bash script in .bin
function explain --description "Lookup command on explainshell.com"
    set -l URL_ENCODE (python -c 'import urllib, sys; print urllib.quote_plus(sys.argv[1])' "$argv")

    if [ "$OSTYPE" = "Linux" ]
        set open_command xdg-open
    else
        set open_command open
    end

    eval $open_command "http://explainshell.com/explain\?cmd=$URL_ENCODE"
end
