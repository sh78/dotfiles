setlocal tabstop=4
setlocal shiftwidth=4

let b:ale_linters = ['language-server', 'shell', 'shellcheck', 'shfmt']
let b:ale_fixers = ['shfmt']
