let s:regex_blank_line                    = '^\s*$'
let s:regex_counter_line                  = '^\d\+\s*$'
let s:regex_counter_line_after_blank_line = '^\s*\n\zs\d\+\s*$'
let s:regex_timecode_line                 = '^\d\d:\d\d:\d\d,\d\d\d\s\+-->\s\+\d\d:\d\d:\d\d,\d\d\d\s*$'

""
" Jump to the next (or previous) subtitle block.
"
" @param {backwards}: If v:true, jump backwards, otherwise forward.
"
" The jump will take the current element type of the cursor line into
" account and will jump to the corresponding element in the next / previous
" subtitle block.
" That means: if the cursor is on the timecode line, jump to the timecode
" line in the next / previous subtitle block.
function! subrip#jump_to_next_block(backwards) abort
  " Find the type of the current line
  let l:line = getline('.')
  if l:line =~# s:regex_blank_line
    let l:current_element = 'blank'
  elseif l:line =~# s:regex_counter_line && getline(line('.')-1) =~# s:regex_blank_line
    let l:current_element = 'counter'
  elseif l:line =~# s:regex_timecode_line
    let l:current_element = 'timecode'
  else
    let l:current_element  = 'caption'
  endif

  " Prepare search flags
  if a:backwards
    let l:searchflags = 'bW'
  else
    let l:searchflags = 'W'
  endif

  " now search the same element type in the next / previous subtitle block
  if l:current_element ==# 'blank'
    let l:lnum = search(s:regex_blank_line, l:searchflags)
    if l:lnum ==# 0 && a:backwards
      call cursor(1, virtcol('.'))
    endif
  elseif l:current_element ==# 'counter'
    let l:lnum = search(s:regex_counter_line_after_blank_line, l:searchflags)
  elseif l:current_element ==# 'timecode'
    let l:lnum = search(s:regex_timecode_line, l:searchflags)
  else
    if a:backwards
      let s:cur_pos = getpos('.')
      let l:lnum = search(s:regex_timecode_line, l:searchflags)
    endif

    let l:lnum = search(s:regex_timecode_line, l:searchflags)
    if l:lnum !=# 0
        normal! j
    elseif a:backwards
      call setpos('.', s:cur_pos)
    endif
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
