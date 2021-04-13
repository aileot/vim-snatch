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

function! s:insert_as_reg(...) abort
  const chars = getreg(v:register)
  call snatch#common#insert(chars)
endfunction

function! snatch#register#wait() abort
  call s:save_reg()

  call snatch#augroup#begin('register')
  autocmd!

  " `TextYankPost` is not allowed to modify texts directly.
  autocmd TextYankPost * ++once
        \ call timer_start(0, expand('<SID>') .'insert_as_reg')
  autocmd TextYankPost * ++once
        \ call timer_start(100, expand('<SID>') .'restore_reg')

  " " Although CursorMoved is not always triggered as TextYankPost has been
  " " triggered, once it is triggered, CursorMoved is sometimes earlier than
  " " TextYankPost.
  " autocmd TextYankPost * ++once call snatch#common#stop()

  call snatch#augroup#end()
endfunction
