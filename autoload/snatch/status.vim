let s:stat = {}

function! s:stat__get() abort dict
  return self.val
endfunction
let s:stat.get = funcref('s:stat__get')

function! s:stat__validate_type(val) abort dict
  if type(a:val) == self.type | return | endif
  call snatch#utils#throw('Invalid type: '. string(a:val))
endfunction
let s:stat.validate_type = funcref('s:stat__validate_type')

function! s:stat__set(val) abort dict
  call self.validate_type(a:val)
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

function! s:stat__extend(item) abort dict
  const t_item = type(a:item)
  if t_item != type([]) && t_item != type({})
    const msg = 'Invalid type: '
          \ . string(a:item) .' must be a List or Dictionary'
    call snatch#utils#throw(msg)
  endif
  " Keep the item unique in list.
  if index(self.val, a:item) >= 0 | return | endif
  call extend(self.val, a:item)
endfunction
let s:stat.extend = funcref('s:stat__extend')

function! s:stat__remove(item) abort dict
  const idx = index(self.val, a:item)
  if idx == -1 | return | endif
  call remove(self.val, idx)
endfunction
let s:stat.remove = funcref('s:stat__remove')

function! snatch#status#new(default) abort
  let stat = deepcopy(s:stat)
  let stat.type = type(a:default)
  let stat.default = a:default
  let stat.val = a:default
  return stat
endfunction

