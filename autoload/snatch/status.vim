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

function! s:stat__add(item) abort dict
  " Keep the item unique in list.
  if index(self.val, a:item) >= 0 | return | endif
  call add(self.val, a:item)
endfunction
let s:stat.add = funcref('s:stat__add')

function! s:stat__remove(item) abort dict
  const idx = index(self.val, a:item)
  if idx == -1 | return | endif
  call remove(self.val, idx)
endfunction
let s:stat.remove = funcref('s:stat__remove')

function! snatch#status#new(default) abort
  let stat = deepcopy(s:stat)
  let stat.default = a:default
  let stat.val = a:default
  return stat
endfunction

