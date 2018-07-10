" Dein Plugin Management
" https://github.com/Shougo/dein.vim
"

if &compatible
  set nocompatible
endif

" Add the dein installation directory into runtimepath
set runtimepath+=~/.vim/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.vim/dein')
  call dein#begin('~/.vim/dein')

  call dein#add('~/.vim/dein')
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif
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
  call dein#add('tpope/vim-abolish')
  call dein#add('tpope/vim-eunuch')
  call dein#add('tpope/vim-fugitive')
  call dein#add('tpope/vim-surround')
  call dein#add('tpope/vim-commentary')
  call dein#add('tpope/vim-speeddating')
  call dein#add('tpope/vim-repeat')
  call dein#add('tpope/vim-vinegar')
  " ______ _   _ _____       _____   ____  _____  ______            _____  ______
  " |  ____| \ | |  __ \     |  __ \ / __ \|  __ \|  ____|     /\   |  __ \|  ____|   /\
  " | |__  |  \| | |  | |    | |__) | |  | | |__) | |__       /  \  | |__) | |__     /  \
  " |  __| | . ` | |  | |    |  ___/| |  | |  ___/|  __|     / /\ \ |  _  /|  __|   / /\ \
  " | |____| |\  | |__| |    | |    | |__| | |    | |____   / ____ \| | \ \| |____ / ____ \
  " |______|_| \_|_____/     |_|     \____/|_|    |______| /_/    \_\_|  \_\______/_/    \_\
  "call dein#add('terryma/vim-multiple-cursors') " https://medium.com/@schtoeffel/you-don-t-need-more-than-one-cursor-in-vim-2c44117d51db
  call dein#add('AndrewRadev/switch.vim')
  " call dein#add('christoomey/vim-quicklink')
  call dein#add('christoomey/vim-sort-motion')
  call dein#add('MarcWeber/vim-addon-mw-utils')
  call dein#add('Shougo/denite.nvim')
  call dein#add('Shougo/deoplete-clangx')
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/neco-syntax')
  call dein#add('Shougo/neosnippet-snippets')
  call dein#add('Shougo/neosnippet.vim')
  call dein#add('airblade/vim-gitgutter')
  call dein#add('altercation/vim-colors-solarized')
  call dein#add('ap/vim-css-color')
  call dein#add('carlitux/deoplete-ternjs')
  call dein#add('christoomey/vim-titlecase')
  call dein#add('christoomey/vim-tmux-navigator')
  call dein#add('dag/vim-fish')
  call dein#add('edkolev/tmuxline.vim')
  call dein#add('fszymanski/deoplete-emoji')
  call dein#add('godlygeek/tabular')
  call dein#add('heavenshell/vim-jsdoc')
  call dein#add('jasonlong/vim-textobj-css')
  call dein#add('jceb/vim-textobj-uri')
  call dein#add('jremmen/vim-ripgrep')
  call dein#add('junegunn/goyo.vim')
  call dein#add('kana/vim-textobj-entire')
  call dein#add('kana/vim-textobj-line')
  call dein#add('kana/vim-textobj-user')
  call dein#add('lambdalisue/vim-gista')
  call dein#add('lvht/phpcd.vim')
  call dein#add('machakann/vim-highlightedyank')
  " call dein#add('majutsushi/tagbar')
  call dein#add('mattn/emmet-vim')
  call dein#add('mattn/webapi-vim')
  call dein#add('mbbill/undotree')
  call dein#add('mileszs/ack.vim')
  call dein#add('ntpeters/vim-better-whitespace')
  call dein#add('powerman/vim-plugin-AnsiEsc')
  call dein#add('rbgrouleff/bclose.vim')
  call dein#add('rking/ag.vim')
  call dein#add('sheerun/vim-polyglot')
  call dein#add('shime/vim-livedown')
  call dein#add('tbabej/taskwiki')
  call dein#add('ternjs/tern_for_vim')
  call dein#add('tomtom/tlib_vim')
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('vim-scripts/SearchComplete')
  call dein#add('vimwiki/vimwiki.git')
  call dein#add('w0rp/ale')
  call dein#add('whatyouhide/vim-textobj-xmlattr')
  call dein#add('zchee/deoplete-jedi')
  " add plugins here ^

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

" TODO: auto detect/install useful?
" let iCanHazVundle=1
" let vundle_readme=expand('~/.vim/bundle/Vundle.vim/README.md')
" if !filereadable(vundle_readme)
"   echo "Installing Vundle.."
"   echo ""
"   silent !mkdir -p ~/.vim/bundle
"   silent !git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
"   let iCanHazVundle=0
" endif
" set rtp+=~/.vim/bundle/Vundle.vim/
" call vundle#rc()


"" if iCanHazVundle == 0
""   echo "Installing Bundles, please ignore key map error messages"
""   echo ""
""   :PluginInstall
"" endif

"" Brief help
"" :PluginList       - lists configured plugins
"" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
"" :PluginSearch foo - searches for foo; append `!` to refresh local cache
"" :PluginClean      - confirms removal of unused plugins; append `!` to auto - approve removal
""
"" see :h vundle for more details or wiki for FAQ
"" Put your non-Plugin stuff after this line

""" Vundler end

"" filetype plugin indent on      "" Turn file type detection back on
