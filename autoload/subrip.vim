let s:regex_blank_line                    = '^\s*$'
let s:regex_counter_line                  = '^\d\+\s*$'
let s:regex_counter_line_after_blank_line = '^\s*\n\zs\d\+\s*$'
let s:regex_timecode_line                 = '^\d\d:\d\d:\d\d,\d\d\d\s\+-->\s\+\d\d:\d\d:\d\d,\d\d\d\s*$'
let s:regex_timestamp                     = '^\s*\(\d\d\):\(\d\d\):\(\d\d\),\(\d\d\d\)\s*$'

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
  if getline('.') !~# s:regex_counter_line
    echohl ErrorMsg | echo "Value on line " . line('.') . " is not a number. Cowardly refusing to change it. Value is: " . getline('.') | echohl Normal
    return
  endif

  " For all counter lines: Update the counter
  while v:true
    call setline(line('.'), l:counter)
    let l:counter += 1
    " search next counter line (only digits after empty line)
    let l:lnum = search(s:regex_counter_line_after_blank_line, 'W')
    if l:lnum ==# 0
      break
    endif
  endwhile

  call setpos('.', l:cur_pos)
endfunction

""
" Shift the timecodes of all entries by a fixed amount.
"
" This function accepts (and requires) a range and only operates on lines
" within that range.
"
" The function requests the desired range from the user and will apply it
" to all timecode lines in the given range.
"
" The amout to shift by must be specified in milliseconds.
"
" @params {amount} The milliseconds to shift the timecodes.
"                  If missing or v:false the function will request the
"                  amount from the user .
function! subrip#shift(amount = v:null) range abort
  echom 'amount ' . a:amount
  if a:amount is v:null
    let l:amount = input("Shift by (ms): ")
  else
    let l:amount = a:amount
  endif
  let l:firstline = a:firstline
  let l:lastline = a:lastline

  let l:cur_pos = getpos('.')

  call cursor(a:firstline - 1, 0)
  let l:timecode_lnum = -1
  while l:timecode_lnum isnot 0
    let l:timecode_lnum = search(s:regex_timecode_line, 'W', a:lastline)
    if l:timecode_lnum isnot 0
      call s:shift_timecode(l:timecode_lnum, l:amount)
    endif
  endwhile

  call setpos('.', l:cur_pos)
endfunction


""
" Shift the timecodes in the given line by the given amount.
"
" @param {timecode_lnum} The line number of the timecode line to operate on
" @param {amount}        The number of milliseconds to shift the timecodes by
function! s:shift_timecode(timecode_lnum, amount) abort
  let l:line = getline(a:timecode_lnum)
  if l:line !~# s:regex_timecode_line
    throw "Subrip001: Line " . a:timecode_lnum . ' is not a valid timecode line: ' . l:line
  endif

  let l:timecodes = split(l:line, '\s\+-->\s\+')
  if len(l:timecodes) isnot 2
    throw "Subrip001: Line " . a:timecode_lnum . ' is not a valid timecode line: ' . l:line
  endif

  let l:start = s:to_millis(l:timecodes[0]) + a:amount
  let l:end   = s:to_millis(l:timecodes[1]) + a:amount
  let l:newline = s:to_timestamp(l:start) . ' --> ' . s:to_timestamp(l:end)
  call setline(a:timecode_lnum, l:newline)
endfunction


""
" Convert a timecode timestamp to milliseconds
"
" @param {timestamp} The string-form of the timestamp to convert
" @return The milliseconds specified by the given timestamp
function! s:to_millis(timestamp) abort
  let l:regex_timestamp                     = '^\s*\(\d\d\):\(\d\d\):\(\d\d\),\(\d\d\d\)\s*$'
  let time_components= matchlist(a:timestamp, l:regex_timestamp)
  return str2nr(time_components[1]) * 1000 * 60 * 60
     \ + str2nr(time_components[2]) * 1000 * 60
     \ + str2nr(time_components[3]) * 1000
     \ + str2nr(time_components[4]) * 1
endfunction


""
" Convert the given milliseconds to a SRT timecode.
"
" @param {millis} The milliseconds to convert to a timecode
" @return The timecode string of the given milliseconds
function! s:to_timestamp(millis) abort
  let l:hours        = float2nr(a:millis / 1000 / 60 / 60)
  let l:remainder    = a:millis  - l:hours * 1000.0 * 60.0 * 60.0
  let l:minutes      = float2nr(l:remainder / 1000 / 60)
  let l:remainder    = l:remainder - l:minutes * 1000.0 * 60.0
  let l:seconds      = float2nr(l:remainder / 1000)
  let l:milliseconds = float2nr(l:remainder - l:seconds * 1000.0)
  return s:pad(string(l:hours),        2) . ':' .
       \ s:pad(string(l:minutes),      2) . ':' .
       \ s:pad(string(l:seconds),      2) . ',' .
       \ s:pad(string(l:milliseconds), 3)
endfunction


""
" Left-pad the given 'string' with zeroes to the given 'length'.
" If the given string is longer than the given length, the string will be
" returned as is.
"
" @param {string} the string to pad
" @param {length} the desired number of characters in the target string
" @return the given {string} padded with zeroes
function! s:pad(string, length) abort
  return repeat('0', a:length - len(a:string)) . a:string
endfunction
