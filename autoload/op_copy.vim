function! op_copy#copy_as_range(...) abort
  if !exists('s:save_pos')
    throw 'Operator Copy: unexpected usage.'
  endif

  if a:0
    const LEFT  = col("'[")
    const RIGHT = col("']")
  else
    const LEFT  = col("'<")
    const RIGHT = col("'>")
  endif

  const line = getline('.')
  " TODO: Let `.` make sense.
  const chars = line[ LEFT - 1 : RIGHT - 1 ]
  echomsg chars

  const old_lnum = s:save_pos[1]
  const old_col = s:save_pos[2]
  unlet s:save_pos

  const old_line = getline(old_lnum)
  const new_line = old_line[ : LEFT - 2 ] . chars . old_line[ LEFT - 1 : ]
  call setline(old_lnum, new_line)

  call setpos('.', [0, old_lnum, old_col + strdisplaywidth(chars), 0])

  if strdisplaywidth(old_line) < LEFT
    norm! a
  else
    norm! i
  endif
endfunction

function! op_copy#start(scout_keys) abort
  let s:save_pos = getpos('.')
  exe 'norm! '. a:scout_keys
  set operatorfunc=op_copy#copy_as_range
  call feedkeys("\<C-c>g@", 'n')
endfunction

