let g:loaded_operator_copy = 1

inoremap <silent> <Plug>(operator-copy-ctrl-y)
      \ <Esc>:call op_copy#start('k')<CR>

inoremap <silent> <Plug>(operator-copy-ctrl-e)
      \ <Esc>:call op_copy#start('j')<CR>

imap <C-y> <Plug>(operator-copy-ctrl-y)
imap <C-e> <Plug>(operator-copy-ctrl-e)

