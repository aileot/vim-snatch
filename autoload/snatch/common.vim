let s:stat = {}
let s:prev_mode = snatch#status#new('NONE').register('prev_mode')
let s:is_sneaking = snatch#status#new(v:false).register('is_sneaking')

const s:is_cmdline_mode = '^[-:>/?@=]$'

const s:use_guicursor = exists('+guicursor')
if s:use_guicursor
  const s:hl_cursor_config = 'n-o:block-SnatchCursor'
  const s:default_hl_cursor = 'a:Cursor'
endif

augroup snatch/watch
  " For the simplicity, keep `is_sneaking` managed within this augroup.

  autocmd!
  autocmd User SnatchReadyPost  call s:is_sneaking.set(v:true)
  autocmd User SnatchInsertPost call s:is_sneaking.set(v:false)

  autocmd User SnatchAbortedPost   call s:is_sneaking.set(v:false)
  autocmd User SnatchCancelledPost call s:is_sneaking.set(v:false)
augroup END

function! s:save_state(config) abort
  call s:prev_mode.set(a:config.prev_mode)
endfunction

function! s:set_another_cursorhl() abort
  if s:use_guicursor
    exe 'set guicursor+='. s:hl_cursor_config
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
  call s:save_state(a:config)
  call s:set_another_cursorhl()
  " Note: Although `:stopinsert` above, and even the success of command,
  " `execute 'normal!' prekeys`, we're NOT in normal mode yet.
  call s:wait()
endfunction

function! s:wait() abort
  call snatch#augroup#begin('abort_on_some_events')
  autocmd!
  " Note: CmdlineEnter can be triggered up to user's mappings. Typically,
  " vim-camelcasemotion triggers the event immediately on each motion.
  const after_TextYankPost_is_triggerd = 50
  execute 'autocmd InsertEnter * ++once call timer_start('
        \ after_TextYankPost_is_triggerd
        \ ', {-> snatch#common#abort()})'

  autocmd! * <buffer>
  autocmd BufWinLeave <buffer> ++once call snatch#common#abort()
  call snatch#augroup#end()

  call snatch#strategy#register#wait()

  if g:snatch#timeoutlen > -1
    const callback = g:snatch#cancellation_policy ==? 'cancel'
          \ ? 'snatch#common#cancel'
          \ : 'snatch#common#abort'
    call timer_start(g:snatch#timeoutlen, callback)
  endif

  const after_prekeys_sent = 20
  call timer_start(after_prekeys_sent,
        \ {-> execute(':doautocmd <nomodeline> User SnatchReadyPost')})
endfunction

function! s:clean_up() abort
  " for key in keys(s:stat)
  "   call s:stat[key].reset()
  " endfor
  call s:restore_cursorhl()
  call snatch#augroup#clear()
endfunction

function! snatch#common#abort(...) abort
  if !s:is_sneaking.get()
    return v:false
  endif

  doautocmd <nomodeline> User SnatchAbortedPre
  call s:clean_up()
  doautocmd <nomodeline> User SnatchAbortedPost
  return v:true
endfunction

function! snatch#common#cancel(...) abort
  if !s:is_sneaking.get()
    return v:false
  endif

  const prev_mode = s:prev_mode.get()
  if prev_mode ==? 'i'
    doautocmd <nomodeline> User SnatchCancelledPre
    call s:clean_up()
    call snatch#mode#ins#restore_pos()
  elseif prev_mode =~# s:is_cmdline_mode
    doautocmd <nomodeline> User SnatchCancelledPre
    call s:clean_up()
    call snatch#mode#cmd#restore_pos()
  else
    call snatch#utils#throw('the previous mode cannot be identified')
  endif

  doautocmd <nomodeline> User SnatchCancelledPost
  return v:true
endfunction

" Terminate snatching successfully.
function! snatch#common#exit(strategy) abort
  call s:clean_up()
  doautocmd <nomodeline> User SnatchInsertPost
endfunction

function! snatch#common#insert(chars) abort
  doautocmd <nomodeline> User SnatchInsertPre

  const prev_mode = s:prev_mode.get()
  if prev_mode ==? 'i'
    call snatch#mode#ins#insert(a:chars)
  elseif prev_mode =~? s:is_cmdline_mode
    call snatch#mode#cmd#insert(a:chars)
  else
    call snatch#utils#throw('unexpected usage')
  endif
endfunction
