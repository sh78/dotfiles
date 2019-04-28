"
" Netrw
"

let g:netrw_banner=0        " disable annoying banner
let g:netrw_browse_split=4  " open in prior window
let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view
let g:netrw_winsize = 25    " set width like a standard file drawer
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

"
" vim markdown
"

let g:vim_markdown_fenced_languages = ['c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini', 'bash=shell', 'javascript=js', 'php=php', 'html=html', 'css=css']
let g:vim_markdown_new_list_item_indent = 0

"
" signify - VCS markers in side column
"

let g:signify_vcs_list = [ 'git', 'svn' ]

"
" Goyo
"

let g:goyo_width = 80
let g:goyo_margin_top = 3
let g:goyo_margin_bottom = 3

function! s:goyo_enter()
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
  Limelight
  " set nocursorline
  " set nocursorcolumn
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) =~# 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
  Limelight!
  " set cursorline
  " set cursorcolumn
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

"
" Emmet
"

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

"
" Vim Better Whitespace
"


"
" Switch.vim
"

let g:switch_mapping = '-'
let g:switch_custom_definitions =
  \ [
  \   switch#NormalizedCase(['+', '-']),
  \   switch#NormalizedCase(['<', '>']),
  \   switch#NormalizedCase(['<=', '>=']),
  \   switch#NormalizedCase(['1', '0']),
  \   switch#NormalizedCase(['add', 'remove']),
  \   switch#NormalizedCase(['asc', 'desc']),
  \   switch#NormalizedCase(['ascending', 'descending']),
  \   switch#NormalizedCase(['around', 'between']),
  \   switch#NormalizedCase(['above', 'below']),
  \   switch#NormalizedCase(['before', 'after']),
  \   switch#NormalizedCase(['black', 'white']),
  \   switch#NormalizedCase(['class', 'id']),
  \   switch#NormalizedCase(['column', 'row']),
  \   switch#NormalizedCase(['dark', 'light']),
  \   switch#NormalizedCase(['enabled', 'disabled']),
  \   switch#NormalizedCase(['error', 'warning', 'success']),
  \   switch#NormalizedCase(['expand', 'collapse']),
  \   switch#NormalizedCase(['first', 'last']),
  \   switch#NormalizedCase(['foo', 'bar', 'baz']),
  \   switch#NormalizedCase(['forward', 'backward']),
  \   switch#NormalizedCase(['flex', 'block']),
  \   switch#NormalizedCase(['hey', 'hi', 'hello']),
  \   switch#NormalizedCase(['http', 'https']),
  \   switch#NormalizedCase(['is', "isn't"]),
  \   switch#NormalizedCase(['jpg', 'png', 'gif']),
  \   switch#NormalizedCase(['login', 'register']),
  \   switch#NormalizedCase(['margin', 'padding']),
  \   switch#NormalizedCase(['min', 'max']),
  \   switch#NormalizedCase(['minimum', 'maximum']),
  \   switch#NormalizedCase(['mobile', 'desktop']),
  \   switch#NormalizedCase(['off', 'on']),
  \   switch#NormalizedCase(['old', 'new']),
  \   switch#NormalizedCase(['opaque', 'transparent']),
  \   switch#NormalizedCase(['open', 'close']),
  \   switch#NormalizedCase(['out', 'in']),
  \   switch#NormalizedCase(['page', 'post']),
  \   switch#NormalizedCase(['previous', 'next']),
  \   switch#NormalizedCase(['right', 'left']),
  \   switch#NormalizedCase(['show', 'hide']),
  \   switch#NormalizedCase(['sm', 'md', 'lg', 'xl', 'xxl']),
  \   switch#NormalizedCase(['staging', 'production']),
  \   switch#NormalizedCase(['top', 'bottom']),
  \   switch#NormalizedCase(['this', 'that']),
  \   switch#NormalizedCase(['up', 'down']),
  \   switch#NormalizedCase(['vertical', 'horizontal']),
  \   switch#NormalizedCase(['width', 'height']),
  \   switch#NormalizedCase(['x', 'y']),
  \   switch#NormalizedCase(['yes', 'no']),
  \ ]

"
" vim mustache handlebars
"

let g:mustache_abbreviations = 1

"
" tabularize
"

"
" undotree - undo tree visualizer
"

let g:undotree_WindowLayout = 4
let g:undotree_ShortIndicators = 1
let g:undotree_DiffpanelHeight = 12
let g:undotree_HelpLine = 0

"
" Gista (snippets)
"

let g:gista#command#post#default_public = 0
let g:gista#command#post#allow_empty_description = 1
" Always request updated gists in :Gista list
let g:gista#command#list#default_options = {
  \ 'cache': 0,
\}



"
" airline
"

set laststatus=2
let g:airline_powerline_fonts = 1

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
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


"
" highlighted yank
"

let g:highlightedyank_highlight_duration = 700
hi HighlightedyankRegion cterm=reverse gui=reverse


"
" Ale linter
"

" let g:ale_sign_error = '🚫 '
" let g:ale_sign_warning = '⚠️ '
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_delay = 1000
let g:ale_sign_column_always = 1
let g:ale_set_balloons = 1

" Do not lint or fix minified files.
let g:ale_pattern_options = {
\ '\.min\.js$': {'ale_linters': [], 'ale_fixers': []},
\ '\.min\.css$': {'ale_linters': [], 'ale_fixers': []},
\}

" If you configure g:ale_pattern_options outside of vimrc, you need this.
let g:ale_pattern_options_enabled = 1


"
" deoplete.
"

let g:deoplete#enable_at_startup = 1
" Disable the candidates in Comment/String syntaxes.
" call deoplete#custom#source('_',
"   \ 'disabled_syntaxes', ['Comment', 'String'])
let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
" let g:deoplete#ignore_sources.php = ['omni']

"
" neosnippet
"

let g:neosnippet#snippets_directory='~/.vim/neosnippet-snippets/neosnippets'

"
" SuperTab like snippets behavior.
"

" " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
" imap <expr><TAB>
"   \ pumvisible() ? "\<C-n>" :
"   \ neosnippet#expandable_or_jumpable() ?
"   \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
" smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
"   \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

"
" JSDoc
"

nmap <silent> <Leader>jd <Plug>(jsdoc)

"
" vimwiki
"


" Wiki settings
let g:wiki_default = {}
let g:wiki_default.auto_export = 0
let g:wiki_default.auto_toc = 0
let g:wiki_default.syntax = 'markdown'
let g:wiki_default.ext = '.md'
let g:wiki_default.diary_rel_path = 'log/'

let g:sh_wiki = copy(g:wiki_default)
let g:sh_wiki.path = '~/notes/'

let g:clorox_wiki = copy(g:wiki_default)
let g:clorox_wiki.path = '~/electro/notes/'

let g:vimwiki_list = [g:sh_wiki, g:clorox_wiki]


"
" tagbar (related)
"
" See https://github.com/majutsushi/tagbar/wiki for additional filetype support

let g:tagbar_compact = 1
let g:tagbar_width = 32

let g:airline#extensions#tagbar#enabled = 1

let g:tagbar_phpctags_bin='~/.bin/phpctags'
let g:tagbar_phpctags_memory_limit = '512M'


let g:tagbar_type_markdown = {
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin' : '~/.bin/markdown2ctags.py',
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

let g:tagbar_type_vimwiki = {
    \ 'ctagstype': 'vimwiki',
    \ 'ctagsbin' : '~/.bin/markdown2ctags.py',
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

let g:tagbar_type_ruby = {
    \ 'kinds' : [
        \ 'm:modules',
        \ 'c:classes',
        \ 'd:describes',
        \ 'C:contexts',
        \ 'f:methods',
        \ 'F:singleton methods'
    \ ]
\ }

let g:tagbar_type_scss = {
\  'ctagstype' : 'scss',
\  'kinds' : [
\    'v:variables',
\    'c:classes',
\    'i:identities',
\    't:tags',
\    'm:medias'
\  ]
\}

let g:tagbar_type_less = {
\  'ctagstype' : 'less',
\  'kinds' : [
\    'v:variables',
\    'c:classes',
\    'i:identities',
\    't:tags',
\    'm:medias'
\  ]
\}

" Inherit bg color
highlight Tagbar guibg=NONE ctermbg=NONE

"
" taskwiki
"

" let g:taskwiki_disable_concealcursor = 'yes'
" let g:taskwiki_markup_syntax = 'markdown'

"
" vim schlepp (like dragvisuals.vim)
"

vmap <up> <Plug>SchleppUp
vmap <down> <Plug>SchleppDown
vmap <left> <Plug>SchleppLeft
vmap <right> <Plug>SchleppRight
vmap D <Plug>SchleppDup
vmap Dk <Plug>SchleppDupUp
vmap Dj <Plug>SchleppDupDown
vmap Dh <Plug>SchleppDupLeft
vmap Dl <Plug>SchleppDupRight

"
" Ferret (:Ack)
"
let g:FerretExecutableArguments = {
  \   'rg': '--vimgrep --no-heading --no-config --max-columns 4096 --glob=!{.git,.svn,*.map,*.min*,**/min/**,**js/build/**,**/node_modules/**,**/bower_components/**}'
  \ }

"
" loupe
"
nmap <leader>nh <Plug>(LoupeClearHighlight)

"
" fzf
"

let g:fzf_layout = { 'down': '~40%' }

" Show preview window for :Files
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)


" Custom :Rg command with ignores
" While :Files respects $FZF_DEFAULT_COMMAND, seems like :Rg does not
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case --glob "!{.git,.svn,*.map,*.min*,**/min/**,**/node_modules/**,**/bower_components/**}"'.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

"
" peekaboo
"

let g:peekaboo_delay = 800

"
" shfmt - shell formatter
"

let g:shfmt_extra_args = '-i 4'

"
" indentline
"

let g:indentLine_concealcursor = 'nc'
let g:indentLine_color_gui = '#333333'
let g:indentLine_char = '│'

"
" NERDTree
"

let g:NERDTreeShowHidden=1
let g:NERDTreeMouseMode=2
let g:NERDTreeMinimalUI=1
let g:NERDTreeWinSize=24

" Inherit bg color
highlight NERDTreeFile guibg=NONE ctermbg=NONE

"
" Rainbow Parenthesis
"
let g:rainbow_active = 1

"
" VDebug
"

" let g:vdebug_options.path_maps = {"/site": "/Users/sean/clorox/cloroxpro.com/site"}

"
" vim sneak
"

let g:sneak#label = 1

"
" search pulse
"

let g:vim_search_pulse_mode = 'pattern'
let g:vim_search_pulse_duration = 100

"
" vim illuminate
"

" hi illuminatedWord cterm=bold gui=bold

let g:Illuminate_ftblacklist = ['nerdtree']
let g:Illuminate_delay = 150

"
" PHP Documentor
"

let g:pdv_template_dir = $HOME ."/.vim/plugged/pdv/templates"
