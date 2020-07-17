"
" Theme
"

syntax enable

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

set signcolumn=yes:2

" Separate splits with an unobtrusive line
set fillchars=vert:│
hi VertSplit ctermbg=NONE guibg=NONE

" Fade out bg outside of textwidth using colorcolumn hack
" let &colorcolumn=join(range(&textwidth + 1,999), ',')

" for italic comments
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"


"" Override font/colors
highlight Comment cterm=italic gui=italic
highlight Normal ctermbg=NONE
highlight MatchParen ctermbg=NONE cterm=bold guibg=NONE gui=bold
highlight LineNr term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE
highlight CursorLineNr term=bold cterm=NONE gui=bold
highlight SignColumn term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=bold guibg=NONE
highlight SignifySignAdd term=bold cterm=bold ctermbg=NONE gui=bold guibg=NONE
highlight SignifySignChange term=bold cterm=bold ctermbg=NONE gui=bold guibg=NONE
highlight SignifySignDelete term=bold cterm=bold ctermbg=NONE gui=bold guibg=NONE
