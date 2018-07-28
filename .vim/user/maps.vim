"
" Quick Toggles
" Use mnemonics where possible, i.e. >sp = `:set paste`.
"

" paste mode
nnoremap <Leader>sp :set invpaste paste?<CR>
set pastetoggle=<Leader>sp

" line numbers
nnoremap <leader>sn :set nonumber! norelativenumber!<CR>

" toggle search highlights
nnoremap <leader>sh :set hlsearch!<CR>

" toggle invisibles
nnoremap <Leader>sl :set list!<CR>

" toggle conceal levels
nnoremap <Leader>sc :set conceallevel=

" toggle spell check
nnoremap <Leader>ss :set spell!<CR>

" change file type (not really a toggle but who's counting)
nnoremap <Leader>sf :set filetype=

" Toggle light/dark color
nnoremap <Leader>' :let &background=(&background =~# "dark"?"light":"dark")<CR>


"
" Functions / Macros
"

" run last :command

" substitute all occurrences of the word under the cursor
nnoremap <Leader>fk :%s/\<<C-r><C-w>\>//g<Left><Left>

" quick find/replace
nnoremap <Leader>fg :%s//g<Left><Left>

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
nnoremap <Leader>dc :RemoveFancyCharacters<CR>

" Get off my lawn (disables mouse support, which is too fancy to quit)
nnoremap <Left> :echo "Use h"<CR>
nnoremap <Right> :echo "Use l"<CR>
nnoremap <Up> :echo "Use k"<CR>
nnoremap <Down> :echo "Use j"<CR>

" su-DOH
cmap w!! w !sudo tee % >/dev/null

" close buffer
map Q :bd
" quick save
nnoremap W :w!<CR>
" quick no save
nnoremap QQ :q!<CR>

" start/end of line
" replaced default of H/L moving cursor to top/bottom +/- `scrolloff`
nnoremap H ^
vnoremap H ^
nnoremap L $
vnoremap L $

" yank all the things, and persist the cursor location
nnoremap <Leader>y ylpxggyGg;h
nnoremap <Leader>Y ylpxgg"*yGg;h

" shortcut to system clipboard
nnoremap Y "*y
vnoremap Y "*y

" source vimrc
nnoremap <leader>% :source $MYVIMRC<cr>

" source vimrc and install vundle plugins
nnoremap <Leader>^ :source $MYVIMRC <BAR> :PlugUpdate<CR>

" Create the `tags` file (may need to install ctags first)
command! MakeTags !ctags -R .
nnoremap <leader>. :MakeTags<CR>

" deal with next/prev spelling error and return to position
nnoremap <Leader>zn ]s1z=<C-o>
nnoremap <Leader>zp [s1z=<C-o>
" mark as good spelling
nnoremap <Leader>zgn ]szg<C-o>
nnoremap <Leader>zgp [szg<C-o>

" tidy up quickly
nnoremap <Leader>gq vapgq

" quickly switch to last buffer
nnoremap <Leader><Leader> :e#<CR>

" toggle indentation spaces
nnoremap <Leader>2 :set tabstop=2 shiftwidth=2<cr>
nnoremap <Leader>4 :set tabstop=4 shiftwidth=4<cr>

" fix indentation of entire buffer
nnoremap <Leader><Tab> gg=G''

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
nnoremap <Leader>fr :FindReplace<CR>

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
