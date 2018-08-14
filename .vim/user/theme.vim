"
" Theme
"

syntax enable
hi Normal ctermbg=NONE
hi MatchParen ctermbg=none cterm=bold guibg=none gui=bold

" for italic comments
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
highlight Comment cterm=italic gui=italic

" Base16-vim
set termguicolors
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

" crosshair cursor
set cursorline
set cursorcolumn

let &colorcolumn=join(range(81,999), ',')
" let &colorcolumn="81,".join(range(100,999),",")
" highlight ColorColumn ctermbg=0 guibg=LightGrey
