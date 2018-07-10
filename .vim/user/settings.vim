"
" General settings
"

let g:mapleader=' '

" make both space and backslash the <Leader> but keep visual indication that
" <Leader> was pressed
" :map <Space> <Leader>

"" Intuitive backspacing.
set backspace=indent,eol,start

" Controversial... switch colon and semicolon for easier commands
:nnoremap ; :
:nnoremap : ;
:vnoremap ; :
:vnoremap : ;

"" Keep buffers open.
set hidden

set encoding=utf-8

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
"" hybrid number mode
set relativenumber
"" Show cursor position.
set ruler
"" Make some room.
set numberwidth=4

"" Highlight matches as you type.
set incsearch
"" Highlight matches.
set hlsearch

" hide highlighting in insert mode
autocmd InsertEnter * :setlocal nohlsearch
autocmd InsertLeave * :setlocal hlsearch

" Soft wrapping
set wrap

" Show 3 lines of context around the cursor.
set scrolloff=2

" Set the terminal's title
set title
" No beeping.
set visualbell

"" Don't make a backup before overwriting a file.
set nobackup
"" And again.
set nowritebackup
set noswapfile
set directory=/.vim/tmp

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

" natural cursor movement between lines
:nnoremap j gj
:nnoremap k gk

" characters used to denote invisible characters
set listchars=tab:▸\ ,eol:⌐

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
set wildignore+=.git,.svn,.DS_Store,.npm,.vagrant,*.zip,*.tgz,*.pdf,*.psd,*.ai,*.mp3,*.mp4,*.bmp,*.ico,*.jpg,*.png,*.gif,*.epub,.hg,.dropbox,.config,.cache,*.pyc
set wildignore+=node_modules/*,bower_components/*,*.min.*

" look more common places for ctags file than just ./tags,tags
set tags+=./.git/tags,./.tags


"
" Auto Commands (Global)
"

" Disable automatic comment insertion
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" When editing a file, always jump to the last known cursor position.
" Don't do it for commit messages, when the position is invalid, or when
" inside an event handler (happens when dropping a file on gvim).
autocmd BufReadPost *
  \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif


