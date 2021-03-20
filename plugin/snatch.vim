let g:loaded_snatch = 1

let g:snatch#clean_registers = get(g:, 'snatch#clean_registers', '0')

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
inoremap <silent> <Plug>(snatch-horizontal-ctrl-y) <Cmd>call snatch#start({
      \   'pre_keys': 'kl',
      \   'snatch_by': ['horizontal_motion'],
      \ })<CR>
inoremap <silent> <Plug>(snatch-horizontal-ctrl-e) <Cmd>call snatch#start({
      \   'pre_keys': 'jl',
      \   'snatch_by': ['horizontal_motion'],
      \ })<CR>
inoremap <silent> <Plug>(snatch-horizontal-here) <Cmd>call snatch#start({
      \   'pre_keys': '',
      \   'snatch_by': ['horizontal_motion'],
      \ })<CR>

inoremap <silent> <Plug>(snatch-reg-ctrl-y) <Cmd>call snatch#start({
      \   'pre_keys': 'kl',
      \   'snatch_by': ['register'],
      \ })<CR>
inoremap <silent> <Plug>(snatch-reg-ctrl-e) <Cmd>call snatch#start({
      \   'pre_keys': 'jl',
      \   'snatch_by': ['register'],
      \ })<CR>
inoremap <silent> <Plug>(snatch-reg-here) <Cmd>call snatch#start({
      \   'pre_keys': '',
      \   'snatch_by': ['register'],
      \ })<CR>

inoremap <silent> <Plug>(snatch-reg-horizontal-ctrl-y) <Cmd>call snatch#start({
      \   'pre_keys': 'kl',
      \   'snatch_by': ['register', 'horizontal_motion'],
      \ })<CR>
inoremap <silent> <Plug>(snatch-reg-horizontal-ctrl-e) <Cmd>call snatch#start({
      \   'pre_keys': 'jl',
      \   'snatch_by': ['register', 'horizontal_motion'],
      \ })<CR>
inoremap <silent> <Plug>(snatch-reg-horizontal-here) <Cmd>call snatch#start({
      \   'pre_keys': '',
      \   'snatch_by': ['register', 'horizontal_motion'],
      \ })<CR>

if !get(g:, 'snatch#no_default_mappings', 0)
  cmap <C-o> <Plug>(snatch-operator)

  imap <C-y> <Plug>(snatch-reg-horizontal-ctrl-y)
  imap <C-e> <Plug>(snatch-reg-horizontal-ctrl-e)
endif

