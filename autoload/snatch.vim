function! snatch#status() abort
  return snatch#common#status()
endfunction

function! snatch#cancel() abort
  if !snatch#status().is_snatching | return | endif
  doautocmd User SnatchStopPre
  call snatch#common#stop()
endfunction
