filetype plugin on
runtime macros/matchit.vim

" https://github.com/junegunn/vim-plug#on-demand-loading-of-plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'junegunn/vim-plug'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
" Plug 'terryma/vim-multiple-cursors' " https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
" Plug 'christoomey/vim-quicklink' " https://github.com/christoomey/vim-quicklink/issues/16
"   _______ _____ __  __     _____   ____  _____  ______             _____  ______
"  |__   __|_   _|  \/  |   |  __ \ / __ \|  __ \|  ____|      /\   |  __ \|  ____|   /\
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
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
" ______ _   _ _____       _____   ____  _____  ______            _____  ______
" |  ____| \ | |  __ \     |  __ \ / __ \|  __ \|  ____|     /\   |  __ \|  ____|   /\
" | |__  |  \| | |  | |    | |__) | |  | | |__) | |__       /  \  | |__) | |__     /  \
" |  __| | . ` | |  | |    |  ___/| |  | |  ___/|  __|     / /\ \ |  _  /|  __|   / /\ \
" | |____| |\  | |__| |    | |    | |__| | |    | |____   / ____ \| | \ \| |____ / ____ \
" |______|_| \_|_____/     |_|     \____/|_|    |______| /_/    \_\_|  \_\______/_/    \_\
Plug 'AndrewRadev/switch.vim'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'RRethy/vim-illuminate'
Plug 'Shougo/deoplete-clangx'
Plug 'Shougo/neco-syntax'
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/neosnippet.vim'
Plug 'Yggdroot/indentLine'
Plug 'ap/vim-css-color', { 'for': ['css', 'sass', 'scss'] }
Plug 'carlitux/deoplete-ternjs', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'chriskempson/base16-vim'
Plug 'christoomey/vim-sort-motion'
Plug 'christoomey/vim-titlecase'
Plug 'christoomey/vim-tmux-navigator'
Plug 'dag/vim-fish', { 'for': 'fish' }
Plug 'flniu/CmdlineComplete'
Plug 'fszymanski/deoplete-emoji'
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }
Plug 'heavenshell/vim-jsdoc', { 'for': 'javascript' }
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vimwiki'] }
Plug 'inside/vim-search-pulse'
Plug 'jasonlong/vim-textobj-css'
Plug 'jceb/vim-textobj-uri'
Plug 'jiangmiao/auto-pairs'
Plug 'jreybert/vimagit'
Plug 'junegunn/fzf', { 'dir': '~/.fzf' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/vim-peekaboo'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-line'
Plug 'kana/vim-textobj-user'
Plug 'lambdalisue/vim-gista', { 'on': 'Gista' }
Plug 'luochen1990/rainbow'
Plug 'lvht/phpcd.vim', { 'for': 'php' }
Plug 'machakann/vim-highlightedyank'
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
Plug 'mattn/emmet-vim', { 'for': ['css', 'sass', 'scss', 'less', 'html', 'html.twig', 'html.handlebars', 'eruby', 'javascript.jsx', 'php'] }
Plug 'mattn/webapi-vim'
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
Plug 'mhartington/nvim-typescript', {  'for':  'typescript', 'do': './install.sh' }
Plug 'mhinz/vim-signify'
Plug 'mhinz/vim-startify'
Plug 'ntpeters/vim-better-whitespace'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'sheerun/vim-polyglot'
Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'tobyS/pdv', { 'for': 'php' }
Plug 'tobyS/vmustache', { 'for': 'php' }
Plug 'tomtom/tlib_vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-php/tagbar-phpctags.vim', { 'for': 'php' }
Plug 'vim-vdebug/vdebug', { 'for': 'php' }
Plug 'vimwiki/vimwiki', { 'for': ['markdown', 'vimwiki'], 'branch': 'dev' }
Plug 'w0rp/ale', { 'for': ['bash', 'c', 'cpp', 'css', 'eruby', 'fish', 'html', 'html.handlebars', 'html.twig', 'javascript', 'javascript.jsx', 'json', 'less', 'php', 'python', 'ruby',  'sass', 'scss', 'sh', 'vim', 'xml', 'yaml',] }
Plug 'whatyouhide/vim-textobj-xmlattr'
Plug 'wincent/ferret', { 'on': ['Ack', 'Acks', 'Lack', 'Lacks', 'Lack!', 'Black', 'Blacks', 'Black!'] }
Plug 'z0mbix/vim-shfmt', { 'for': 'sh' }
Plug 'zchee/deoplete-jedi', { 'for': 'python' }
Plug 'zirrostig/vim-schlepp'
" add plugins here ^

call plug#end()
