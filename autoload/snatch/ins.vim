let s:win_id = snatch#status#new(0)
let s:insert_pos = snatch#status#new([])

function! s:highlight_insert_pos() abort
  let [l, c] = s:insert_pos.get()[1 : 2]
  if c == col('$')
    " TODO: Distinguish the highlight for the last column from that for the one
    " just before the last. If we could set highlight in vertical line instead
    " of in rectangle, substitute it.
    let c -= 1
  endif
  const m = matchaddpos('SnatchInsertPos', [[l, c]])
  const id = s:win_id.get()

  call snatch#augroup#begin('ins/highlight-insert_pos')
  autocmd!
  exe 'autocmd User SnatchInsertPre    ++once call s:highlight_clear(' m ',' id ')'
  exe 'autocmd User SnatchAbortedPre   ++once call s:highlight_clear(' m ',' id ')'
  exe 'autocmd User SnatchCancelledPre ++once call s:highlight_clear(' m ',' id ')'
  call snatch#augroup#end()
endfunction

function! s:highlight_clear(m, winid) abort
  call matchdelete(a:m, a:winid)
  silent! autocmd! snatch/ins/highlight-insert_pos
endfunction


function! s:prepare(config) abort
  call s:insert_pos.set(getpos('.'))
  call s:win_id.set(win_getid())
  call s:highlight_insert_pos()
  call snatch#common#prepare(a:config)
endfunction

function! snatch#ins#start(config) abort
  const config = extend(deepcopy(a:config), {'prev_mode': 'i'})
  call s:prepare(config)
endfunction

function! s:restore_pos() abort
  if s:insert_pos.is_reset()
    snatch#utils#throw('invalid usage')
  endif

  call win_gotoid(s:win_id.get())
  const [lnum, col] = s:insert_pos.get()[1:2]
  call s:insert_pos.reset()

  call setpos('.', [0, lnum, col])
  return [lnum, col]
endfunction

function! s:restart_insertmode(lnum, col, new_chars) abort
  let chars = a:new_chars
  if mode(1) !~# 'i'
    const old_width = strdisplaywidth(getline(a:lnum))
    const reinsert = old_width < a:col ? 'a' : 'i'
    let chars = reinsert . chars
  endif
  call feedkeys(chars, 'n')
endfunction

function! snatch#ins#insert(chars) abort
  const [lnum, col] = s:restore_pos()
  call s:restart_insertmode(lnum, col, a:chars)
endfunction

function! snatch#ins#restore_pos() abort
  call s:restore_pos()
endfunction
