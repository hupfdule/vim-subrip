if exists('g:loaded_pluginhelp')
 let plugin_spec = {
     \ 'help_topic': 'subrip',
     \ 'mappings':  [
     \    {'plugmap': '<Plug>(SrtJumpToNextBlock)', 'desc': 'Move cursor to next subtitle block'},
     \    {'plugmap': '<Plug>(SrtJumpToPrevBlock)', 'desc': 'Move cursor to previous subtitle block'},
     \    {'plugmap': '<Plug>(SrtShift)',           'desc': 'Shift timecodes by a certain amount'},
     \    {'plugmap': '<Plug>(SrtHelp)',            'desc': 'Show this short help'},
     \  ],
     \ }
  nnoremap <buffer> <silent> <Plug>(SrtHelp)    :call pluginhelp#show(plugin_spec)<cr>
  nmap     <buffer> <silent> g?                 <Plug>(SrtHelp)
endif
