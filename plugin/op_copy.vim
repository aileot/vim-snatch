let g:loaded_operator_copy = 1

let g:operator_copy#clean_registers =
      \ get(g:, 'operator_copy#clean_registers', '0')

" Note: Use <Cmd> for the first hand mappings.
" - <Esc> invokes `InsertLeave`.
" - <C-c> cannot distinguish which col cursor was inserted at 1 or 2 from the
"   beginning of a line.
" Note: <Cmd> and <Plug> cannot put in the same mapping. The mapping,
"   ```
"   inoremap <C-y> <Cmd>call s:foo("\<Plug>(bar)")<CR>
"   ```
"   throws the error E5522.
inoremap <silent> <Plug>(operator-copy-ctrl-y)
      \ <Cmd>call op_copy#start('kl')<CR>

inoremap <silent> <Plug>(operator-copy-ctrl-e)
      \ <Cmd>call op_copy#start('jl')<CR>

if !get(g:, 'operator_copy#no_default_mappings', 0)
  imap <C-y> <Plug>(operator-copy-ctrl-y)
  imap <C-e> <Plug>(operator-copy-ctrl-e)
endif

