let s:old_pos = snatch#status#new([])
let s:win_id = snatch#status#new(0)

function! s:abort_horizontal_detection(au_name) abort
  call s:old_pos.reset()
  " Note: FileType invokes after WinNew or WinEnter does so that it's hard to
  " abort just on specific filetypes.
  call snatch#augroup#clear(a:au_name)
  doautocmd <nomodeline> User SnatchAbortedInPart-horizontal_motion
endfunction

function! s:insert_on_horizontal_motion(au_name, oneshot) abort
  if win_getid() != s:win_id.get()
    call s:abort_horizontal_detection(a:au_name)
    return
  endif

  const old_pos = s:old_pos.get()
  const new_pos = getcurpos()
  const new_lnum = new_pos[1]
  const old_lnum = old_pos[1]

  const is_horizontal_motion = new_lnum == old_lnum
  if !is_horizontal_motion
    if a:oneshot
      call s:abort_horizontal_detection(a:au_name)
      return
    endif

    call s:old_pos.set(new_pos)
    return
  endif

  const insert_col = old_pos[2]
  const end_col = col('.')
  const [ LEFT, RIGHT ] = sort([insert_col, end_col], 'n')

  const target_line = getline('.')
  const chars = target_line[ LEFT - 1 : RIGHT - 1 ]

  call snatch#common#insert(chars)
  " In common.vim, clear the autocmds on CursorMoved.
  call snatch#common#exit()
endfunction

function! snatch#motion#wait(oneshot) abort
  const au_name = snatch#augroup#begin('motion')
  autocmd!
  call s:old_pos.set(getcurpos())
  call s:win_id.set(win_getid())
  " Creating a new window triggers CursorMoved, which often makes unexpected
  " snatching. WinNew did not fix this problem.
  execute 'autocmd CursorMoved *'
        \ 'call s:insert_on_horizontal_motion(' string(au_name) ',' a:oneshot ')'
  call snatch#augroup#end()
endfunction
