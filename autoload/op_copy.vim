function! op_copy#copy_as_range(...) abort
  if exists('s:repeat_keys')
    " Tips: Because the motion keys might override `g:repeat_sequence`,
    " repeat#set() should be invoked inside this function, which is registered
    " in &operatorfunc.
    silent! call repeat#set(s:repeat_keys)
    unlet s:repeat_keys
  endif

  if a:0
    const LEFT  = col("'[")
    const RIGHT = col("']")
  else
    const LEFT  = col("'<")
    const RIGHT = col("'>")
  endif

  const line = getline('.')
  const chars = line[ LEFT : RIGHT - 1 ]

  " TODO: Let `.` make sense.
  exe 'norm! gi'. chars
endfunction

function! op_copy#start(scout_keys) abort
  stopinsert

  exe 'norm!' a:scout_keys
  set operatorfunc=op_copy#copy_as_range
  call feedkeys('g@', 'n')
endfunction

