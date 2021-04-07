let s:std_pos = snatch#status#new([])

function! s:insert_on_horizontal_motion() abort
  if s:std_pos.is_reset()
    call s:std_pos.set(getpos('.'))
    call snatch#motion#wait()
    return
  endif

  const pos = getpos('.')
  let std_pos = s:std_pos.get()
  const old_lnum = std_pos[1]
  const new_lnum = pos[1]

  const is_horizontal_motion = new_lnum != old_lnum || pos == std_pos
  if !is_horizontal_motion
    call s:std_pos.set(pos)
    call snatch#motion#wait()
    return
  endif

  const insert_col = std_pos[2]
  const end_col = col('.')
  const [ LEFT, RIGHT ] = sort([insert_col, end_col], 'n')

  const target_line = getline('.')
  const chars = target_line[ LEFT - 1 : RIGHT - 1 ]

  call snatch#common#insert(chars)
  call s:std_pos.reset()
endfunction

function! snatch#motion#wait() abort
  call snatch#augroup#begin('motion')
  autocmd CursorMoved * ++once call s:insert_on_horizontal_motion()
  call snatch#augroup#end()
endfunction
