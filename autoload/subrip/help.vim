" The pattern to identify <Plug>-mappings for this plugin
let s:plugmap_pattern = "<Plug>(Srt"

""
" Show a short help regarding the current mappings and settings.
function! subrip#help#show() abort
  let l:a = @a

  " Find all normal mode mappings to this plugins <Plug>-Mappings
  redir @a
  silent map
  silent imap
  redir END
  let l:mappings = split(@a, "\n")
  call filter(l:mappings, 'v:val =~ s:plugmap_pattern')
  call map(l:mappings, 'split(v:val)')
  call filter(l:mappings, 'v:val[-1] =~ s:plugmap_pattern')
  "call map(l:mappings, 'v:val[1:]')
  call  sort(l:mappings, 's:compare_mappings')

  let @a = l:a

  " calculate the max length of all mappings
  let l:mappings_max_length = 0
  for m in l:mappings
    let l:mappings_max_length = max([l:mappings_max_length, len(m[1])])
  endfor

  " Prepare the help content
  let content = ['See `:help subrip` for more details and the hardcoded defaults.']
  call extend(content, ['', 'MAPPINGS', ''])
  for m in l:mappings
    let l:map = s:pad('*' . m[1] . '*', l:mappings_max_length + 2)
    call add(content, '  ' . m[0] . '  ' . l:map . '  ' . m[2])
  endfor
  "call extend(content, ['', 'SETTINGS', ''])
  "call add(content, '  *g:push_no_default_mappings* = ' . get(g:, 'push_no_default_mappings', '<unset>'))

  " Open the dialog
  let opts = {'syntax': 'help'}
  if exists('g:quickui_version')
    call quickui#textbox#open(content, opts)
  else
    call s:show_in_window(content)
  endif
endfunction


""
" Compare two lists with mapping information.
"
" Both lists must have exactly 3 items:
"
"   1. mode
"   2. {lhs}
"   3. {rhs}
"
" Comparison will compare from the last to the first item. That means first the
" {rhs} is compared, if they are equal, the {lhs} is compared and only if
" that is equal the mode will be compared.
"
" @returns - a positive integer if 'm1' is considered "after" 'm2'
"          - a negative integer if 'm1' is considered "before" 'm2'
"          - 0 if both are considered equal
function! s:compare_mappings(m1, m2) abort
  let l:result = s:compare(a:m1[2], a:m2[2])
  if l:result !=# 0
    return l:result
  endif

  let l:result = s:compare(a:m1[1], a:m2[1])
  if l:result !=# 0
    return l:result
  endif

  return s:compare(a:m1[0], a:m2[0])
endfunction


""
" Compare two values.
"
" @return -1 if the first argument is considered smaller
"          1 if the first argument is considered  larger
"          0 if both arguments are considered equal
function! s:compare(v1, v2) abort
  if a:v1 < a:v2
    return -1
  elseif a:v1 > a:v2
    return 1
  else
    return 0
  endif
endfunction


""
" Display the given lines of text in a new split window.
"
" The window will be resized to display the whole text.
" The windows will get settings for a temporary buffer and can be closed
" with either 'q' or 'gq'.
function! s:show_in_window(content) abort
  if bufexists('pushhelp')
    " if the help buffer already exists, jump to it
    let l:winnr = bufwinnr('pushhelp')
    execute l:winnr . "wincmd w"
  else
    " otherwise create the help buffer
    execute len(a:content) + 1 . 'new'
    call append(0, a:content)
    setlocal syntax=help nomodifiable nomodified buftype=nofile bufhidden=wipe nowrap nonumber
    file pushhelp
    nnoremap <buffer> q  :close<cr>
    nnoremap <buffer> gq :close<cr>
  endif
endfunction


""
" Left-pad the given 'string' to the given 'length'.
function! s:pad(string, length) abort
  return a:string . repeat(' ', a:length - len(a:string))
endfunction



