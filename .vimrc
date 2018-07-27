"
" Vim Configuration
" This file is sourced by .config/nvim/init.vim for parity.
"

" Use the improved vi
" Must come first because it changes other options.
set nocompatible

" handle anyone crazy enough to use a non-POSIX compatible shell like fish
set shell=/bin/sh

"
" User settings
" There is probably a better convention for these.
"

" source $HOME/.vim/plugin-vundle.vim
source $HOME/.vim/user/plugins.vim
source $HOME/.vim/user/settings.vim
source $HOME/.vim/user/theme.vim
source $HOME/.vim/user/maps.vim
source $HOME/.vim/user/plugin-settings.vim

"
" Map Ideas
"

" g" is unmapped by default
" nnoremap g;
" gH (who TF uses select line mode anyway)
" nnoremap gH
" gK (unmapped by default)
" nnoremap gK
" gk (already remapped K to do gk)
" nnoremap gk
" gn (don't need to visually select search patterns
" nnoremap gn
" gP (don't need cursor moving after paste)
" nnoremap gP
" gF (unmapped by default)
" <C-h> and <C-L> (don't use them much)

