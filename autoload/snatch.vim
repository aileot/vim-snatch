function! s:insert_copied(chars) abort
  autocmd! snatch

  if !exists('s:insert_pos') | return | endif
  const old_lnum = s:insert_pos[1]
  const old_col = s:insert_pos[2]
  unlet s:insert_pos

  const chars = a:chars

  const old_line = getline(old_lnum)
  const preceding = old_col == 1 ? '' : old_line[ : old_col - 2 ]
  const new_line = preceding . chars . old_line[ old_col - 1 : ]
  call setline(old_lnum, new_line)

  call setpos('.', [0, old_lnum, old_col + strdisplaywidth(chars), 0])

  if strdisplaywidth(old_line) < old_col
    call feedkeys('a', 'n')
  else
    call feedkeys('i', 'n')
  endif
endfunction

function! s:save_reg() abort
  if g:snatch#clean_registers is# '' | return | endif
  let s:save_regcontents = {}
  for regname in split(g:snatch#clean_registers, '\zs')
    call extend(s:save_regcontents, { regname : getreg(regname) })
  endfor
endfunction

function! s:restore_reg(...) abort
  const regname = v:operator ==# 'y' ? '0' : v:register
  if matchstr(g:snatch#clean_registers, regname) is# '' | return | endif
  call setreg(regname, s:save_regcontents[regname])
  unlet s:save_regcontents
endfunction

function! s:insert_as_register(...) abort
  const chars = getreg(v:register)
  call s:insert_copied(chars)
endfunction

function! s:insert_as_motion() abort
  if !exists('s:start_pos')
    let s:start_pos = getpos('.')
    call s:wait_motions()
    return
  endif

  const pos = getpos('.')
  const old_lnum = s:start_pos[1]
  const new_lnum = pos[1]

  if s:recursive_motion ==# 'vertical'
        \ && (new_lnum != old_lnum || pos == s:start_pos)
    let s:start_pos = pos
    call s:wait_motions()
    return
  endif

  const start_col = s:start_pos[2]
  const end_col = col('.')
  const [ LEFT, RIGHT ] = sort([start_col, end_col], 'n')

  const target_line = getline('.')
  const chars = target_line[ LEFT - 1 : RIGHT - 1 ]

  call s:insert_copied(chars)
  unlet s:start_pos
endfunction

function! s:parse_snatch_events() abort
  const snatch_by = deepcopy(s:config.snatch_by)
  let s:use_register = index(snatch_by, 'register') >= 0
  let s:recursive_motion = index(snatch_by, 'any_motion') >= 0 ? 'none'
        \ : index(snatch_by, 'horizontal_motion') >= 0 ? 'vertical'
        \ : 'any'
endfunction

function! s:wait_motions() abort
  call s:parse_snatch_events()

  augroup snatch
    autocmd!

    if s:recursive_motion !=# 'any'
      autocmd CursorMoved * ++once call s:insert_as_motion()
      autocmd TextYankPost * ++once unlet s:start_pos
    endif

    if s:use_register
      " `TextYankPost` is not allowed to modify texts directly.
      autocmd TextYankPost * ++once
            \ call timer_start(0, expand('<SID>') .'insert_as_register')
      autocmd TextYankPost * ++once
            \ call timer_start(100, expand('<SID>') .'restore_reg')

      " Although CursorMoved is not always triggered as TextYankPost has been
      " triggered, once it is triggered, CursorMoved is sometimes earlier than
      " TextYankPost.
      autocmd TextYankPost * ++once silent! autocmd! snatch
    endif
  augroup END
endfunction

function! snatch#start(config) abort
  let s:insert_pos = getpos('.')
  call s:save_reg()

  let s:config = a:config
  const pre_keys = s:config.pre_keys
  if pre_keys !=# ''
    exe 'norm!' pre_keys
  endif

  noautocmd stopinsert
  call s:wait_motions()
endfunction

