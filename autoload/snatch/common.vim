let s:stat = {}
let s:stat.win_id = snatch#status#new(0)
let s:stat.insert_pos = snatch#status#new([])
let s:stat.prev_mode = snatch#status#new('NONE')
let s:stat.snatch_by = snatch#status#new([])
let s:stat.once_by = snatch#status#new([])
let s:stat.is_sneaking = snatch#status#new(v:false)

let s:is_cmdline_mode = '^[-:>/?@=]$'

let s:use_guicursor = exists('&guicursor')
if s:use_guicursor
  let s:hl_cursor_config = 'n-o:SnatchCursor'
endif

augroup snatch/watch
  " For the simplicity, keep `is_sneaking` managed within this augroup.

  autocmd!
  autocmd User SnatchReadyPost  call s:stat.is_sneaking.set(v:true)
  autocmd User SnatchInsertPost call s:stat.is_sneaking.set(v:false)

  autocmd User SnatchAbortedPost   call s:stat.is_sneaking.set(v:false)
  autocmd User SnatchCancelledPost call s:stat.is_sneaking.set(v:false)
augroup END

function! s:save_state(config) abort
  call s:stat.win_id.set(win_getid())
  call s:stat.prev_mode.set(a:config.prev_mode)
  call s:stat.snatch_by.set(get(a:config, 'snatch_by', []))
  call s:stat.once_by.set(get(a:config, 'once_by', []))
endfunction

function! s:set_another_cursorhl() abort
  if s:use_guicursor
    exe 'setlocal guicursor+='. s:hl_cursor_config
    return
  endif

  let s:save_hl = matchstr(execute('hi Cursor'), 'xxx\s\+\zs.*')
  hi! link Cursor SnatchCursor
endfunction

function! s:restore_cursorhl() abort
  if s:use_guicursor
    exe 'setlocal guicursor-='. s:hl_cursor_config
    return
  endif

  if s:save_hl =~# '^links'
    const hl_group = matchstr(s:save_hl, 'links to \zs\S\+')
    exe 'hi! link Cursor' hl_group
    return
  endif
  exe 'hi! Cursor' s:save_hl
endfunction

function! snatch#common#prepare(config) abort
  doautocmd User SnatchReadyPre
  noautocmd stopinsert

  call s:save_state(a:config)
  call s:set_another_cursorhl()

  const pre_keys = get(a:config, 'pre_keys', '')
  if pre_keys !=# ''
    exe 'norm!' pre_keys
  endif

  call s:wait()
endfunction

function! s:wait() abort
  augroup snatch/abort_on_some_events
    autocmd!
    " Note: CmdlineEnter can be triggered up to user's mappings. Typically,
    " vim-camelcasemotion triggers the event immediately on each motion.
    " FIXME: It throws E523.
    autocmd InsertEnter * ++once call snatch#common#abort()

    autocmd! * <buffer>
    autocmd BufWinLeave <buffer> call snatch#common#abort()
  augroup END

  const once_by = deepcopy(s:stat.once_by.get())
  const oneshot_hor = index(once_by, 'horizontal_motion') >= 0

  const snatch_by = deepcopy(s:stat.snatch_by.get())
  if oneshot_hor || index(snatch_by, 'horizontal_motion') >= 0
    call snatch#motion#wait(oneshot_hor)
  endif

  if index(snatch_by, 'register') >= 0
    call snatch#register#wait()
  endif

  if g:snatch#timeoutlen > -1
    const callback = g:snatch#cancellation_policy ==? 'cancel'
          \ ? 'snatch#common#cancel'
          \ : 'snatch#common#abort'
    call timer_start(g:snatch#timeoutlen, callback)
  endif
  doautocmd User SnatchReadyPost
endfunction

function! snatch#common#stop() abort
  " for key in keys(s:stat)
  "   call s:stat[key].reset()
  " endfor
  call s:restore_cursorhl()
  call snatch#augroup#clear()
endfunction

function! snatch#common#abort(...) abort
  if !s:stat.is_sneaking.get()
    return v:false
  endif

  doautocmd User SnatchAbortedPre
  call snatch#common#stop()
  doautocmd User SnatchAbortedPost
  return v:true
endfunction

function! snatch#common#cancel(...) abort
  if !s:stat.is_sneaking.get()
    return v:false
  endif

  const prev_mode = s:stat.prev_mode.get()
  if prev_mode ==? 'i'
    doautocmd User SnatchCancelledPre
    call snatch#common#stop()
    call snatch#ins#restore_pos()
  elseif prev_mode =~# s:is_cmdline_mode
    doautocmd User SnatchCancelledPre
    call snatch#common#stop()
    call snatch#cmd#restore_pos()
  else
    call snatch#utils#throw('the previous mode cannot be identified')
  endif

  doautocmd User SnatchCancelledPost
  return v:true
endfunction

function! snatch#common#insert(chars) abort
  doautocmd User SnatchInsertPre

  const prev_mode = s:stat.prev_mode.get()
  if prev_mode ==? 'i'
    call snatch#ins#insert(a:chars)
  elseif prev_mode =~? s:is_cmdline_mode
    call snatch#cmd#insert(a:chars)
  else
    call snatch#utils#throw('unexpected usage')
  endif

  call snatch#common#stop()
  doautocmd User SnatchInsertPost
endfunction

function! snatch#common#status() abort
  let stat = {}
  for key in keys(s:stat)
    let val = s:stat[key].get()
    let stat[key] = val
  endfor
  return stat
endfunction
