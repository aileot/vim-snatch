let s:stat = {}
let s:stat.prev_mode = snatch#status#new('NONE').register('prev_mode')
let s:stat.strategies = snatch#status#new([]).register('strategies')
let s:stat.is_sneaking = snatch#status#new(v:false).register('is_sneaking')
let s:stat.pre_keys = snatch#status#new('').register('pre_keys')

const s:is_cmdline_mode = '^[-:>/?@=]$'

const s:use_guicursor = exists('+guicursor')
if s:use_guicursor
  const s:hl_cursor_config = 'n-o:block-SnatchCursor'
  const s:default_hl_cursor = 'a:Cursor'
endif

function! s:abort_if_no_strategies_are_available() abort
  if !empty(s:stat.strategies.get()) | return | endif
  call snatch#common#abort()
endfunction

augroup snatch/watch
  " For the simplicity, keep `is_sneaking` managed within this augroup.

  autocmd!
  autocmd User SnatchReadyPost  call s:stat.is_sneaking.set(v:true)
  autocmd User SnatchInsertPost call s:stat.is_sneaking.set(v:false)

  autocmd User SnatchAbortedPost   call s:stat.is_sneaking.set(v:false)
  autocmd User SnatchCancelledPost call s:stat.is_sneaking.set(v:false)

  autocmd User SnatchAbortedInPart-horizontal_motion
        \ call s:stat.strategies.remove(
        \ s:oneshot_hor
        \ ? 'oneshot_horizontal'
        \ : 'horizontal_motion')
  autocmd User SnatchAbortedInPart-horizontal_motion
        \ call s:abort_if_no_strategies_are_available()
augroup END

function! s:wait_if_surely_in_normal_mode(...) abort
  if mode() !=# 'n'
    call timer_start(50, expand('<SID>') .'wait_if_surely_in_normal_mode')
    return
  endif

  call s:wait()
endfunction

function! s:save_state(config) abort
  call s:stat.prev_mode.set(a:config.prev_mode)
  call s:stat.strategies.set(get(a:config, 'strategies', []))
endfunction

function! s:set_another_cursorhl() abort
  if s:use_guicursor
    exe 'set guicursor+='. s:hl_cursor_config
    if g:snatch#force_restore_cursor_highlight
      exe 'set guicursor-='. s:default_hl_cursor
    endif
    return
  endif

  let s:save_hl = matchstr(execute('hi Cursor'), 'xxx\s\+\zs.*')
  hi! link Cursor SnatchCursor
endfunction

function! s:restore_cursorhl() abort
  if s:use_guicursor
    exe 'set guicursor-='. s:hl_cursor_config
    if g:snatch#force_restore_cursor_highlight
      exe 'set guicursor^='. s:default_hl_cursor
    endif
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
  doautocmd <nomodeline> User SnatchReadyPre
  noautocmd stopinsert

  call s:save_state(a:config)
  call s:set_another_cursorhl()

  const pre_keys = get(a:config, 'pre_keys', '')
  call s:stat.pre_keys.set(pre_keys)
  if pre_keys !=# ''
    exe 'norm!' pre_keys
  endif

  " Note: Although `:stopinsert` above, and even the success of command,
  " `execute 'normal!' prekeys`, we're NOT in normal mode yet.
  call s:wait_if_surely_in_normal_mode()
endfunction

function! s:wait() abort
  call snatch#augroup#begin('abort_on_some_events')
  autocmd!
  " Note: CmdlineEnter can be triggered up to user's mappings. Typically,
  " vim-camelcasemotion triggers the event immediately on each motion.
  " FIXME: It throws E523.
  autocmd InsertEnter * ++once call snatch#common#abort()

  autocmd! * <buffer>
  autocmd BufWinLeave <buffer> ++once call snatch#common#abort()
  call snatch#augroup#end()

  const strategies = deepcopy(s:stat.strategies.get())
  let s:oneshot_hor = index(strategies, 'oneshot_horizontal') >= 0
  if s:oneshot_hor || index(strategies, 'horizontal_motion') >= 0
    call snatch#motion#wait(s:oneshot_hor)
  endif

  if index(strategies, 'register') >= 0
    call snatch#register#wait()
  endif

  if g:snatch#timeoutlen > -1
    const callback = g:snatch#cancellation_policy ==? 'cancel'
          \ ? 'snatch#common#cancel'
          \ : 'snatch#common#abort'
    call timer_start(g:snatch#timeoutlen, callback)
  endif
  doautocmd <nomodeline> User SnatchReadyPost
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

  doautocmd <nomodeline> User SnatchAbortedPre
  call snatch#common#stop()
  doautocmd <nomodeline> User SnatchAbortedPost
  return v:true
endfunction

function! snatch#common#cancel(...) abort
  if !s:stat.is_sneaking.get()
    return v:false
  endif

  const prev_mode = s:stat.prev_mode.get()
  if prev_mode ==? 'i'
    doautocmd <nomodeline> User SnatchCancelledPre
    call snatch#common#stop()
    call snatch#ins#restore_pos()
  elseif prev_mode =~# s:is_cmdline_mode
    doautocmd <nomodeline> User SnatchCancelledPre
    call snatch#common#stop()
    call snatch#cmd#restore_pos()
  else
    call snatch#utils#throw('the previous mode cannot be identified')
  endif

  doautocmd <nomodeline> User SnatchCancelledPost
  return v:true
endfunction

function! snatch#common#insert(chars) abort
  doautocmd <nomodeline> User SnatchInsertPre

  const prev_mode = s:stat.prev_mode.get()
  if prev_mode ==? 'i'
    call snatch#ins#insert(a:chars)
  elseif prev_mode =~? s:is_cmdline_mode
    call snatch#cmd#insert(a:chars)
  else
    call snatch#utils#throw('unexpected usage')
  endif

  call snatch#common#stop()
  doautocmd <nomodeline> User SnatchInsertPost
endfunction
