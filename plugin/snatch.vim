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

xnoremap <silent> <Plug>(snatch-into-cmdline) :call snatch#cmd#op()<CR>

cnoremap <silent> <Plug>(snatch-operator) <C-\>e snatch#cmd#operator()<CR>

" Note: Use <Cmd> for the first hand mappings.
" - <Esc> invokes `InsertLeave`.
" - <C-c> cannot distinguish which col cursor was inserted at 1 or 2 from the
"   beginning of a line.
" Note: <Cmd> and <Plug> cannot put in the same mapping. The mapping,
"   ```
"   inoremap <C-y> <Cmd>call s:foo("\<Plug>(bar)")<CR>
"   ```
"   throws the error E5522.
inoremap <silent> <SID>(snatch-horizontal-ctrl-y)
      \ <Cmd>call snatch#ins#start({
      \   'pre_keys': 'kl',
      \   'strategies': ['horizontal_motion'],
      \ })<CR>
inoremap <silent> <SID>(snatch-horizontal-ctrl-e)
      \ <Cmd>call snatch#ins#start({
      \   'pre_keys': 'jl',
      \   'strategies': ['horizontal_motion'],
      \ })<CR>
inoremap <silent> <SID>(snatch-horizontal-here)
      \ <Cmd>call snatch#ins#start({
      \   'strategies': ['horizontal_motion'],
      \ })<CR>

inoremap <silent> <SID>(snatch-reg-ctrl-y)
      \ <Cmd>call snatch#ins#start({
      \   'pre_keys': 'kl',
      \   'strategies': ['register'],
      \ })<CR>
inoremap <silent> <SID>(snatch-reg-ctrl-e)
      \ <Cmd>call snatch#ins#start({
      \   'pre_keys': 'jl',
      \   'strategies': ['register'],
      \ })<CR>
inoremap <silent> <SID>(snatch-reg-here)
      \ <Cmd>call snatch#ins#start({
      \   'strategies': ['register'],
      \ })<CR>

inoremap <silent> <SID>(snatch-hor-or-reg-ctrl-y)
      \ <Cmd>call snatch#ins#start({
      \   'pre_keys': 'kl',
      \   'strategies': ['register', 'horizontal_motion'],
      \ })<CR>
inoremap <silent> <SID>(snatch-hor-or-reg-ctrl-e)
      \ <Cmd>call snatch#ins#start({
      \   'pre_keys': 'jl',
      \   'strategies': ['register', 'horizontal_motion'],
      \ })<CR>
inoremap <silent> <SID>(snatch-hor-or-reg-here)
      \ <Cmd>call snatch#ins#start({
      \   'strategies': ['register', 'horizontal_motion'],
      \ })<CR>

inoremap <silent> <SID>(snatch-oneshot-hor-or-reg-ctrl-y)
      \ <Cmd>call snatch#ins#start({
      \   'pre_keys': 'kl',
      \   'strategies': ['register', 'oneshot_horizontal'],
      \ })<CR>
inoremap <silent> <SID>(snatch-oneshot-hor-or-reg-ctrl-e)
      \ <Cmd>call snatch#ins#start({
      \   'pre_keys': 'jl',
      \   'strategies': ['register', 'oneshot_horizontal'],
      \ })<CR>
inoremap <silent> <SID>(snatch-oneshot-hor-or-reg-here)
      \ <Cmd>call snatch#ins#start({
      \   'once_by': ['horizontal_motion'],
      \   'strategies': ['register', 'oneshot_horizontal'],
      \ })<CR>

imap <Plug>(snatch-horizontal-ctrl-y)         <SID>(snatch-horizontal-ctrl-y)
imap <Plug>(snatch-horizontal-ctrl-e)         <SID>(snatch-horizontal-ctrl-e)
imap <Plug>(snatch-horizontal-here)           <SID>(snatch-horizontal-here)
imap <Plug>(snatch-reg-ctrl-y)                <SID>(snatch-reg-ctrl-y)
imap <Plug>(snatch-reg-ctrl-e)                <SID>(snatch-reg-ctrl-e)
imap <Plug>(snatch-reg-here)                  <SID>(snatch-reg-here)
imap <Plug>(snatch-hor-or-reg-ctrl-y)         <SID>(snatch-hor-or-reg-ctrl-y)
imap <Plug>(snatch-hor-or-reg-ctrl-e)         <SID>(snatch-hor-or-reg-ctrl-e)
imap <Plug>(snatch-hor-or-reg-here)           <SID>(snatch-hor-or-reg-here)
imap <Plug>(snatch-oneshot-hor-or-reg-ctrl-y) <SID>(snatch-oneshot-hor-or-reg-ctrl-y)
imap <Plug>(snatch-oneshot-hor-or-reg-ctrl-e) <SID>(snatch-oneshot-hor-or-reg-ctrl-e)
imap <Plug>(snatch-oneshot-hor-or-reg-here)   <SID>(snatch-oneshot-hor-or-reg-here)

snoremap <SID>(erase) <space><BS>

smap <Plug>(snatch-horizontal-ctrl-y)         <SID>(erase)<SID>(snatch-horizontal-ctrl-y)
smap <Plug>(snatch-horizontal-ctrl-e)         <SID>(erase)<SID>(snatch-horizontal-ctrl-e)
smap <Plug>(snatch-horizontal-here)           <SID>(erase)<SID>(snatch-horizontal-here)
smap <Plug>(snatch-reg-ctrl-y)                <SID>(erase)<SID>(snatch-reg-ctrl-y)
smap <Plug>(snatch-reg-ctrl-e)                <SID>(erase)<SID>(snatch-reg-ctrl-e)
smap <Plug>(snatch-reg-here)                  <SID>(erase)<SID>(snatch-reg-here)
smap <Plug>(snatch-hor-or-reg-ctrl-y)         <SID>(erase)<SID>(snatch-hor-or-reg-ctrl-y)
smap <Plug>(snatch-hor-or-reg-ctrl-e)         <SID>(erase)<SID>(snatch-hor-or-reg-ctrl-e)
smap <Plug>(snatch-hor-or-reg-here)           <SID>(erase)<SID>(snatch-hor-or-reg-here)
smap <Plug>(snatch-oneshot-hor-or-reg-ctrl-y) <SID>(erase)<SID>(snatch-oneshot-hor-or-reg-ctrl-y)
smap <Plug>(snatch-oneshot-hor-or-reg-ctrl-e) <SID>(erase)<SID>(snatch-oneshot-hor-or-reg-ctrl-e)
smap <Plug>(snatch-oneshot-hor-or-reg-here)   <SID>(erase)<SID>(snatch-oneshot-hor-or-reg-here)

if !get(g:, 'snatch#no_default_mappings', 0)
  xmap z: <Plug>(snatch-into-cmdline)
  cmap <C-o> <Plug>(snatch-operator)

  inoremap <SID>(C-y) <C-y>
  inoremap <SID>(C-e) <C-y>
  imap <expr> <C-y> pumvisible() ? '<SID>(C-y)' : '<Plug>(snatch-oneshot-hor-or-reg-ctrl-y)'
  imap <expr> <C-e> pumvisible() ? '<SID>(C-e)' : '<Plug>(snatch-oneshot-hor-or-reg-ctrl-e)'
  smap <C-y> <Plug>(snatch-oneshot-hor-or-reg-ctrl-y)
  smap <C-e> <Plug>(snatch-oneshot-hor-or-reg-ctrl-e)
endif

