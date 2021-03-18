function! s:insert_copied(chars) abort
  const chars = a:chars

  const old_lnum = s:insert_pos[1]
  const old_col = s:insert_pos[2]
  unlet s:insert_pos

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

function! op_copy#get_range() abort
  if !exists('s:start_pos')
    let s:start_pos = getpos('.')
    call s:wait_motions()
  endif

  const pos = getpos('.')
  const old_lnum = s:start_pos[1]
  const new_lnum = pos[1]

  if new_lnum != old_lnum || pos == s:start_pos
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

function! s:wait_motions() abort
  augroup operator_copy
    au!
    au CursorMoved * ++once call op_copy#get_range()
  augroup END
endfunction

function! op_copy#start(scout_keys) abort
  let s:insert_pos = getpos('.')
  exe 'norm! '. a:scout_keys
  noautocmd stopinsert
  call s:wait_motions()
endfunction

