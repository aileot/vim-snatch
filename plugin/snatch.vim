let g:loaded_snatch = 1

let g:snatch#clean_registers =
      \ get(g:, 'snatch#clean_registers', '0')

" Note: Use <Cmd> for the first hand mappings.
" - <Esc> invokes `InsertLeave`.
" - <C-c> cannot distinguish which col cursor was inserted at 1 or 2 from the
"   beginning of a line.
" Note: <Cmd> and <Plug> cannot put in the same mapping. The mapping,
"   ```
"   inoremap <C-y> <Cmd>call s:foo("\<Plug>(bar)")<CR>
"   ```
"   throws the error E5522.
inoremap <silent> <Plug>(snatch-ctrl-y)
      \ <Cmd>call snatch#start('kl')<CR>

inoremap <silent> <Plug>(snatch-ctrl-e)
      \ <Cmd>call snatch#start('jl')<CR>

inoremap <silent> <Plug>(snatch-here)
      \ <Cmd>call snatch#start()<CR>

if !get(g:, 'snatch#no_default_mappings', 0)
  imap <C-y> <Plug>(snatch-ctrl-y)
  imap <C-e> <Plug>(snatch-ctrl-e)
endif

