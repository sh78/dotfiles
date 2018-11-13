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
    autocmd BufEnter,FocusGained,VimEnter,WinEnter * call FocusBuffer()
    autocmd FocusLost,WinLeave * call UnfocusBuffer()
augroup END

" hide highlighting in insert mode
autocmd InsertEnter * setlocal nohlsearch
autocmd InsertLeave * setlocal hlsearch

" hide highlighting in normal mode, after some time
autocmd CursorHold,CursorHoldI * setlocal nohlsearch

" TODO: show cursor highlight again if cycling through matches
" autocmd CursorMoved * :setlocal hlsearch
" nmap n setlocal hlsearch<CR><bar>n
" nmap N setlocal hlsearch<CR><bar>N

autocmd FileType crontab setlocal nowritebackup
