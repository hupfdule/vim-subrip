" Plugin folklore "{{{1
if v:version < 700 || exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
"}}}1

nnoremap <buffer> <silent> ]] :call subrip#jump_to_next_block(v:false)<cr>
nnoremap <buffer> <silent> [[ :call subrip#jump_to_next_block(v:true)<cr>

command -buffer SrtRenumber call subrip#renumber()

" Plugin folklore "{{{1
let &cpo = s:cpo_save
unlet s:cpo_save
"}}}1

" Vim Modeline " {{{2
" vim: set foldmethod=marker:
