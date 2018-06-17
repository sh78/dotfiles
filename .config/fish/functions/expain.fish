function explain --description "Lookup command on explainshell.com"
    set -l URL_ENCODE (python -c 'import urllib, sys; print urllib.quote_plus(sys.argv[1])' "$argv")
    open "http://explainshell.com/explain?cmd=$URL_ENCODE"
end
