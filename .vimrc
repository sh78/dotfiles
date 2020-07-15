"
" Vim Configuration
" This file is sourced by .config/nvim/init.vim for parity.
"

" Use the improved vi
" Must come first because it changes other options.
set nocompatible

" handle anyone crazy enough to use a non-POSIX compatible shell like fish
set shell=/bin/sh

set encoding=UTF-8

"
" User settings
" There is probably a better convention for these.
"

function! SourceIfExists(file)
  if filereadable(expand(a:file))
    exe 'source' a:file
  endif
endfunction

call SourceIfExists('$HOME/.vim/user/plugins.vim')
call SourceIfExists('$HOME/.vim/user/settings.vim')
call SourceIfExists('$HOME/.vim/user/functions.vim')
call SourceIfExists('$HOME/.vim/user/autocmds.vim')
call SourceIfExists('$HOME/.vim/user/theme.vim')
call SourceIfExists('$HOME/.vim/user/plugin-settings.vim')
call SourceIfExists('$HOME/.vim/user/maps.vim')
call SourceIfExists('$HOME/.vim/user/abbreviations.vim')
