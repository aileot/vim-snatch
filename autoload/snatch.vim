function! snatch#status() abort
  return snatch#common#status()
endfunction

function! snatch#abort() abort
  call snatch#common#abort()
endfunction

function! snatch#cancel() abort
  call snatch#common#cancel()
endfunction
