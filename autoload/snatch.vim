function! snatch#status() abort
  return snatch#common#status()
endfunction

function! snatch#cancel() abort
  if !snatch#status().is_sneaking | return | endif
  doautocmd User SnatchCancelledPre
  call snatch#common#stop()
  doautocmd User SnatchCancelledPost
endfunction
