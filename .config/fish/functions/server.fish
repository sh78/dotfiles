function server --description "Start an HTTP server from a directory"
  open http://localhost:8080/
  and python -m SimpleHTTPServer 8080
end
