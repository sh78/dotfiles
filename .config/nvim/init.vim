" This file is hard-linked!
"" ~/.config/nvim/init.vim > ~/.vimrc

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

Plugin 'VundleVim/Vundle.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/vim-colors-solarized'
Plugin 'alvan/vim-closetag'
Plugin 'ap/vim-css-color'
Plugin 'junegunn/goyo.vim'
Plugin 'AndrewRadev/switch.vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'godlygeek/tabular'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'mattn/emmet-vim'
Plugin 'mattn/gist-vim'
Plugin 'mattn/webapi-vim'
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'scrooloose/syntastic'
Plugin 'mbbill/undotree'
"Plugin 'terryma/vim-multiple-cursors' " https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
Plugin 'tomtom/tlib_vim'
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
 " ______ _   _ _____       _____   ____  _____  ______            _____  ______
 " |  ____| \ | |  __ \     |  __ \ / __ \|  __ \|  ____|     /\   |  __ \|  ____|   /\
 " | |__  |  \| | |  | |    | |__) | |  | | |__) | |__       /  \  | |__) | |__     /  \
 " |  __| | . ` | |  | |    |  ___/| |  | |  ___/|  __|     / /\ \ |  _  /|  __|   / /\ \
 " | |____| |\  | |__| |    | |    | |__| | |    | |____   / ____ \| | \ \| |____ / ____ \
 " |______|_| \_|_____/     |_|     \____/|_|    |______| /_/    \_\_|  \_\______/_/    \_\
Plugin 'vim-scripts/SearchComplete'
Plugin 'lumiliet/vim-twig'
Plugin 'yuttie/comfortable-motion.vim'
Plugin 'mileszs/ack.vim'
Plugin 'Shougo/denite.nvim'
Plugin 'easymotion/vim-easymotion'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'edkolev/tmuxline.vim'


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

let mapleader = "\\"
set backspace=indent,eol,start    "" Intuitive backspacing.

"" Controversial...swap colon and semicolon for easier commands
nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;

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

let &colorcolumn="80,".join(range(100,999),",")
"highlight ColorColumn ctermbg=0 guibg=LightGrey

set incsearch                     "" Highlight matches as you type.
set hlsearch                      "" Highlight matches.

"" hide highlighting in insert mode
autocmd InsertEnter * :setlocal nohlsearch
autocmd InsertLeave * :setlocal hlsearch

set wrap                          "" Turn on line wrapping.
set scrolloff=3                   "" Show 3 lines of context around the cursor.

set title                         "" Set the terminal's title

set visualbell                    "" No beeping.

set nobackup                      "" Don't make a backup before overwriting a file.
set nowritebackup                 "" And again.
set noswapfile
set directory=/.vim/tmp

" Set spellfile location
set spellfile=$HOME/.vim-spell-en.utf-8.add

"" tab settings
set tabstop=2                    "" Global tab width.
set shiftwidth=2                 "" And again, related.
set shiftround                   "" use multiple of shiftwidth when indenting with '<' and '>'
set expandtab                    "" Use spaces instead of tabs
" set laststatus=2                  "" Show the status line all the time

set undofile                      " Maintain undo history between sessions
set undodir=~/.vim/undodir        " Keep all undo in one place

"" natural cursor movement between lines
nnoremap j gj
nnoremap k gk

" Disable automatic comment insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

"" Useful status information at bottom of screen
" set statusline=[%n]\ %<%.99f\ %h%w%m%r%y\ %{exists('*CapsLockStatusline')?CapsLockStatusline():''}%=%-16(\ %l,%c-%v\ %)%P


" # Autocompletion

" set complete =
set complete+=kspell
imap <Tab> <C-P>
imap <S><Tab> <C-N>

" Multipurpose tab key
" Indent if we're at the beginning of a line. Else, do completion.
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<C-n>"
    endif
endfunction
inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <C-n>

nnoremap QQ :q!<CR>


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

" Create the `tags` file (may need to install ctags first)
command! MakeTags !ctags -R .

nnoremap <leader>. :MakeTags<CR>

" Tweaks for browsing
let g:netrw_banner=0        " disable annoying banner
let g:netrw_browse_split=4  " open in prior window
let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'



" # Quick Toggles

"" paste mode
nnoremap <Leader>sp :set invpaste paste?<CR>
set pastetoggle=<Leader>sp
set showmode

"" line numbers
nnoremap <leader>sn :set nonumber! norelativenumber!<CR>

"" toggle search highlights
nnoremap <leader>si :set incsearch!<CR>
nnoremap <leader>sh :set hlsearch!<CR>

"" toggle invisibles
nnoremap <Leader>sl :set list!<CR>
set listchars=tab:▸\ ,eol:⌐


" # Theme

syntax enable
colorscheme solarized
hi Normal ctermbg=NONE

"" change background based on time
"" big ups to Garrett Oreilly @ https://coderwall.com/p/1b30wg
if strftime("%H") > 8 && strftime("%H") < 18
  set background=light
else
  set background=dark
endif

"" Toggle light/dark color
nnoremap <Leader>' :let &background=(&background == "dark"?"light":"dark")<CR>

"" crosshair cursor
set cursorline
set cursorcolumn


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


" # Functions

"" Quickly edit/reload the vimrc file
map <Leader>rv :source ~/.vimrc<cr>

"" substitute all occurrences of the word under the cursor
:nnoremap <Leader>fw :%s/\<<C-r><C-w>\>//g<Left><Left>

"" quick find/replace
:nnoremap <Leader>fg :%s//g<Left><Left>

"" Automatic fold settings for specific files. Uncomment to use.
"" autocmd FileType ruby setlocal foldmethod=syntax
"" autocmd FileType css  setlocal foldmethod=indent shiftwidth=2 tabstop=2

"" commit messages | http://robots.thoughtbot.com/post/48933156625/5-useful-tips-for-a-better-commit-message
autocmd Filetype gitcommit setlocal spell textwidth=72

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
:nnoremap <Leader>dc :RemoveFancyCharacte<CR>


" Get off my lawn (disables mouse support, which is too fancy to quit)
" nnoremap <Left> :echoe "Use h"<CR>
" nnoremap <Right> :echoe "Use l"<CR>
" nnoremap <Up> :echoe "Use k"<CR>
" nnoremap <Down> :echoe "Use j"<CR>

"" su-DOH
cmap w!! w !sudo tee % >/dev/null

"" reduce mistakes
:map Q <Nop>

"" kick vim into recognising moderm terminal color handling
"" if $TERM == "xterm-256color"" || $TERM == "screen-256color"" || $COLORTERM == "gnome-terminal"
""   set t_Co=256
"" endif


"" # Syntax-specifics

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  "autocmd BufReadPost *
  "  \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
  "  \   exe "normal g`\"" |
  "  \ endif

  " Set syntax type for markdown and txt
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile *.txt set filetype=text

  " Enable spellchecking for Markdown and txt
  autocmd FileType markdown setlocal spell
  autocmd FileType txt setlocal spell

  " Automatically wrap at 80 characters for Markdown and txt
  autocmd BufRead,BufNewFile *.md setlocal textwidth=80
  autocmd BufRead,BufNewFile *.txt setlocal textwidth=80

augroup END

"" # Plugins

"" inherit line column color for vim-gitgutter
highlight clear SignColumn

"" Ack
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

"" Goyo
" let g:goyo_width = 100
" let g:goyo_height = 90%

"" Mapping and settings for emmet
let g:user_emmet_expandabbr_key = '<Leader><Tab>'
let g:user_emmet_next_key = '<Leader>n'
let g:user_emmet_prev_key = '<Leader>N'

let g:user_emmet_settings = {
  'php' : {
    'extends' : 'html',
    'filters' : 'c',
  },
  'xml' : {
    'extends' : 'html',
  },
  'haml' : {
    'extends' : 'html',
  },
  'twig' : {
    'extends' : 'html',
  },
}

"" closetag.vim
":au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim

"" Marked build
:nnoremap <leader>b :silent !open -a Marked\ 2.app '%:p'<cr>

"" NERDTree
:nnoremap <Leader>t :NERDTreeToggle<CR>
:nnoremap <Leader>T :NERDTreeFind<CR>

"" mapping for NERDtree and autoclose
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

"" show hidden files in nerdtree
let NERDTreeShowHidden=1
"" auto delete buffer of deleted files
let NERDTreeAutoDeleteBuffer = 1
"" look nice
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

"" open nerdtree on start
"" autocmd VimEnter * NERDTree | wincmd p

" NERDCommenter
let g:NERDSpaceDelims = 1
let g:NERDCommentEmptyLines = 1

"" fix youcompleteme freezing vim after pressing dot
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_completion = 0

"" Vim Better Whitespace
:nnoremap <Leader>tw :ToggleWhitespace<CR>
:nnoremap <Leader>dw :StripWhitespace<CR>

"" Switch.vim
let g:switch_mapping = "-"

"" vim mustache handlebars
let g:mustache_abbreviations = 1

" comfortable-motion.vim - smooth scrolling
noremap <silent> <ScrollWheelDown> :call comfortable_motion#flick(40)<CR>
noremap <silent> <ScrollWheelUp>   :call comfortable_motion#flick(-40)<CR>

let g:comfortable_motion_no_default_key_mappings = 1
let g:comfortable_motion_impulse_multiplier = 1  " Feel free to increase/decrease this value.
nnoremap <silent> <C-d> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 2)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -2)<CR>
nnoremap <silent> <C-f> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 4)<CR>
nnoremap <silent> <C-b> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -4)<CR>

" tabularize
nnoremap <Leader>aa :Tabularize <CR>
nnoremap <Leader>a= :Tabularize /=<CR>
nnoremap <Leader>a: :Tabularize /:\zs<CR>
nnoremap <Leader>a- :Tabularize /-<CR>
nnoremap <Leader>a, :Tabularize /,<CR>
nnoremap <Leader>a< :Tabularize /\<<CR>
nnoremap <Leader>a\| :Tabularize /\|<CR>

" undotree - undo tree visualizer
nnoremap <C-z> :UndotreeToggle<CR>
let g:undotree_WindowLayout = 4
let g:undotree_ShortIndicators = 1
let g:undotree_DiffpanelHeight = 12
let g:undotree_HelpLine = 0


" fzf - fuzzy finder
set rtp+=/usr/local/opt/fzf


" denite
call denite#custom#option('default', 'prompt', '>')

call denite#custom#var('file/rec', 'command',
	\ ['ag', '--follow', '--nogroup', '-g', ''])

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

nnoremap <Leader><Leader> :Denite
nnoremap <Leader>p :Denite buffer file/rec<CR>
nnoremap <Leader>P :Denite command<CR>
nnoremap <Leader>k :DeniteCursorWord line<CR>
nnoremap <Leader>K :DeniteCursorWord tags<CR>

" Gist (snippets)
let g:gist_detect_filetype = 1
let g:gist_show_privates = 1
let g:gist_post_private = 1
let g:gist_get_multiplefile = 1
let g:gist_list_vsplit = 0
let g:gist_namelength = 40

nnoremap gil :Gist --list<CR>
nnoremap gip :Gist -public<CR>
nnoremap gid :Gist --delete<CR>
nnoremap gia :Gist --anonymous<CR>

" airline
set laststatus=2
let g:airline_theme='solarized'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled=1
let g:airline#extensions#branch#empty_message='☓'
let g:airline#extensions#hunks#enabled=0
let g:airline#extensions#whitespace#enabled=1

let g:airline_powerline_fonts = 1

" " uncomment if not using powerline patched font
" if !exists('g:airline_symbols')
"     let g:airline_symbols = {}
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


" tmuxline
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


" closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.twig,*.php'
let g:closetag_emptyTags_caseSensitive = 1
let closetag_close_shortcut = '<leader>>'

