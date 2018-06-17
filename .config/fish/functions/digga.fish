function digga --description "All the dig info"
  dig +nocmd "$argv[1..-1]" any +multiline +noall +answer
end
