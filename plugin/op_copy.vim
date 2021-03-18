let g:loaded_operator_copy = 1

inoremap <silent> <Plug>(operator-copy-ctrl-y)
      \ <Cmd>call op_copy#start('kl')<CR>

inoremap <silent> <Plug>(operator-copy-ctrl-e)
      \ <Cmd>call op_copy#start('jl')<CR>

if !get(g:, 'operator_copy#no_default_mappings', 0)
  imap <C-y> <Plug>(operator-copy-ctrl-y)
  imap <C-e> <Plug>(operator-copy-ctrl-e)
endif

