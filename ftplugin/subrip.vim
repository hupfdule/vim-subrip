" Plugin folklore "{{{1
if v:version < 700 || exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
"}}}1

command! -buffer SrtRenumber call subrip#renumber()
command! -buffer -range=% SrtShift    <line1>,<line2>call subrip#shift()

nnoremap <buffer> <silent> <Plug>(SrtJumpToNextBlock) :call subrip#jump_to_next_block(v:false)<cr>
nnoremap <buffer> <silent> <Plug>(SrtJumpToPrevBlock) :call subrip#jump_to_next_block(v:true)<cr>
nnoremap <buffer> <silent> <Plug>(SrtShiftN)          :SrtShift<cr>
xnoremap <buffer> <silent> <Plug>(SrtShiftX)          :SrtShift<cr>

nmap     <buffer> <silent> ]]        <Plug>(SrtJumpToNextBlock)
nmap     <buffer> <silent> [[        <Plug>(SrtJumpToPrevBlock)
nmap     <buffer> <silent> <leader>S <Plug>(SrtShiftN)
xmap     <buffer> <silent> <leader>S <Plug>(SrtShiftX)

" Plugin folklore "{{{1
let &cpo = s:cpo_save
unlet s:cpo_save
"}}}1

" Vim Modeline " {{{2
" vim: set foldmethod=marker:
