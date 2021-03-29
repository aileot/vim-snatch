let s:groups = []

function! snatch#augroup#begin(name) abort
  " Start defining augroup, registering it with a list of augroups which should
  " be at once cleared by snatch#augroup#clear().

  const group = 'snatch/'. a:name
  let s:groups += [ group ]
  exe 'augroup' group
  autocmd!
endfunction

function! snatch#augroup#end() abort
  " Resolve indent-problem with GetVimIndent() (default &indentexpr for VimL).
  exe 'augroup END'
endfunction

function! snatch#augroup#clear() abort
  let groups = s:groups
  call uniq(groups)
  for grp in groups
    exe 'autocmd!' grp
  endfor
  let s:groups = []
endfunction
