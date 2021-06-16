function! s:save_cmdline() abort
  let s:save_line = getcmdline()
  let s:save_col = getcmdpos() - 1
  let s:save_cmdtype = getcmdtype()

  " Save current pending command not to lose it on interruption, or on the
  " failure to get motion. Delete it from the history when operator function
  " has been warranted to succeed.
  call histadd(s:save_cmdtype, s:save_line)

  " TODO: Modify the behavior for each cmdtype.
  if s:save_cmdtype ==# '@'
    call snatch#utils#throw("input() is not supported")
  elseif s:save_cmdtype ==# '-'
    call snatch#utils#throw("either `:insert` or `:append` is not supported")
  elseif s:save_cmdtype ==# '='
    " TODO: If possible, save both lines of ':' and '=' and restore then later.
    call snatch#utils#throw("expression register is not supported")
    return ''
  endif

  return ''
endfunction

function! s:prepare() abort
  call s:save_cmdline()

  const config = {
        \ 'strategies': ['operator'],
        \ 'prev_mode': s:save_cmdtype,
        \ }
  call snatch#common#prepare(config)
endfunction

function! s:imitate_pending_cmdline() abort
  const sep = g:snatch#cmd#position_marker
  const line = s:save_line[: s:save_col - 1] . sep . s:save_line[s:save_col :]
  echo s:save_cmdtype . line
endfunction

function! s:insert_to_cmdline(chars) abort
  const line = s:save_line
  const col = s:save_col
  const type = s:save_cmdtype

  call histdel(type, -1)

  " TODO: Restore highlights after easymotion.
  const keys = type . line . repeat("\<Left>", len(line) - col) . a:chars
  call feedkeys(keys, 'n')
endfunction

function! snatch#mode#cmd#insert(chars) abort
  call s:insert_to_cmdline(a:chars)
endfunction

function! snatch#mode#cmd#op(...) abort
  if a:0
    const LEFT =  col("'[") - 1
    const RIGHT =  col("']") - 1
  else
    const text = getline('.')[ col("'<") - 1 : col("'>") - 1]
    call feedkeys(':'. text, 'n')
    return
  endif
  const line = getline('.')
  const chars = line[ LEFT : RIGHT ]
  call snatch#common#insert(chars)
  call snatch#common#exit('operator')
endfunction

function! snatch#mode#cmd#operator() abort
  call s:prepare()
  set operatorfunc=snatch#mode#cmd#op
  call feedkeys("\<Esc>", 'n')
  call s:imitate_pending_cmdline()
  call feedkeys('g@', 'n')
  return ''
endfunction

function! snatch#mode#cmd#restore_pos() abort
  call s:insert_to_cmdline('')
endfunction

