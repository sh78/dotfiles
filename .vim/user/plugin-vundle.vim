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
Plugin 'vimwiki/vimwiki.git'
Plugin 'powerman/vim-plugin-AnsiEsc'
" Plugin 'majutsushi/tagbar'
Plugin 'tbabej/taskwiki'
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
