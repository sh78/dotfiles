"
" Plugins
"

" Netrw adjustments
let g:netrw_banner=0        " disable annoying banner
let g:netrw_browse_split=4  " open in prior window
let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view
let g:netrw_winsize = 25    " set width like a standard file drawer
let g:netrw_list_hide=netrw_gitignore#Hide()
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

" vim markdown
let g:vim_markdown_fenced_languages = ['c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini', 'bash=shell', 'javascript=js', 'php=php', 'html=html', 'css=css']
let g:vim_markdown_new_list_item_indent = 0

" vim-gitgutter
" inherit line column color
highlight clear SignColumn
" prevent conflict w/ vim-textobj-css
omap ih <Plug>GitGutterTextObjectInnerPending
omap ah <Plug>GitGutterTextObjectOuterPending
xmap ih <Plug>GitGutterTextObjectInnerVisual
xmap ah <Plug>GitGutterTextObjectOuterVisual

" Ack
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Goyo
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

" Mapping and settings for emmet
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

" closetag.vim
":au Filetype html,xml,xsl source ~/.vim/scripts/closetag.vim


" fix youcompleteme freezing vim after pressing dot
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_completion = 0

" Vim Better Whitespace
nnoremap <Leader>tw :ToggleWhitespace<CR>
nnoremap <Leader>dw :StripWhitespace<CR>

" Switch.vim
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

" vim mustache handlebars
let g:mustache_abbreviations = 1

" tabularize
nnoremap <Leader>aa :Tabularize <CR>
nnoremap <Leader>a= :Tabularize /=<CR>
nnoremap <Leader>a: :Tabularize /:\zs<CR>
nnoremap <Leader>a- :Tabularize /-<CR>
nnoremap <Leader>a, :Tabularize /,<CR>
nnoremap <Leader>a< :Tabularize /\<<CR>
nnoremap <Leader>a\| :Tabularize /\|<CR>
nnoremap <Leader>as :Tabularize /<Space><CR>

" undotree - undo tree visualizer
nnoremap <C-z> :UndotreeToggle<CR>
let g:undotree_WindowLayout = 4
let g:undotree_ShortIndicators = 1
let g:undotree_DiffpanelHeight = 12
let g:undotree_HelpLine = 0

" denite
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
nnoremap gp :Denite buffer file/rec<CR>
nnoremap ;; :Denite command<CR> " search commands
nnoremap gr :DeniteBufferDir grep:. -mode=normal<CR> " gr unmapped by default
nnoremap gk :DeniteCursorWord line<CR> " gk (already remapped k to do gk)
nnoremap gK :DeniteCursorWord grep:. -mode=normal<CR> " gK (unmapped by default)
nnoremap gn :DeniteCursorWord tags -mode=normal<CR> " (don't need to visually select search patterns
nnoremap gh :Denite help<CR> " gh (who TF uses select mode anyway)
nnoremap gH :DeniteCursorWord help<CR> " gH (who TF uses select line mode anyway)
nnoremap g; :Denite change -mode=normal<CR> " g; (don't need to go to a change from memory, and using :Denite change is nicer)
nnoremap g" :Denite register<CR> " g" is unmapped by default


" maybe eunuch :Find?" gF (unmapped by default)
" gP (don't need cursor moving after paste)

" Gista (snippets)
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


" airline
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

" highlighted yank
let g:highlightedyank_highlight_duration = 700

" ranger.vim
map <leader>rr :RangerEdit<cr>
" map <leader>rv :RangerVSplit<cr>
" map <leader>rs :RangerSplit<cr>
" map <leader>rt :RangerTab<cr>
" map <leader>ri :RangerInsert<cr>
" map <leader>ra :RangerAppend<cr>
" map <leader>rc :set operatorfunc=RangerChangeOperator<cr>g@
let g:ranger_replace_netrw = 0

" titlecase
" let g:titlecase_map_keys = 0
" nmap <leader>gt <Plug>Titlecase
" vmap <leader>gt <Plug>Titlecase
" nmap <leader>gT <Plug>TitlecaseLine

" livedown (markdown)
nmap gm :LivedownToggle<CR>

" easy motion
map <C-m> <Plug>(easymotion-prefix)

" Ale linter
let g:ale_sign_error = '🚫 '
let g:ale_sign_warning = '⚠️ '
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_delay = 800"
nmap <silent> <C-h> <Plug>(ale_previous_wrap)
nmap <silent> <C-l> <Plug>(ale_next_wrap)

" Use deoplete.
let g:deoplete#enable_at_startup = 1
" Disable the candidates in Comment/String syntaxes.
" call deoplete#custom#source('_',
"   \ 'disabled_syntaxes', ['Comment', 'String'])
let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
let g:deoplete#ignore_sources.php = ['omni']

" neosnippet
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

" JSDoc
nmap <silent> <Leader>jd <Plug>(jsdoc)

" vimwiki
let g:vimwiki_list = [{
  \ 'path': '~/Drive/notes/',
  \ 'syntax': 'markdown', 'ext': '.md'
\ }]

" tagbar
nnoremap <Leader>tb :TagbarToggle<CR>

" taskwiki
" TODO: not working
nnoremap <Leader>td :TaskWikiDone