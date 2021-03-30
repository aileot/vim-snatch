let s:insert_pos = snatch#status#new([])

hi def link SnatchPrevPos DiffAdd

augroup snatch/ins/highlight
  autocmd!
augroup END

function! s:highlight_insert_pos() abort
  let [l, c] = s:insert_pos.get()[1 : 2]
  if c == col('$')
    " TODO: Distinguish the highlight for the last column from that for the one
    " just before the last. If we could set highlight in vertical line instead
    " of in rectangle, substitute it.
    let c -= 1
  endif
  const m = matchaddpos('SnatchPrevPos', [[l, c]])
  augroup snatch/ins/highlight
    exe 'autocmd User SnatchStopPost ++once call s:highlight_clear(' m ')'
  augroup END
endfunction

function! s:highlight_clear(m) abort
  call matchdelete(a:m)
endfunction


function! s:prepare(config) abort
  call s:insert_pos.set(getpos('.'))
  call s:highlight_insert_pos()
  call snatch#common#prepare(a:config)
endfunction

function! snatch#ins#start(config) abort
  const config = extend(deepcopy(a:config), {'prev_mode': 'insert'})
  call s:prepare(config)
  noautocmd stopinsert
  call snatch#common#wait()
endfunction

function! snatch#ins#insert(chars) abort
  if s:insert_pos.is_reset() | return | endif
  const insert_pos = s:insert_pos.get()
  const old_lnum = insert_pos[1]
  const old_col = insert_pos[2]
  call s:insert_pos.reset()

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

