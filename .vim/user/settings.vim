"
" General settings
"

let g:mapleader=' '

" Intuitive backspacing.
set backspace=indent,eol,start

"" Keep buffers open.
set hidden

set encoding=utf-8
set fileformat=unix

"" Display incomplete commands.
set showcmd
"" Display the mode youre in.
set showmode

"" Case-insensitive searching.
set ignorecase
"" But case-sensitive if expression contains a capital letter.
set smartcase

"" Show line numbers.
set nonumber!
"" Use numbers relative to cursor line.
set relativenumber
"" Show cursor position.
set ruler
"" Make some room.
set numberwidth=3

"" Highlight matches as you type.
set incsearch
"" Highlight matches.
set hlsearch

if has("nvim")
    " Live preview substitutions.
    set inccommand=nosplit
endif

" Historgram diffs
if has('nvim-0.3.2') || has("patch-8.1.0360")
    set diffopt=filler,internal,algorithm:histogram,indent-heuristic
endif

" Format options
set textwidth=80

" Soft wrapping
set wrap

" Show 2 lines of context around the cursor.
set scrolloff=2

" Set the terminal's title
set title
" No beeping.
set visualbell

set noswapfile
set directory=/.vim/tmp
set backupdir=/tmp

" Spelling
setlocal spell spelllang=en_us
set spellfile=$HOME/.vim/spell/en.utf-8.add
set thesaurus+=$HOME/.vim/thesaurus/mthesaur.txt

set complete+=kspell

" Indentation defaults
set autoindent
set smartindent
set shiftround
set expandtab
set tabstop=4
set shiftwidth=4

" Persistent undo
set undofile
set undodir=~/.vim/undodir

" Keep lots of command history
" Must come after `nocompatible`
set history=1024

" characters used to denote invisible characters
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮

" open new panes to right/bottom
set splitbelow
set splitright

" Useful status information at bottom of screen
" Replaced by vim-airline
" set statusline=[%n]\ %<%.99f\ %h%w%m%r%y\ %{exists('*CapsLockStatusline')?CapsLockStatusline():''}%=%-16(\ %l,%c-%v\ %)%P

"
" File Navigation
"

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=.,**

" Display all matching files when we tab complete
set wildmenu
"set wildmode=list:longest         "" Complete files like a shell.

" Don't offer to open certain files/directories
" respected by :Denite file/rec
set wildignore+=.git,.svn,.DS_Store,.npm,.vagrant,*.zip,*.tgz,*.pdf,*.psd,*.ai,*.mp3,*.mp4,*.bmp,*.ico,*.jpg,*.png,*.gif,*.epub,.hg,.dropbox,.config,.cache,*.pyc,*.min*
" set wildignore+=**/node_modules/**,**/bower_components/**,*.min*,**/min

" look more common places for ctags file than just ./tags,tags
set tags+=./.git/tags,./.tags

" include hyphens in the word text-object
set iskeyword+=-

" Just for funzies
set mouse=a

" Make a variety of things faster
set updatetime=100

" don't give |ins-completion-menu| messages.
set shortmess+=c
