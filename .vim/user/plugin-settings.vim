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
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) =~# 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
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

nnoremap <Leader>tw :ToggleWhitespace<CR>
nnoremap <Leader>dw :StripWhitespace<CR>

"
" Switch.vim
"

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
  \   ['enabled', 'disabled'],
  \ ]

"
" vim mustache handlebars
"

let g:mustache_abbreviations = 1

"
" tabularize
"

nnoremap <Leader>aa :Tabularize <CR>
vnoremap <Leader>aa :Tabularize <CR>
nnoremap <Leader>a= :Tabularize /=<CR>
vnoremap <Leader>a= :Tabularize /=<CR>
nnoremap <Leader>a: :Tabularize /:\zs<CR>
vnoremap <Leader>a: :Tabularize /:\zs<CR>
nnoremap <Leader>a- :Tabularize /-<CR>
vnoremap <Leader>a- :Tabularize /-<CR>
nnoremap <Leader>a, :Tabularize /,<CR>
vnoremap <Leader>a, :Tabularize /,<CR>
nnoremap <Leader>a< :Tabularize /\<<CR>
vnoremap <Leader>a< :Tabularize /\<<CR>
nnoremap <Leader>a\| :Tabularize /\|<CR>
vnoremap <Leader>a\| :Tabularize /\|<CR>
nnoremap <Leader>as :Tabularize /<Space><CR>
vnoremap <Leader>as :Tabularize /<Space><CR>

"
" undotree - undo tree visualizer
"

nnoremap <C-z> :UndotreeToggle<CR>
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

nnoremap <Leader>gl :Gista list<CR>
nnoremap <Leader>gb :Gista browse
nnoremap <Leader>gpr :Gista post --private<CR>
nnoremap <Leader>gpu :Gista post --public<CR>
nnoremap <Leader>ga :Gista post --anonymous<CR>
nnoremap <Leader>gd :Gista --delete<CR>
nnoremap <Leader>gs :Gista star<CR>
nnoremap <Leader>gu :Gista unstar<CR>


"
" airline
"

set laststatus=2
let g:airline_theme='solarized'
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
" tmuxline
"

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

"
" closetag
"

let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.twig,*.php'
let g:closetag_emptyTags_caseSensitive = 1
let closetag_close_shortcut = '<leader>>'

"
" highlighted yank
"

let g:highlightedyank_highlight_duration = 700
hi HighlightedyankRegion cterm=reverse gui=reverse

"
" ranger.vim
"

map <leader>rr :RangerEdit<cr>
" map <leader>rv :RangerVSplit<cr>
" map <leader>rs :RangerSplit<cr>
" map <leader>rt :RangerTab<cr>
" map <leader>ri :RangerInsert<cr>
" map <leader>ra :RangerAppend<cr>
" map <leader>rc :set operatorfunc=RangerChangeOperator<cr>g@
let g:ranger_replace_netrw = 0

"
" titlecase
"

" let g:titlecase_map_keys = 0
" nmap <leader>gt <Plug>Titlecase
" vmap <leader>gt <Plug>Titlecase
" nmap <leader>gT <Plug>TitlecaseLine

"
" livedown (markdown)
"

nmap <Leader>m :LivedownToggle<CR>

"
" easy motion
"

map <C-m> <Plug>(easymotion-prefix)

"
" Ale linter
"

" let g:ale_sign_error = '🚫 '
" let g:ale_sign_warning = '⚠️ '
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_delay = 1000
let g:ale_sign_column_always = 1
nmap <leader>= <Plug>(ale_fix)
nmap <leader>lt <Plug>(ale_toggle)
" Mappings in the style of unimpaired-next
nmap <silent> [W <Plug>(ale_first)
nmap <silent> [w <Plug>(ale_previous_wrap)
nmap <silent> ]w <Plug>(ale_next_wrap)
nmap <silent> ]W <Plug>(ale_last)


"
" deoplete.
"

let g:deoplete#enable_at_startup = 1
" Disable the candidates in Comment/String syntaxes.
" call deoplete#custom#source('_',
"   \ 'disabled_syntaxes', ['Comment', 'String'])
let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
let g:deoplete#ignore_sources.php = ['omni']

"
" neosnippet
"

" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)

"
" SuperTab like snippets behavior.
"

" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <expr><TAB>
  \ pumvisible() ? "\<C-n>" :
  \ neosnippet#expandable_or_jumpable() ?
  \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

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
let g:sh_wiki.path = '~/Drive/notes/'

let g:clorox_wiki = copy(g:wiki_default)
let g:clorox_wiki.path = '~/Drive/clorox/notes/'

let g:vimwiki_list = [g:sh_wiki, g:clorox_wiki]


"
" tagbar
"

nnoremap <Leader>tb :TagbarToggle<CR>

"
" taskwiki
"

let g:taskwiki_syntax = 'markdown'

" TODO: not working
nnoremap <Leader>td :TaskWikiDone

"
" vim schlepp (dragvisuals.vim)
"

" TODO: not working
vnoremap <up> <Plug>SchleppUp
vnoremap <down> <Plug>SchleppDown
vnoremap <left> <Plug>SchleppLeft
vnoremap <right> <Plug>SchleppRight

"
" gutentags (ctags)
"

let g:gutentags_project_root = ['.svn'] " supplemental
let g:gutentags_cache_dir = '~/.tags'

"
" loupe
"
nmap <leader>nh <Plug>(LoupeClearHighlight)

"
" fzf
"

let g:fzf_layout = { 'down': '~40%' }

" https://github.com/junegunn/fzf.vim#commands
nnoremap <C-p> :Files<CR>
" gp unmapped by default
nnoremap gb :Buffers<CR>
" gh (who TF uses select mode anyway)
nnoremap gh :Helptags<CR>
" g; (don't need to go to a change from memory
nnoremap g; :History:<CR>
" gr unmapped by default
nnoremap gr :Tags<CR>
" gm unmapped by default
nnoremap gm :Marks<CR>
" g/ unmapped by default
nnoremap g/ :History/<CR>

"
" peekaboo
"

let g:peekaboo_delay = 1000

"
" shfmt - shell formatter
"

let g:shfmt_extra_args = '-i 4'
