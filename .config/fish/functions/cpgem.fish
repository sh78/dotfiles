function cpgem --description "copy a gem's source files to current directory"
  cp -R (bundle show $argv) ./
end
