let s:stat = {}

function! s:stat__get() abort dict
  return self.val
endfunction
let s:stat.get = funcref('s:stat__get')

function! s:stat__set(val) abort dict
  let self.val = a:val
endfunction
let s:stat.set = funcref('s:stat__set')

function! s:stat__reset() abort dict
  let self.val = self.default
endfunction
let s:stat.reset = funcref('s:stat__reset')

function! s:stat__is_reset() abort dict
  return self.val == self.default
endfunction
let s:stat.is_reset = funcref('s:stat__is_reset')

function! snatch#status#new(default) abort
  let stat = deepcopy(s:stat)
  let stat.default = a:default
  let stat.val = a:default
  return stat
endfunction

