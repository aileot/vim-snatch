let s:stat = {}
let s:stat.win_id = snatch#status#new(0)
let s:stat.insert_pos = snatch#status#new([])
let s:stat.prev_mode = snatch#status#new('')
let s:stat.is_sneaking = snatch#status#new(v:false)
let s:stat.snatch_by = snatch#status#new([])

function! s:insert_copied(chars) abort
  autocmd! snatch

  if s:stat.insert_pos.is_reset() | return | endif
  const insert_pos = s:stat.insert_pos.get()
  const old_lnum = insert_pos[1]
  const old_col = insert_pos[2]
  call s:stat.insert_pos.reset()
  call s:stat.is_sneaking.set(v:false)

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
  if s:stat.insert_pos.is_reset()
    call s:stat.insert_pos.set(getpos('.'))
    call s:wait_motions()
    return
  endif

  const pos = getpos('.')
  const insert_pos = s:stat.insert_pos.get()
  const old_lnum = insert_pos[1]
  const new_lnum = pos[1]

  if s:recursive_motion ==# 'vertical'
        \ && (new_lnum != old_lnum || pos == insert_pos)
    let insert_pos = pos
    call s:wait_motions()
    return
  endif

  const insert_col = insert_pos[2]
  const end_col = col('.')
  const [ LEFT, RIGHT ] = sort([insert_col, end_col], 'n')

  const target_line = getline('.')
  const chars = target_line[ LEFT - 1 : RIGHT - 1 ]

  call s:insert_copied(chars)
  call s:stat.insert_pos.reset()
endfunction

function! s:parse_snatch_events() abort
  const snatch_by = deepcopy(s:stat.snatch_by.get())
  let s:use_register = index(snatch_by, 'register') >= 0
  let s:recursive_motion = index(snatch_by, 'any_motion') >= 0 ? 'none'
        \ : index(snatch_by, 'horizontal_motion') >= 0 ? 'vertical'
        \ : 'any'
endfunction

function! s:wait_motions() abort
  call s:stat.is_sneaking.set(v:true)
  call s:parse_snatch_events()

  augroup snatch
    autocmd!

    if s:recursive_motion !=# 'any'
      autocmd CursorMoved * ++once call s:stat.insert_as_motion()
      autocmd TextYankPost * ++once s:stat.insert_pos.reset()
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
  call s:stat.insert_pos.set(getpos('.'))
  call s:stat.win_id.set(win_getid())
  call s:stat.prev_mode.set('insert')
  call s:stat.snatch_by.set(a:config.snatch_by)

  call s:save_reg()

  const pre_keys = a:config.pre_keys
  if pre_keys !=# ''
    exe 'norm!' pre_keys
  endif

  noautocmd stopinsert
  call s:wait_motions()
endfunction

function! snatch#status() abort
  let stat = {}

  for key in keys(s:stat)
    let val = s:stat[key].get()
    let stat[key] = val
  endfor
  return stat
endfunction
