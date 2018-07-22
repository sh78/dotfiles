setlocal tabstop=2
setlocal shiftwidth=2

" Default to https://standardjs.com/
let b:ale_linters = ['standard']
let b:ale_fixers = ['standard']
let g:javascript_linter = 'standard'

function! ToggleALEJavaScript()
    if g:javascript_linter =~# 'standard'
        let b:ale_linters = ['eslint']
        let b:ale_fixers = ['eslint']
        let g:javascript_linter = 'eslint'
        echom 'ALE Linter set to eslint.'
    else
        let b:ale_linters = ['standard']
        let b:ale_fixers = ['standard']
        let g:javascript_linter = 'standard'
        echom 'ALE Linter set to standard.'
    endif
endfunction
command! ToggleALEJavaScript :call ToggleALEJavaScript()
nnoremap <Leader>ljs :ToggleALEJavaScript<CR>

