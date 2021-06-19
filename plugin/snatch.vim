let g:loaded_snatch = 1

hi def SnatchCursor ctermfg=white guifg=white ctermbg=magenta guibg=magenta cterm=bold gui=bold
hi def SnatchInsertPos cterm=bold,reverse gui=bold,reverse
hi def SnatchInsertChars ctermfg=black guifg=black ctermbg=lightgreen guibg=lightgreen

let g:snatch#clean_registers = get(g:, 'snatch#clean_registers', '0')
let g:snatch#timeoutlen = get(g:, 'snatch#timeoutlen', 60000)
let g:snatch#cancellation_policy =
      \ get(g:, 'snatch#cancellation_policy', 'cancel')
let g:snatch#flash_duration_for_insertchars =
      \ get(g:, 'snatch#flash_duration_for_insertchars', 450)
let g:snatch#force_restore_cursor_highlight =
      \ get(g:, 'snatch#force_restore_cursor_highlight', 1)
let g:snatch#cmd#position_marker =
      \ get(g:, 'snatch#cmd#position_marker', '┃')
let g:snatch#ins#attempt_to_escape_from_window =
      \ get(g:, 'snatch#ins#attempt_to_escape_from_window', "\<C-c>\<C-w>p")

cnoremap <silent> <Plug>(snatch-by-register) <C-\>e snatch#mode#cmd#start()<CR>

" Note: Use <Cmd> for the first hand mappings.
" - <Esc> invokes `InsertLeave`.
" - <C-c> cannot distinguish which col cursor was inserted at 1 or 2 from the
"   beginning of a line.
" Note: <Cmd> and <Plug> cannot put in the same mapping. The mapping,
"   ```
"   inoremap <C-y> <Cmd>call s:foo("\<Plug>(bar)")<CR>
"   ```
"   throws the error E5522.
inoremap <Plug>(snatch-completion-confirm) <C-y>
inoremap <Plug>(snatch-completion-cancel)  <C-e>

inoremap <expr> <Plug>(snatch-by-register)        snatch#mode#ins#start()
inoremap <expr> <Plug>(snatch-by-register-ctrl-y) snatch#mode#ins#start(col('.') == 1 ? 'k' : 'kl')
inoremap <expr> <Plug>(snatch-by-register-ctrl-e) snatch#mode#ins#start(col('.') == 1 ? 'j' : 'jl')

inoremap <expr> <Plug>(snatch-by-register-wincmd-p) snatch#mode#ins#start("\<C-w>p")

snoremap <SID>(erase-placeholder) <Space><BS>
smap <Plug>(snatch-by-register)        <SID>(erase-placeholder)<Plug>(snatch-by-register)
smap <Plug>(snatch-by-register-ctrl-y) <SID>(erase-placeholder)<Plug>(snatch-by-register-ctrl-y)
smap <Plug>(snatch-by-register-ctrl-e) <SID>(erase-placeholder)<Plug>(snatch-by-register-ctrl-e)
smap <Plug>(snatch-by-register-wincmd-p) <SID>(erase-placeholder)<Plug>(snatch-by-register-wincmd-p)

if !get(g:, 'snatch#no_default_mappings', 0)
  cmap <C-o> <Plug>(snatch-by-register)

  smap <C-y> <Plug>(snatch-by-register-ctrl-y)
  smap <C-e> <Plug>(snatch-by-register-ctrl-e)

  imap <C-g><C-o> <Plug>(snatch-by-register)
  imap <C-g><C-y> <Plug>(snatch-by-register-ctrl-y)
  imap <C-g><C-e> <Plug>(snatch-by-register-ctrl-e)
  imap <C-g><C-p> <Plug>(snatch-by-register-wincmd-p)

  imap <expr> <C-y> pumvisible() ? '<Plug>(snatch-completion-confirm)' : '<Plug>(snatch-by-register-ctrl-y)'
  imap <expr> <C-e> pumvisible() ? '<Plug>(snatch-completion-cancel)'  : '<Plug>(snatch-by-register-ctrl-e)'
endif
