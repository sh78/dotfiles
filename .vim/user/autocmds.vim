"
" Auto Commands (Global)
"

" Set format options
" :help fo-table
autocmd FileType * setlocal formatoptions+=c formatoptions-=r formatoptions-=o

" When editing a file, always jump to the last known cursor position.
" Don't do it for commit messages, when the position is invalid, or when
" inside an event handler (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if &ft != 'gitcommit' && &ft != 'svn' && line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif


" focus (these should be grouped into a function and called together)
augroup focus_bg
    autocmd!
    autocmd BufEnter,FocusGained,VimEnter,WinEnter * let &colorcolumn=join(range(81,999), ',')
    autocmd FocusLost,WinLeave * let &colorcolumn=join(range(1,999), ',')
augroup END

augroup focus_cursor
    autocmd!
    autocmd BufEnter,FocusGained,VimEnter,WinEnter * set cursorline cursorcolumn
    autocmd FocusLost,WinLeave * set nocursorline nocursorcolumn
augroup END
