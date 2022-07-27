vim-subrip
==========

Introduction
------------

vim-subrip is an ftplugin for subrip subtitle files (usually with the `.srt`
extension).

It provides syntax highlighting as well as some commands and mappings for
handling such files.


Commands
--------

The following commands are available in a "subrip" buffer.

 - `:SrtRenumber`

   Renumber all the counters in the file.
   This is necessary after adding or removing subtitle blocks.

 - `:[range]SrtShift [ms]`<a name="srtshift-command"></a>

   Shift the timecodes in the whole file or (if given) in the specified
   range by a certain amount of milliseconds.
   If the argument [ms] is given, the timecodes will be shifted by that
   amount. Otherwise the plugin will prompt for the amount of milliseconds
   to shift.


Mappings
--------

The following navigational mappings are available in normal mode:

 - `<Plug>(SrtJumpToNextBlock)`  
  `<Plug>(SrtJumpToPrevBlock)`

   Move the cursor to the next or previous block, respectively.
   The cursor will be put in the first column of the timecode line.

   The mappings try to jump "intelligently". They take the element at the
   cursor position into account. That means if the cursor is on a timecode
   element they will jump to the timecode element in the next / previous
   subtitle block.

The following mappings are available in normal, visual, select and
insert mode:

 - `<Plug>(SrtShift)`

   Shift the timecodes in the whole file or the selected range by a certain
   amount of milliseconds. In insert mode only the timecodes in the current
   line are changed.

   These mappings call the [:SrtShift](#srtshift-command) command, but will
   always request the amount to shift from the user.

 - `<Plug>(SrtHelp)`

   Open a help window displaying the current key mappings and settings
   of push.vim

   This mapping is only available if [vimpl/vim-pluginhelp] is installed.

   If [skywind3000/vim-quickui] is available the help content will be
   shown in a popup dialog. Otherwise a normal split window will be
   used.
   The split window can be closed with either `q` or `gq`.

### Default mappings

|             |                              |
|-------------|------------------------------|
| `]]`        | `<Plug>(SrtJumpToNextBlock)` |
| `[[`        | `<Plug>(SrtJumpToPrevBlock)` |
| `<Leader>S` | `<Plug>(SrtShift)`           |
| `g?`        | `<Plug>(SrtHelp)`            |


Settings
--------

vim-subrip doesn't provide its own settings.

But it allows concealing the markup in the subtitle captions. To actually
apply such concealing set `conceallevel` to 2.


Complementary Plugins
---------------------

 - [vimpl/vim-pluginhelp]

    To display the help window, vim-pluginhelp needs to be installed.

 - [skywind3000/vim-quickui]

    To display the help window in a floating window, vim-quickui needs to be
    installed.


License
-------

This plugin is licensed under the terms of the MIT License.

http://opensource.org/licenses/MIT

[vimpl/vim-pluginhelp]: https://github.com/vimpl/vim-pluginhelp
[skywind3000/vim-quickui]: https://github.com/skywind3000/vim-quickui
