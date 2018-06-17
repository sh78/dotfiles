function lla --description "show permissions, filesize, name for all files"
  ls -AlhFG $argv | cut -c 1-11,28-34,48-
end


