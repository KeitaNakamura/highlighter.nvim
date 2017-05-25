# highlighter.nvim

Highlighter is an asynchronous syntax highlight engine (using ctags) for Neovim.

## Features

* The highlighter plug-in is based on [Exuberant Ctags](http://ctags.sourceforge.net) that generates an index (or tag) file of language objects found in source files. This means that the highlighter is available for all of languages supported by ctags.

* Tag data and syntax commands (for vim) are generated asynchronously by using [python-client](https://github.com/neovim/python-client).

<img src="https://github.com/KeitaNakamura/highlighter.nvim/blob/master/demo.gif" width="700">

## Reguirements

* Neovim with if_python3.
* [Exuberant Ctags](http://ctags.sourceforge.net).

## Installation

For vim-plug
```vim
Plug 'KeitaNakamura/highlighter.nvim', { 'do': ':UpdateRemotePlugins' }
```

## Usage

You can update the syntax highlight by using `:HighlighterUpdate` command.

## Options

### Languages that you want to disable syntax highlight
example:
```vim
let g:highlighter#disabled_languages = ['c', 'cpp'] " set `filetype`s
```

### Automatic syntax highlight
```vim
let g:highlighter#auto_update = 0 " 0: disable (default), 1: after saving the file, 2: after saving and opening the file
```

### Project root directory sign
Syntax highlight is updated only in the current file by default. If you add `g:highlighter#project_root_signs` option, the highlighter set a directory having a root sign as project root, and all of your project files (same language) will be updated.
example:
```vim
let g:highlighter#project_root_signs = ['.git']
```

### Customization
example:
```vim
let g:highlighter#syntax_python = [
      \ { 'hlgroup'       : 'HighlighterPythonFunction',
      \   'hlgroup_link'  : 'Function',
      \   'tagkinds'      : 'f',
      \   'syntax_type'   : 'match',
      \   'syntax_suffix' : '(\@=',
      \ },
      \ { 'hlgroup'       : 'HighlighterPythonMethod',
      \   'hlgroup_link'  : 'Function',
      \   'tagkinds'      : 'm',
      \   'syntax_type'   : 'match',
      \   'syntax_prefix' : '\.\@<=',
      \ },
      \ { 'hlgroup'       : 'HighlighterPythonClass',
      \   'hlgroup_link'  : 'Type',
      \   'tagkinds'      : 'c',
      \ }]
```
* `hlgroup`: Highlight group (required)
* `hlgroup_link`: If it is set, `highlight link` command will be executed.
* `tagkinds`: See `ctags --help` in terminal for details. (required)
* `syntax_type`: `keyword` (default) or `match`. See `:h syn_keyword` and `:h syn_match` for details.
* `syntax_prefix`: This is used only for `match` syntax type.
* `syntax_suffix`: This is used only for `match` syntax type.

I added above customizations for following languages, referring to [xolox/vim-easytags](https://github.com/xolox/vim-easytags).
* Lua
* C
* C++
* PHP
* Python
* Java
* C#
* Ruby
* Perl
* Julia

Please see 'Setting for each language' section in `autoload/highlighter.vim` for details.
