"
" Theme
"

syntax enable
hi Normal ctermbg=NONE
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
" set termguicolors
colorscheme solarized

" change background based on env variable
" fallback to time-based solution
if $COLOR =~# 'light'
  set background=light
elseif $COLOR =~# 'dark'
  set background=dark
elseif strftime('%H') > 8 && strftime('%H') < 18
  set background=light
else
  set background=dark
endif

" crosshair cursor
set cursorline
set cursorcolumn

let &colorcolumn=join(range(81,999), ',')
" let &colorcolumn="81,".join(range(100,999),",")
" highlight ColorColumn ctermbg=0 guibg=LightGrey

" italic comments
highlight Comment cterm=italic

