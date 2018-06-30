" just in case your're fishing
set shell=/bin/sh

" # vundle plugins #

filetype plugin indent off     "" required!

"" setting up vundle - the vim plugin bundler
let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/Vundle.vim/README.md')
if !filereadable(vundle_readme)
  echo "Installing Vundle.."
  echo ""
  silent !mkdir -p ~/.vim/bundle
  silent !git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  let iCanHazVundle=0
endif
set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#rc()

 "  _______ _____ __  __     _____   ____  _____  ______             _____  ______
 " |__   __|_   _|  \/  |   |  __ \ / __ \|  __ \|  ____|      /\   |  __ \|  ____|   /\
    " | |    | | | \  / |   | |__) | |  | | |__) | |__        /  \  | |__) | |__     /  \
    " | |    | | | |\/| |   |  ___/| |  | |  ___/|  __|      / /\ \ |  _  /|  __|   / /\ \
    " | |   _| |_| |  | |   | |    | |__| | |    | |____    / ____ \| | \ \| |____ / ____ \
  " __|_|_ |_____|_|__|_|   |_|___  \____/|_|___ |______|  /_/    \_\_|__\_\______/_/    \_\
  " **************************************************///////////////////////(((((((((((((((
" *****************************************************//////////////////////(((((((((((((((
" *******************************************************/*////////////////////(((((((((((((
" ***********************************************/***********///////////////////((((((((((((
" ***********,,,,,,,,,,,,,,,,,,*,********//#&@@@@@&@&(/********////////////////////(((((((((
" **,**,,,,,,,,,,,,,,,,,,,,,,,,,,**///#%&@@@@@@@@@@@@@@@@&(/*******//////////////////(((((((
" ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*//#&@@@@@@@@@@@@@@@@@@@@@@&/*******//////////////////(((((
" ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,**/#&&@&&@@&&@@@@@@@@@@@@@@@@@@(/*****//////////////////((((
" ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*//&&%%%##(###%&&&&&&&&&&&@@@@@@@@(******/*///////////////(((
" ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,*%((/////((((((###%#%%%%%&&@@@@@@&/*******////////////////((
" ,,,,,,,,,,,,,,,,,,,,,,,,,,,,#//*******////((((#########%&@@@@@@@/********///////////////(
" ,,,,,,,,,,,,,,,,,,,,,,,,,,,(&/***********/////((((########%&@@@@@@@(********//////////////
" ,,,,,,,,,,,,,,,,,,,,,,,,,,/&****,*********//////(((((((###%&@@@@@@@@(*********////////////
" ,,,,,,,,,,,,,,,,..,...,,,#&**,,,,,,,,*,********/////((((((#&@@@@@@@@@***********//////////
" ,,,,,,,,,,...,,,......,*%&**,,,,,,,,,,,,,*******/////(((((#&&@@@@@@@@%/*********//////////
" ,,,,.,..,,............**%(**,,,,,,,,,,,,,*******///////(/(#%&@@@@@@@@@#***********////////
" ,,,.,................,,*%***,,,,,,,,,,*********//////////(%&&@@@@@@@@@@#**********////////
" ,.....................,*#**,,,,,,,,,,,,********//////////(%%&@@@@@@@@@@&(**********///////
" .......................,/*,,,,.....,,,,,,,,,*****/////((((%&@@@@@@@@@@@@%/*********///////
" ..,.....................,(//((//*,,,,,,**(####(((((/((((((%&@@@@@@@@@@@@@#/**********/////
" ........................,*(#(%%%(**,*//(####(((((((#((((((#&@@@@@@@@@@@@@##*************//
" ........................**/*,#%((/*,,*/(#((* .&#%#((/(((#&@@@%##@@@@@@@%#************////
" ......................../**/////*****//((//**///((((///(/((&@@#(##@&@@@@@&(*************//
" .......................,**//*******//((////*/////////////(#&@&&@@@@%@@@@@&(*************//
" .......................**,,*,,,****/((((///***/*/*//////(#&@@(%@@@@@@@@@@@(**************/
" ......................,*,,,,,,*,..,*//(((#/*******/////(#@@@@%&&&@@@@@@@@@(***************
" ......................**,,,****/*/(%@&((%%(*******////((&@@@%((#&@@@@@@@@@/**************/
" ......................*****/**//*/*//(/////*****///((((#@@@@%%@&&@@@@@@@@%****************
" ......................,/*,/%#********//((((//////((/((#%@@@@@@@@@@@@@@@@@(****************
" .......................//**/**//*/((##%%%%%%/**//(#(((#&@@@@@@@@@@@@@@@@@/****************
" .......................#********/*/////((///***/((((((%@@@@@@@@@@@@@@@@@&/****************
" .......................#(////****///***//(((///(((((#%@@@&@@@@@@@@@@@@@@%*****************
" ......................**##////**,**/((((##(((((####%&@@@#%@@@@@@@@@@@@@@(*****************
" ......................#,@&&(/*,*/*,*/((((((##%%%%%&@@@#/(@@@@@@@@@@@@@@&(*,***************
" .....................*/%&&@&((#(/((##%%%&&&&@&&@%((//(%@@@@@@@@@&@@@@#(*,****************
" ....................*/#%&@&&(@@%%&@@@@@@@@@@&&@#((///(&@@@@@@@@@@@@@%//******************
" ...................,(/(&@@%%@@@(,/(%&&&&@@&&%#%#((////(%@@@@@@@@@@@@@&(**,****************
" .................,,(*&%@&@@@@(*,*,,,**///////****///(&@@@@@@@@@@@@@(**,***,,*************
" ,..............,,***#@@%/&@@@@@#*,,,**********,,,****(%&@@@@@@@@@@@@@@@&/*,***************
" ..............,,,/*#@(%(##@@@@&*,,,,.,,,,,,,,,,,,,,**(&@@@@@@@@@@@@@@@@@@@@%#/************
" ,...........,,,,/*%%(//#(@@@@%&(,,,,,..,,,,,,.,,,,*%@@@@@@@@@@@@@@@@@@@@@@@@@@@&/*********
" ,,,........,,,,**##(*(*(@@@@&@@/,,..,......,...,#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#******
" ,,,,,...,..,,,******#@@@@@@@@&/,.........,(&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&@&@@@@%****
" ,,,,,,,,,,,,,,**(%,,/&@@@@@@@@@@@@%(((#%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&&@@@@@@@@@&/
" ,,,,,,,,,..,****#%&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&@@@@@@@@@@@@@@@@
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-speeddating'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-vinegar'
 " ______ _   _ _____       _____   ____  _____  ______            _____  ______
 " |  ____| \ | |  __ \     |  __ \ / __ \|  __ \|  ____|     /\   |  __ \|  ____|   /\
 " | |__  |  \| | |  | |    | |__) | |  | | |__) | |__       /  \  | |__) | |__     /  \
 " |  __| | . ` | |  | |    |  ___/| |  | |  ___/|  __|     / /\ \ |  _  /|  __|   / /\ \
 " | |____| |\  | |__| |    | |    | |__| | |    | |____   / ____ \| | \ \| |____ / ____ \
 " |______|_| \_|_____/     |_|     \____/|_|    |______| /_/    \_\_|  \_\______/_/    \_\
"Plugin 'terryma/vim-multiple-cursors' " https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
Plugin 'AndrewRadev/switch.vim'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'Shougo/denite.nvim'
Plugin 'Shougo/deoplete.nvim'
if !has('nvim')
  Plugin 'roxma/nvim-yarp'
  Plugin 'roxma/vim-hug-neovim-rpc'
endif
Plugin 'Shougo/neco-syntax'
Plugin 'carlitux/deoplete-ternjs'
Plugin 'ternjs/tern_for_vim'
Plugin 'lvht/phpcd.vim'
Plugin 'zchee/deoplete-jedi'
Plugin 'Shougo/deoplete-clangx'
" Plugin 'thalesmello/webcomplete.vim'
Plugin 'fszymanski/deoplete-emoji'
Plugin 'Shougo/neosnippet.vim'
Plugin 'Shougo/neosnippet-snippets'
Plugin 'VundleVim/Vundle.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/vim-colors-solarized'
Plugin 'ap/vim-css-color'
Plugin 'christoomey/vim-titlecase'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'easymotion/vim-easymotion'
Plugin 'edkolev/tmuxline.vim'
Plugin 'francoiscabrol/ranger.vim'
Plugin 'godlygeek/tabular'
Plugin 'jasonlong/vim-textobj-css'
Plugin 'jceb/vim-textobj-uri'
Plugin 'jremmen/vim-ripgrep'
Plugin 'junegunn/goyo.vim'
Plugin 'kana/vim-textobj-entire'
Plugin 'kana/vim-textobj-line'
Plugin 'kana/vim-textobj-user'
Plugin 'lambdalisue/vim-gista'
Plugin 'machakann/vim-highlightedyank'
Plugin 'mattn/emmet-vim'
Plugin 'mattn/webapi-vim'
Plugin 'mbbill/undotree'
Plugin 'mileszs/ack.vim'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'rbgrouleff/bclose.vim'
Plugin 'rking/ag.vim'
Plugin 'w0rp/ale'
Plugin 'sheerun/vim-polyglot'
Plugin 'shime/vim-livedown'
Plugin 'tomtom/tlib_vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-scripts/SearchComplete'
Plugin 'whatyouhide/vim-textobj-xmlattr'
Plugin 'dag/vim-fish'
Plugin 'heavenshell/vim-jsdoc'
" add plugins here ^

if iCanHazVundle == 0
  echo "Installing Bundles, please ignore key map error messages"
  echo ""
  :PluginInstall
endif

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto - approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

"" Vundler end

filetype plugin indent on      "" Turn file type detection back on

" load matchit plugin
runtime macros/matchit.vim


" # General settings

" let mapleader = "\\"
" make space the <Leader> but keep visual indication that <Leader> was pressed
:map <Space> <Leader>

set backspace=indent,eol,start    "" Intuitive backspacing.

"" Controversial...swap colon and semicolon for easier commands
:nnoremap ; :
:nnoremap : ;
:vnoremap ; :
:vnoremap : ;

set nocompatible                  "" Must come first because it changes other options.
set hidden                        "" Keep buffers open.

set encoding=utf-8

set showcmd                       "" Display incomplete commands.
set showmode                      "" Display the mode youre in.

set autoindent
set smartindent

set ignorecase                    "" Case-insensitive searching.
set smartcase                     "" But case-sensitive if expression contains a capital letter.

set nonumber!                     "" Show line numbers.
set relativenumber                "" hybrid number mode
set ruler                         "" Show cursor position.
set numberwidth=4                 "" Make some room.

set incsearch                     "" Highlight matches as you type.
set hlsearch                      "" Highlight matches.

"" hide highlighting in insert mode
autocmd InsertEnter * :setlocal nohlsearch
autocmd InsertLeave * :setlocal hlsearch

set wrap                          "" Turn on line wrapping.
set scrolloff=2                   "" Show 3 lines of context around the cursor.

set title                         "" Set the terminal's title
set visualbell                    "" No beeping.

set nobackup                      "" Don't make a backup before overwriting a file.
set nowritebackup                 "" And again.
set noswapfile
set directory=/.vim/tmp

setlocal spell spelllang=en_us
set spellfile=$HOME/.vim/spell/en.utf-8.add
set thesaurus+=$HOME/.vim/thesaurus/mthesaur.txt

"" tab settings
set tabstop=2                    "" Global tab width.
set shiftwidth=2                 "" And again, related.
set shiftround                   "" use multiple of shiftwidth when indenting with '<' and '>'
set expandtab                    "" Use space          of tabs
" set laststatus=2                  "" Show the status line all the time

set undofile                      " Maintain undo history between sessions
set undodir=~/.vim/undodir        " Keep all undo in one place

"" natural cursor movement between lines
:nnoremap j gj
:nnoremap k gk

"" Useful status information at bottom of screen
" set statusline=[%n]\ %<%.99f\ %h%w%m%r%y\ %{exists('*CapsLockStatusline')?CapsLockStatusline():''}%=%-16(\ %l,%c-%v\ %)%P


" # File Types: Syntax-specific settings


" # Auto completion

" set complete =
set complete+=kspell
" imap <Tab> <C-P>
" imap <S-Tab> <C-N>

" Multipurpose tab key
" Indent if we're at the beginning of a line. Else, do completion.
" function! InsertTabWrapper()
"   let col = col('.') - 1
"   if !col || getline('.')[col - 1] !~ '\k'
"     return "\<tab>"
"   else
"     return "\<C-n>"
"   endif
" endfunction
" inoremap <expr> <tab> InsertTabWrapper()
" inoremap <s-tab> <C-n>

:nnoremap QQ :q!<CR>


" # File Navigation

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=.,**

" Display all matching files when we tab complete
set wildmenu
"set wildmode=list:longest         "" Complete files like a shell.

" Don't offer to open certain files/directories
"" respected by :Denite file/rec
set wildignore+=.git,.svn,.DS_Store,.npm,.vagrant,*.zip,*.tgz,*.pdf,*.psd,*.ai,*.mp3,*.mp4,*.bmp,*.ico,*.jpg,*.png,*.gif,*.epub,.hg,.dropbox,.config,.cache,*.pyc
set wildignore+=node_modules/*,bower_components/*,*.min.*

" look more common places for ctags file than just ./tags,tags
set tags+=./.git/tags,./.tags

" Tweaks for browsing
let g:netrw_banner=0        " disable annoying banner
let g:netrw_browse_split=4  " open in prior window
let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view
let g:netrw_winsize = 25    " set width like a standard file drawer
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'



" # Quick Toggles

"" paste mode
:nnoremap <Leader>sp :set invpaste paste?<CR>
set pastetoggle=<Leader>sp

"" line numbers
:nnoremap <leader>sn :set nonumber! norelativenumber!<CR>

"" toggle search highlights
:nnoremap <leader>si :set incsearch!<CR>
:nnoremap <leader>sh :set hlsearch!<CR>

"" toggle invisibles
:nnoremap <Leader>sl :set list!<CR>
set listchars=tab:▸\ ,eol:⌐

"" toggle conceal levels
:nnoremap <Leader>sc :set conceallevel=

"" toggle spell check
:nnoremap <Leader>ss :set spell!<CR>

"" change file type (not really a toggle but who's counting)
:nnoremap <Leader>sf :set filetype=


" # Theme

"" TODO: better terminal awareness... needed?
"" kick vim into recognising modern terminal color handling
" if $TERM == "xterm-256color"" || $TERM == "screen-256color"" || $COLORTERM == "gnome-terminal"
"   set t_Co=256
" endif

syntax enable
hi Normal ctermbg=NONE
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
" set termguicolors
colorscheme solarized

"" change background based on env variable
" alternate -
" if strftime("%H") > 8 && strftime("%H") < 18
if $COLOR == "light"
  set background=light
else
  set background=dark
endif

"" Toggle light/dark color
:nnoremap <Leader>' :let &background=(&background == "dark"?"light":"dark")<CR>

"" crosshair cursor
set cursorline
set cursorcolumn

let &colorcolumn="80,".join(range(100,999),",")
"highlight ColorColumn ctermbg=0 guibg=LightGrey

" italic comments
highlight Comment cterm=italic


" # Tabs Windows & Beyond

"" open new panes to right/bottom
set splitbelow
set splitright

"" Tab mappings.
map <Leader>tt :tabnew<cr>
map <Leader>te :tabedit
map <Leader>tc :tabclose<cr>
map <Leader>to :tabonly<cr>
map <Leader>tn :tabnext<cr>
map <Leader>tp :tabprevious<cr>
map <Leader>tf :tabfirst<cr>
map <Leader>tl :tablast<cr>
map <Leader>tm :tabmove


" # Functions / Macros

"" substitute all occurrences of the word under the cursor
:nnoremap <Leader>fk :%s/\<<C-r><C-w>\>//g<Left><Left>

"" quick find/replace
:nnoremap <Leader>fg :%s//g<Left><Left>

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
  :exe ":%s/".join(keys(typo), '\|').'/\=typo[submatch(0)]/ge'
endfunction
command! RemoveFancyCharacters :call RemoveFancyCharacters()
:nnoremap <Leader>dc :RemoveFancyCharacters<CR>

" Get off my lawn (disables mouse support, which is too fancy to quit)
:nnoremap <Left> :echo "Use h"<CR>
:nnoremap <Right> :echo "Use l"<CR>
:nnoremap <Up> :echo "Use k"<CR>
:nnoremap <Down> :echo "Use j"<CR>

" su-DOH
cmap w!! w !sudo tee % >/dev/null

" reduce mistakes
:map Q <Nop>

" quick save
:nnoremap W :w!<CR>

" yank all the things, and persist the cursor location
:nnoremap <Leader>y ylpxggyGg;h
:nnoremap <Leader>Y ylpxgg"*yGg;h

" shortcut to system clipboard
:nnoremap Y "*y
:vnoremap y "*y

" source vimrc
:nnoremap <leader>% :source $MYVIMRC<cr>

" source vimrc and install vundle plugins
:nnoremap <Leader>^ :source $MYVIMRC <BAR> :BundleInstall<CR>

" Create the `tags` file (may need to install ctags first)
command! MakeTags !ctags -R .
:nnoremap <leader>. :MakeTags<CR>

" deal with next/prev spelling error and return to position
:nnoremap <Leader>zn ]s1z=<C-o>
:nnoremap <Leader>zp [s1z=<C-o>
:nnoremap <Leader>zgn ]szg<C-o>
:nnoremap <Leader>zgp [szg<C-o>

" tidy up quickly
:nnoremap <Leader>gq vapgq

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
  :redraw
  if confirm == 'y'
    " find with rigrep (populate quickfix )
    :silent exe 'Rg ' . find
    " use cfdo to substitute on all quickfix files
    :silent exe 'cfdo %s/' . find . '/' . replace . '/g | update'
    " close quickfix window
    :silent exe 'cclose'
    :echom('Replaced ' . find . ' with ' . replace . ' in all files in ' . dir )
  else
    :echom('Find/Replace Aborted :(')
    return
  endif
endfunction
:nnoremap <Leader>fr :call FindReplace()<CR>


" # Syntax-specifics

" Disable automatic comment insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" commit messages | http://robots.thoughtbot.com/post/48933156625/5-useful-tips-for-a-better-commit-message
autocmd Filetype gitcommit setlocal spell textwidth=72

"  markdown
" autocmd BufNewFile,BufReadPost *.md,*.markdown set filetype=markdown
autocmd FileType markdown,text setlocal spell textwidth=80 conceallevel=2
let g:vim_markdown_fenced_languages = ['c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini', 'bash=shell', 'javascript=js', 'php=php', 'html=html', 'css=css']
let g:vim_markdown_new_list_item_indent = 0

" When editing a file, always jump to the last known cursor position.
" Don't do it for commit messages, when the position is invalid, or when
" inside an event handler (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif


"" # Plugins

"" vim-gitgutter inherit line column color
highlight clear SignColumn
"" prevent conflict w/ vim-textobj-css
omap ih <Plug>GitGutterTextObjectInnerPending
omap ah <Plug>GitGutterTextObjectOuterPending
xmap ih <Plug>GitGutterTextObjectInnerVisual
xmap ah <Plug>GitGutterTextObjectOuterVisual

"" Ack
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

"" Goyo
noremap <Leader>G :Goyo<CR>
let g:goyo_width = 80
let g:goyo_margin_top = 3
let g:goyo_margin_bottom = 3

function! s:goyo_enter()
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

"" Mapping and settings for emmet
let g:user_emmet_expandabbr_key = '<C-y>y'
let g:user_emmet_settings = {
  \  'php' : {
  \    'extends' : 'html',
  \    'filters' : 'c',
  \  },
  \  'xml' : {
  \    'extends' : 'html',
  \  },
  \  'haml' : {
  \    'extends' : 'html',
  \  },
  \  'twig' : {
  \    'extends' : 'html',
  \  },
  \}

"" closetag.vim
":au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim

"" Marked build
:nnoremap <leader>b :silent !open -a Marked\ 2.app '%:p'<cr>

"" NERDTree
" :nnoremap <Leader>t :NERDTreeToggle<CR>
" :nnoremap <Leader>T :NERDTreeFind<CR>
" " show hidden files in nerdtree
" let NERDTreeShowHidden=1
" " auto delete buffer of deleted files
" let NERDTreeAutoDeleteBuffer = 1
" " look nice
" let NERDTreeMinimalUI = 1
" let NERDTreeDirArrows = 1

" mapping for NERDtree and autoclose
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
" open nerdtree on start
" autocmd VimEnter * NERDTree | wincmd p

"" fix youcompleteme freezing vim after pressing dot
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_completion = 0

"" Vim Better Whitespace
:nnoremap <Leader>tw :ToggleWhitespace<CR>
:nnoremap <Leader>dw :StripWhitespace<CR>

"" Switch.vim
let g:switch_mapping = '-'
let g:switch_custom_definitions =
  \ [
  \   ['foo', 'bar', 'baz'],
  \   ["is', 'isn't"],
  \   ['old', 'new'],
  \   ['previous', 'next'],
  \   ['first', 'last'],
  \   ['before', 'after'],
  \   ['dark', 'light'],
  \   ['opaque', 'transparent'],
  \   ['black', 'white'],
  \   ['staging', 'production'],
  \   ['http', 'https'],
  \   ['+', '-'],
  \ ]

"" vim mustache handlebars
let g:mustache_abbreviations = 1

"" tabularize
:nnoremap <Leader>aa :Tabularize <CR>
:nnoremap <Leader>a= :Tabularize /=<CR>
:nnoremap <Leader>a: :Tabularize /:\zs<CR>
:nnoremap <Leader>a- :Tabularize /-<CR>
:nnoremap <Leader>a, :Tabularize /,<CR>
:nnoremap <Leader>a< :Tabularize /\<<CR>
:nnoremap <Leader>a\| :Tabularize /\|<CR>

"" undotree - undo tree visualizer
:nnoremap <C-z> :UndotreeToggle<CR>
let g:undotree_WindowLayout = 4
let g:undotree_ShortIndicators = 1
let g:undotree_DiffpanelHeight = 12
let g:undotree_HelpLine = 0

"" fzf - fuzzy finder
set rtp+=/usr/local/opt/fzf

"" denite
call denite#custom#option('default', 'prompt', '>')

call denite#custom#var('file/rec', 'command',
	\ ['ag', '--follow', '--nogroup', '-g', ''])

call denite#custom#var('grep', 'command', ['rg'])
call denite#custom#var('grep', 'default_opts',
    \ ['--vimgrep', '--no-heading'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

call denite#custom#map(
  \ 'insert',
  \ '<C-j>',
  \ '<denite:move_to_next_line>',
  \ 'noremap'
  \)
call denite#custom#map(
  \ 'insert',
  \ '<C-k>',
  \ '<denite:move_to_previous_line>',
  \ 'noremap'
  \)

" these are mapped to avoid the leader/ctrl for ease
" attempting to follow vim convention of 'g' going or jumping
:nnoremap gp :Denite buffer file/rec<CR>
:nnoremap ;; :Denite command<CR> " search commands
:nnoremap gr :DeniteBufferDir grep:. -mode=normal<CR> " gr unmapped by default
:nnoremap gk :DeniteCursorWord line<CR> " gk (already remapped k to do gk)
:nnoremap gK :DeniteCursorWord grep:. -mode=normal<CR> " gK (unmapped by default)
:nnoremap gn :DeniteCursorWord tags -mode=normal<CR> " (don't need to visually select search patterns
:nnoremap gh :Denite help<CR> " gh (who TF uses select mode anyway)
:nnoremap gH :DeniteCursorWord help<CR> " gH (who TF uses select line mode anyway)
:nnoremap g; :Denite change -mode=normal<CR> " g; (don't need to go to a change from memory, and using :Denite change is nicer)

" :nnoremap <Leader><Leader>

" maybe eunuch :Find?" gF (unmapped by default)
" gP (don't need cursor moving after paste)

"" Gista (snippets)
let g:gista#command#post#default_public = 0
let g:gista#command#post#allow_empty_description = 1
" Always request updated gists in :Gista list
let g:gista#command#list#default_options = {
  \ 'cache': 0,
\}

:nnoremap <Leader>gl :Gista list<CR>
:nnoremap <Leader>gb :Gista browse
:nnoremap <Leader>gpr :Gista post --private<CR>
:nnoremap <Leader>gpu :Gista post --public<CR>
:nnoremap <Leader>ga :Gista post --anonymous<CR>
:nnoremap <Leader>gd :Gista --delete<CR>
:nnoremap <Leader>gs :Gista star<CR>
:nnoremap <Leader>gu :Gista unstar<CR>


"" airline
set laststatus=2
let g:airline_theme='solarized'
let g:airline_powerline_fonts = 1

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#branch#empty_message='☓'
let g:airline#extensions#hunks#enabled=0
let g:airline#extensions#whitespace#enabled=1

" " uncomment if not using powerline patched font
" if !exists('g:airline_symbols')
"   let g:airline_symbols = {}
" endif

" " unicode symbols
" let g:airline_left_sep = '»'
" let g:airline_left_sep = '▶'
" let g:airline_right_sep = '«'
" let g:airline_right_sep = '◀'
" let g:airline_symbols.linenr = '␊'
" let g:airline_symbols.linenr = '␤'
" let g:airline_symbols.linenr = '¶'
" let g:airline_symbols.branch = '⎇'
" let g:airline_symbols.paste = 'ρ'
" let g:airline_symbols.whitespace = 'Ξ'

" " airline symbols
" let g:airline_left_sep = ''
" let g:airline_left_alt_sep = ''
" let g:airline_right_sep = ''
" let g:airline_right_alt_sep = ''
" let g:airline_symbols.branch = ''
" let g:airline_symbols.readonly = ''
" let g:airline_symbols.linenr = ''

"" tmuxline
" let g:tmuxline_preset = 'full'
let g:tmuxline_preset = {
  \'a'       : '#S:#I',
  \'b disabled'       : '',
  \'c disabled'       : '',
  \'win'     : ['#I', '#W'],
  \'cwin'    : ['#I', '#W'],
  \'x'       : '#(~/.bin/executables/tmux-battery 🔋 🔌 ⚡️ 10)',
  \'y'       : ['%a', '%Y-%m-%d', '%H:%M'],
  \'z disabled'       : '',
  \'options' : {'status-justify': 'left'}}

"" closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.twig,*.php'
let g:closetag_emptyTags_caseSensitive = 1
let closetag_close_shortcut = '<leader>>'

"" highlighted yank
let g:highlightedyank_highlight_duration = 700

"" ranger.vim
map <leader>rr :RangerEdit<cr>
" map <leader>rv :RangerVSplit<cr>
" map <leader>rs :RangerSplit<cr>
" map <leader>rt :RangerTab<cr>
" map <leader>ri :RangerInsert<cr>
" map <leader>ra :RangerAppend<cr>
" map <leader>rc :set operatorfunc=RangerChangeOperator<cr>g@
let g:ranger_replace_netrw = 0

"" titlecase
" let g:titlecase_map_keys = 0
" nmap <leader>gt <Plug>Titlecase
" vmap <leader>gt <Plug>Titlecase
" nmap <leader>gT <Plug>TitlecaseLine

"" livedown (markdown)
nmap gm :LivedownToggle<CR>

"" easy motion
map <C-m> <Plug>(easymotion-prefix)

"" Ale linter
let g:ale_sign_error = '🚫 '
let g:ale_sign_warning = '⚠️ '
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_delay = 800"
nmap <silent> <C-h> <Plug>(ale_previous_wrap)
nmap <silent> <C-l> <Plug>(ale_next_wrap)

"" Use deoplete.
let g:deoplete#enable_at_startup = 1
" Disable the candidates in Comment/String syntaxes.
call deoplete#custom#source('_',
  \ 'disabled_syntaxes', ['Comment', 'String'])
let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
let g:deoplete#ignore_sources.php = ['omni']

"" neosnippet
" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <expr><TAB>
  \ pumvisible() ? "\<C-n>" :
  \ neosnippet#expandable_or_jumpable() ?
  \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

"" JSDoc
nmap <silent> <Leader>jd <Plug>(jsdoc)
