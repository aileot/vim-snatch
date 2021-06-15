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
      \ get(g:, 'snatch#ins#attempt_to_escape_from_window', "\<C-w>p")

xnoremap <silent> <Plug>(snatch-into-cmdline) :call snatch#mode#cmd#op()<CR>

cnoremap <silent> <Plug>(snatch-operator) <C-\>e snatch#mode#cmd#operator()<CR>

" Note: Use <Cmd> for the first hand mappings.
" - <Esc> invokes `InsertLeave`.
" - <C-c> cannot distinguish which col cursor was inserted at 1 or 2 from the
"   beginning of a line.
" Note: <Cmd> and <Plug> cannot put in the same mapping. The mapping,
"   ```
"   inoremap <C-y> <Cmd>call s:foo("\<Plug>(bar)")<CR>
"   ```
"   throws the error E5522.
function! s:generate_imaps() abort
  " For example, `<Plug>(snatch-oneshot-hor-or-reg-ctrl-y)` is genearated.
  " Also generate `smaps`.
  inoremap <SID>(completion-keep-match) <space><BS>
  imap <expr> <SID>(by-force) pumvisible() ? '<SID>(completion-keep-match)' : ''
  snoremap <SID>(erase-placeholder) <space><BS>

  const strategies = {
        \ 'horizontal': ['horizontal_motion'],
        \ 'reg': ['register'],
        \ 'hor-or-reg': ['horizontal_motion', 'register'],
        \ 'oneshot-hor-or-reg': ['oneshot_horizontal', 'register'],
        \ }
  const pre_keys = {
        \ 'ctrl-y': 'kl',
        \ 'ctrl-e': 'jl',
        \ 'here': '',
        \ }

  for prefix in keys(strategies)
    for suffix in keys(pre_keys)
      let name = '(snatch-'. prefix .'-'. suffix .')'
      let plug = '<Plug>'. name
      let rhs = printf('<Cmd>call snatch#mode#ins#start({
            \ "pre_keys": %s,
            \ "strategies": %s,
            \ })<CR>', string(pre_keys[suffix]), string(strategies[prefix]))
      let i_rhs = '<SID>(by-force)'. rhs
      let s_rhs = '<SID>(erase-placeholder)'. rhs
      execute 'imap' plug i_rhs
      execute 'smap' plug s_rhs
    endfor
  endfor
endfunction
call s:generate_imaps()
delfunction s:generate_imaps

inoremap <Plug>(snatch-completion-confirm) <C-y>
inoremap <Plug>(snatch-completion-cancel) <C-e>

if !get(g:, 'snatch#no_default_mappings', 0)
  xmap z: <Plug>(snatch-into-cmdline)
  cmap <C-o> <Plug>(snatch-operator)

  smap <C-y> <Plug>(snatch-oneshot-hor-or-reg-ctrl-y)
  smap <C-e> <Plug>(snatch-oneshot-hor-or-reg-ctrl-e)

  imap <C-g><C-y> <Plug>(snatch-oneshot-hor-or-reg-ctrl-y)
  imap <C-g><C-e> <Plug>(snatch-oneshot-hor-or-reg-ctrl-e)

  imap <expr> <C-y> pumvisible() ? '<Plug>(snatch-completion-confirm)' : '<Plug>(snatch-oneshot-hor-or-reg-ctrl-y)'
  imap <expr> <C-e> pumvisible() ? '<Plug>(snatch-completion-cancel)' : '<Plug>(snatch-oneshot-hor-or-reg-ctrl-e)'
endif

