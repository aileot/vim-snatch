function! snatch#utils#throw(msg) abort
  call snatch#common#abort()

  throw '[Snatch] '. a:msg
endfunction
