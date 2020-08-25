" global find/replace inside working directory
function! FindReplace()
  " figure out which directory we're in
    let dir = expand('%:h')
  " ask for patterns
  call inputsave()
  let find = input('Pattern: ')
  call inputrestore()
  let replace = input('Replacement: ')
  call inputrestore()
  " are you sure?
  let confirm = input('WARNING: About to replace ' . find . ' with ' . replace . ' in ' . dir . '/**/* (y/n):')
  " clear echoed message
  redraw
  if confirm =~# 'y'
    " find with rigrep (populate quickfix )
    silent exe 'Rg ' . find
    " use cfdo to substitute on all quickfix files
    silent exe 'cfdo %s/' . find . '/' . replace . '/g | update'
    " close quickfix window
    silent exe 'cclose'
    echom('Replaced ' . find . ' with ' . replace . ' in all files in ' . dir )
  else
    echom('Find/Replace Aborted :(')
    return
  endif
endfunction
command! FindReplace :call FindReplace()

" RemoveFancyCharacters - smart quotes, etc.
function! RemoveFancyCharacters()
  let typo = {}
  let typo["“"] = '"'
  let typo["”"] = '"'
  let typo["‘"] = "'"
  let typo["’"] = "'"
  let typo["–"] = '--'
  let typo["—"] = '---'
  let typo["…"] = '...'
  exe ":%s/".join(keys(typo), '\|').'/\=typo[submatch(0)]/ge'
endfunction
command! RemoveFancyCharacters :call RemoveFancyCharacters()

" https://stackoverflow.com/questions/10760326/merge-multiple-lines-two-blocks-in-vim#answer-10760494
function! HorizontalConcat()
  " prompt for ranges
  call inputsave()
  let start = input('Enter starting range (like 1,50): ')
  call inputrestore()
  let end = input('Enter range to merge in (like 51,101): ')
  call inputrestore()
  " let separator = input('Enter separator (optional): ')
  " call inputrestore()
  silent exe end . 'del | let l=split(@","\n") | ' . start . 's/$/\=remove(l,0)/'
endfunction
command! HorizontalConcat :call HorizontalConcat()
nnoremap <Leader>hc :HorizontalConcat<CR>

function! FocusBuffer()
    let width = &textwidth + 1
    let &colorcolumn=join(range(width,999), ',')
    set cursorline cursorcolumn
endfunction

function! UnfocusBuffer()
    if &filetype != 'nerdtree'
        let &colorcolumn=join(range(1,999), ',')
    else
        let &colorcolumn=join(range(0,999), ',')
    endif
    set nocursorline nocursorcolumn
endfunction

" Auto Make
function! Make()
    if filereadable(expand('Makefile'))
        " There's already a Makefile, run :make and open results in quickfix
        :make | copen
    else
        " Make a Makefile, silly!
        :e Makefile
        " TODO: Prepopulate a simple template... Does vim script have HEREDOC?
        " https://patrickheneise.com/2018/01/makefile-for-node-js-developers/
    endif
endfunction
command! Make :call Make()
nnoremap <Leader>q :Make<CR>
