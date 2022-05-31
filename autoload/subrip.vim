""
" Jump to the next (or previous) subtitle block.
"
" @param {backwards}: If v:true, jump backwards, otherwise forward.

" At the moment this is very naiive and only jumps to the counter line.
" This could be made better to jump to the same element in the next block,
" e.g. if the cursor is on the time element, jump to the time element in the
" next subtitle block.
function! subrip#jump_to_next_block(backwards) abort
  " TODO: Jump to the same level. If cursor is on number, jump to the
  " number. If cursor is on time, jump to time. If cursor is  on test, jump
  " to text.
  if a:backwards
    normal! {{j
  else
    normal! }j
  endif
endfunction

""
" Renumber all the counters in the file.
"
" This is necessary after adding or removing subtitle blocks.
function! subrip#renumber() abort
  let l:cur_pos = getpos('.')
  " Set a mark in the jumplist to be able to jump back if we error out
  " while processing the file
  normal! m'

  " Find the first counter line
  let l:firstline = nextnonblank(1)
  call cursor(l:firstline, 1)
  let l:counter = 1
  if getline('.') !~# '^\d\+\s*$'
    echohl ErrorMsg | echo "Value on line " . line('.') . " is not a number. Cowardly refusing to change it. Value is: " . getline('.') | echohl Normal
    return
  endif

  " For all counter lines: Update the counter
  while v:true
    call setline(line('.'), l:counter)
    let l:counter += 1
    " search next counter line (only digits after empty line)
    let l:lnum = search('^\s*$\n\zs\d\+\s*$', 'W')
    if l:lnum ==# 0
      break
    endif
  endwhile

  call setpos('.', l:cur_pos)
endfunction
