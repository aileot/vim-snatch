let s:old_pos = snatch#status#new([])

function! s:abort_horizontal_detection(au_name) abort
  " Note: FileType invokes after WinNew or WinEnter does so that it's hard to
  " abort just on specific filetypes.
  call snatch#augroup#clear(a:au_name)
endfunction

function! s:insert_on_horizontal_motion(oneshot) abort
  if s:old_pos.is_reset()
    call s:old_pos.set(getcurpos())
    call snatch#motion#wait(a:oneshot)
    return
  endif

  const old_pos = s:old_pos.get()
  const new_pos = getcurpos()
  const new_lnum = new_pos[1]
  const old_lnum = old_pos[1]

  const is_horizontal_motion = new_lnum == old_lnum
  if !is_horizontal_motion
    if a:oneshot
      call s:old_pos.reset()
      return
    endif

    call s:old_pos.set(new_pos)
    call snatch#motion#wait(a:oneshot)
    return
  endif

  const insert_col = old_pos[2]
  const end_col = col('.')
  const [ LEFT, RIGHT ] = sort([insert_col, end_col], 'n')

  const target_line = getline('.')
  const chars = target_line[ LEFT - 1 : RIGHT - 1 ]

  call snatch#common#insert(chars)

  call s:old_pos.reset()
endfunction

function! snatch#motion#wait(oneshot) abort
  const au_name = snatch#augroup#begin('motion')
  autocmd!
  " Creating a new window triggers CursorMoved, which often makes unexpected
  " snatching. WinNew did not fix this problem.
  execute 'autocmd WinNew,WinEnter * ++once'
        \  'call s:abort_horizontal_detection(' string(au_name) ')'
  execute 'autocmd CursorMoved * ++once'
        \ 'call s:insert_on_horizontal_motion(' a:oneshot ')'
  call snatch#augroup#end()
endfunction
