" just in case your're fishing
set shell=/bin/sh

" # vundle plugins #

filetype plugin indent off     "" required!

"" brief help
"" :bundlelist          - list configured bundles
"" :bundleinstall(!)    - install (update) bundles
"" :bundlesearch(!) foo - search (or refresh cache first) for foo
"" :bundleclean(!)      - confirm (or auto-approve) removal of unused bundles

"" see :h vundle for more details or wiki for faq
"" note: comments after bundle commands are not allowed. repos on github

"" setting up vundle - the vim plugin bundler
let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/readme.md')
if !filereadable(vundle_readme)
    echo "installing vundle.."
    echo ""
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
    let iCanHazVundle=0
endif
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/vim-colors-solarized'
Plugin 'alvan/vim-closetag'
Plugin 'AndrewRadev/switch.vim'
Plugin 'bling/vim-airline'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'edkolev/tmuxline.vim'
Plugin 'garbas/vim-snipmate'
Plugin 'gmarik/vundle'
Plugin 'godlygeek/tabular'
Plugin 'groenewege/vim-less'
Plugin 'kien/ctrlp.vim'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'mattn/emmet-vim'
Plugin 'mattn/gist-vim'
Plugin 'mattn/webapi-vim'
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'rizzatti/dash.vim'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'scrooloose/syntastic'
Plugin 'sjl/clam.vim'
Plugin 'sjl/gundo.vim'
Plugin 'slim-template/vim-slim'
"Plugin 'terryma/vim-multiple-cursors' " https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
Plugin 'tomtom/tlib_vim'
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
"Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-scripts/SearchComplete'
"Plugin 'beyondwords/vim-twig'
"Plugin 'lumiliet/vim-twig'
Plugin 'qbbr/vim-twig'
Plugin 'junegunn/fzf'
Plugin 'yuttie/comfortable-motion.vim'


if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif
"" Vundler end


" # Example Vim configuration from Peepcode Smash Into Vim
"" https://peepcode.com/products/smash-into-vim-i

set nocompatible                  "" Must come first because it changes other options.

 filetype plugin indent on      "" Turn on file type detection.

set hidden                        "" Keep buffers open.

runtime macros/matchit.vim        "" Load the matchit plugin.

set showcmd                       "" Display incomplete commands.
set showmode                      "" Display the mode youre in.

set complete+=kspell

set autoindent
set smartindent

" Disable automatic comment insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o


let mapleader = ","
set backspace=indent,eol,start    "" Intuitive backspacing.

"" Controversial...swap colon and semicolon for easier commands
nnoremap ; :
nnoremap : ;

vnoremap ; :
vnoremap : ;

set wildmenu                      "" Enhanced command line completion.
set wildmode=list:longest         "" Complete files like a shell.

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
set laststatus=2                  "" Show the status line all the time

set undofile                      " Maintain undo history between sessions
set undodir=~/.vim/undodir        " Keep all unod in one place

"" Useful status information at bottom of screen
set statusline=[%n]\ %<%.99f\ %h%w%m%r%y\ %{exists('*CapsLockStatusline')?CapsLockStatusline():''}%=%-16(\ %l,%c-%v\ %)%P


" # Quick Toggles #

"" quick toggle paste mode
nnoremap <Leader>sp :set invpaste paste?<CR>
set pastetoggle=<Leader>sp
set showmode

"" line numbers
nnoremap <leader>sn :set nonumber! norelativenumber!<CR>

"" toggle search highlights
nnoremap <leader>si :set incsearch!<CR>
nnoremap <leader>sh :set hlsearch!<CR>


" # Color-scheming #

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
nnoremap <leader>b :let &background=(&background == "dark"?"light":"dark")<CR>

"" crosshair cursor
set cursorline
set cursorcolumn

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


" # Macros #

"" Quickly edit/reload the vimrc file
map <Leader>rv :source $MYVIMRC<cr>

"" substitute all occurrences of the word under the cursor
:nnoremap <Leader>w :%s/\<<C-r><C-w>\>//g<Left><Left>

"" quick find/replace
:nnoremap <Leader>k :%s//g<Left><Left>


"" Automatic fold settings for specific files. Uncomment to use.
"" autocmd FileType ruby setlocal foldmethod=syntax
"" autocmd FileType css  setlocal foldmethod=indent shiftwidth=2 tabstop=2

"" commit messages | http://robots.thoughtbot.com/post/48933156625/5-useful-tips-for-a-better-commit-message
autocmd Filetype gitcommit setlocal spell textwidth=72


"" open new panes to right/bottom
set splitbelow
set splitright

"" natural cursor movement between lines
nnoremap j gj
nnoremap k gk

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

"" su-DOH
cmap w!! w !sudo tee % >/dev/null


"" kick vim into recognising moderm terminal color handling
"" if $TERM == "xterm-256color"" || $TERM == "screen-256color"" || $COLORTERM == "gnome-terminal"
""   set t_Co=256
"" endif

"" toggle invisibles
nnoremap <Leader>l :set list!<CR>
set listchars=tab:▸\ ,eol:⌐


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

"" use powerline patched fonts for airline
let g:airline_powerline_fonts = 0

"" inherit line column color for vim-gitgutter
highlight clear SignColumn

"" CTRLP plugin, set some mappings and defaults, courtesy
" http://statico.github.io/vim.html
" https://robots.thoughtbot.com/faster-grepping-in-vim
:let g:ctrlp_cmd = 'CtrlP'
:let g:ctrlp_map = '<c-t>'
":let g:ctrlp_working_path_mode = 'ra' "set dir to first vcs parent
:let g:ctrlp_working_path_mode = 0 "set dir to dir that vim started with
:let g:ctrlp_match_window_bottom = 0
:let g:ctrlp_match_window_reversed = 0
:let g:ctrlp_dotfiles = 1
:let g:ctrlp_show_hidden = 1

" rigrep or The Silver Searcher

" rigrep and ag are fast enough that CtrlP doesn't need to cache
if executable("rg") || executable("ag")
    let g:ctrlp_use_caching = 0
endif

if executable("rg")
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  :let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden --skip-vcs-ignores
    \ --ignore .git
    \ --ignore .svn
    \ --ignore .DS_Store
    \ --ignore .npm
    \ --ignore .vagrant
    \ --ignore "*.zip"
    \ --ignore "*.tgz"
    \ --ignore "*.pdf"
    \ --ignore "*.mp3"
    \ --ignore "*.mp4"
    \ --ignore "*.jpg"
    \ --ignore "*.png"
    \ --ignore "*.gif"
    \ --ignore "*.epub"
    \ --ignore .hg
    \ --ignore .dropbox
    \ --ignore .config
    \ --ignore .cache
    \ --ignore "**/*.pyc"
    \ -g ""'
endif


" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>


"" mapping for NERDtree and autoclose
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

"" show hidden files in nerdtree
let NERDTreeShowHidden=1
"" auto delete buffer of deleted files
let NERDTreeAutoDeleteBuffer = 1
"" look nice
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1


"" Mapping and settings for emmet
let g:user_emmet_expandabbr_key = '<Leader><Leader>'
let g:user_emmet_next_key = '<Leader>n'
let g:user_emmet_prev_key = '<Leader>N'

"" let g:user_emmet_settings = {
""   'php' : {
""     'extends' : 'html',
""     'filters' : 'c',
""   },
""   'xml' : {
""     'extends' : 'html',
""   },
""   'haml' : {
""     'extends' : 'html',
""   },
"" }

"" closetag.vim
":au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim

"" Marked build
:nnoremap <leader>m :silent !open -a Marked\ 2.app '%:p'<cr>

"" NERDTree
:nnoremap <Leader>f :NERDTreeToggle<CR>

"" open nerdtree on start
"" autocmd VimEnter * NERDTree | wincmd p

" NERDCommenter
let g:NERDSpaceDelims = 1
let g:NERDCommentEmptyLines = 1
"let g:NERDCompactSexyComs = 1


"" fix youcompleteme freezing vim after pressing dot
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_completion = 0

"" Vim Better Whitespace
:nnoremap <Leader>tw :ToggleWhitespace<CR>
:nnoremap <Leader>sw :StripWhitespace<CR>

"" Switch.vim
let g:switch_mapping = "-"

"" vim mustache handlebars
let g:mustache_abbreviations = 1

"" Clam
nnoremap ! :Clam<space>
vnoremap ! :ClamVisual<space>

"" Dash
:nmap <silent> <leader>d <Plug>DashSearch

" multiple cursors custom mapping to avoid conflicts with builtins
" let g:multi_cursor_use_default_mapping=0
" let g:multi_cursor_next_key='<C-n>'
" let g:multi_cursor_prev_key='<C-p>'
" let g:multi_cursor_skip_key='<C-x>'
" let g:multi_cursor_quit_key='<Esc>'

" comfortable-motion.vim
noremap <silent> <ScrollWheelDown> :call comfortable_motion#flick(40)<CR>
noremap <silent> <ScrollWheelUp>   :call comfortable_motion#flick(-40)<CR>

let g:comfortable_motion_no_default_key_mappings = 1
let g:comfortable_motion_impulse_multiplier = 1  " Feel free to increase/decrease this value.
nnoremap <silent> <C-d> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 2)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -2)<CR>
nnoremap <silent> <C-f> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * 4)<CR>
nnoremap <silent> <C-b> :call comfortable_motion#flick(g:comfortable_motion_impulse_multiplier * winheight(0) * -4)<CR>
