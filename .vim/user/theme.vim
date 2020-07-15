"
" Theme
"

syntax enable
highlight Normal ctermbg=NONE
highlight MatchParen ctermbg=NONE cterm=bold guibg=NONE gui=bold

" Base16-vim
set termguicolors
colorscheme base16-default-dark
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

" crosshair cursor
" set cursorline
" set cursorcolumn

" Fade out bg outside of textwidth using colorcolumn hack
let &colorcolumn=join(range(&textwidth + 1,999), ',')

" for italic comments
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
highlight Comment cterm=italic gui=italic

