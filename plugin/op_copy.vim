let g:loaded_operator_copy = 1

" Note:
" Use <C-c>, and the functions should be adapted to the affairs that <C-c>
" causes because of the reasons below:
" - <Esc> invokes `InsertLeave`.
" - <Cmd> and <Plug> cannot put in the same mapping. (E5522)
" - <Plug>-mappings defined in `:omap` does not seem to work in `:imap`; thus,
"   ```
"   imap <C-y> <Plug>(operator-copy-ctrl-y)<Plug>(some-motions)
"   ```
"   does not work, only to insert literal _<Plug>(some-motions)_.
inoremap <silent> <Plug>(operator-copy-ctrl-y)
      \ <C-c>:call op_copy#start('kl')<CR>

inoremap <silent> <Plug>(operator-copy-ctrl-e)
      \ <C-c>:call op_copy#start('jl')<CR>

if !get(g:, 'operator_copy#no_default_mappings', 0)
  imap <C-y> <Plug>(operator-copy-ctrl-y)
  imap <C-e> <Plug>(operator-copy-ctrl-e)
endif

