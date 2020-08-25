"
" Theme
"

syntax enable

" Shoot for nice 24 bit color and italic comments
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"

set termguicolors
if !has('termguicolors')
  " fall back to 256 colors for base16
  let base16colorspace=256
endif

" Base16-vim
if filereadable(expand("~/.vimrc_background"))
  source ~/.vimrc_background
endif


" crosshair cursor
set cursorline
set cursorcolumn

set signcolumn=yes:1

" Separate splits with an unobtrusive line
set fillchars=vert:│
hi VertSplit ctermbg=NONE guibg=NONE

" Fade out bg outside of textwidth using colorcolumn hack
let &colorcolumn=join(range(&textwidth + 1,999), ',')

"" Override font/colors
highlight Comment cterm=italic gui=italic
highlight Normal ctermbg=NONE guibg=NONE
highlight MatchParen ctermbg=NONE cterm=bold gui=bold guibg=NONE
" highlight ColorColumn ctermbg=NONE guibg=#112233
highlight LineNr
  \ term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE
  \ gui=NONE guifg=DarkGrey guibg=NONE
highlight CursorLineNr term=bold cterm=NONE gui=bold
highlight SignColumn
  \ term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE
  \ gui=NONE guifg=bold guibg=NONE
highlight SignifySignAdd
  \ term=bold cterm=bold ctermbg=NONE
  \ gui=bold guibg=DarkGreen guifg=LightGreen
highlight SignifySignChange
  \ term=bold cterm=bold ctermbg=NONE
  \ gui=bold guibg=NONE guifg=DarkYellow
highlight SignifySignDelete
  \ term=bolditalic cterm=bolditalic ctermbg=NONE
  \ gui=bolditalic guibg=DarkRed guifg=LightRed

