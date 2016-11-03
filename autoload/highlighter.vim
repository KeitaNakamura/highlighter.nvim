" FILE: highlighter.vim
" AUTHOR: Keita Nakamura
" License: MIT license


if !exists('g:loaded_highlighter')
  runtime! plugin/highlighter.vim
endif

let s:save_cpo = &cpo
set cpo&vim

" Global variables {{{1
let g:highlighter#default_syntax_prefix = '\C\<'
let g:highlighter#default_syntax_suffix = '\>'
if !exists('g:highlighter#disabled_languages')
  let g:highlighter#disabled_languages = []
endif
if !exists('g:highlighter#syntax')
  let g:highlighter#syntax = {}
endif
if !exists('g:highlighter#project_root_signs')
  let g:highlighter#project_root_signs = []
endif
if !exists('g:highlighter#ctags_options')
  let path = expand('<sfile>:p:h')
  let g:highlighter#ctags_options = ['--options='.path.'/ctags_options_file']
endif
" }}}
" Functions for highlighting syntax {{{1
function! highlighter#update_highlight(object) " {{{2
  let commands = a:object[0]
  let root = a:object[1]
  let filetype = a:object[2]
  let currwin=winnr()
  for w in s:get_windows(root, filetype)
    execute w.'windo '.commands
  endfor
  execute currwin.'wincmd w'
endfunction
" }}}
function! s:get_windows(project_root, filetype) " {{{2
  let list = []
  for b in range(1, bufnr('$'))
    let ft = getbufvar(b, '&filetype')
    let path = expand("#".b.":p")
    if ft ==# a:filetype && match(path, a:project_root) == 0 && bufwinnr(b) != -1
      call add(list, bufwinnr(b))
    endif
  endfor
  return list
endfunction
" }}}
" }}}
" Functions for defining syntax {{{1
function! highlighter#initialize() abort " {{{2
  let userdefs = filter(copy(g:), 'v:key =~ "^highlighter#syntax_"')
  for [key, val] in items(userdefs)
    let type = substitute(key, '^highlighter#syntax_', '', '')
    let g:highlighter#syntax[type] = s:init_syntax(val)
  endfor
endfunction
" }}}
function! s:init_syntax(objects) " {{{2
  for obj in a:objects
    if has_key(obj, 'hlgroup_link') && !hlexists(obj['hlgroup'])
      exec "hi def link " . join([obj['hlgroup'], obj['hlgroup_link']])
    endif
    if !has_key(obj, 'syntax_prefix')
      let obj['syntax_prefix'] = g:highlighter#default_syntax_prefix
    endif
    if !has_key(obj, 'syntax_suffix')
      let obj['syntax_suffix'] = g:highlighter#default_syntax_suffix
    endif
    if !has_key(obj, 'syntax_type')
      let obj['syntax_type'] = 'keyword'
    endif
    if !has_key(obj, 'syntax_ignore')
      let obj['syntax_ignore'] = s:syntax_groups_to_ignore()
    endif
  endfor
  return a:objects
endfunction
" }}}
function! s:syntax_groups_to_ignore() " {{{2
  " NOTE: This function is copied from https://github.com/xolox/vim-easytags/blob/72a8753b5d0a951e547c51b13633f680a95b5483/autoload/xolox/easytags.vim
  "
  " Get a string matching the syntax groups where dynamic highlighting should
  " *not* apply. This is complicated by the fact that Vim has a tendency to do
  " this:
  "
  "     Vim(syntax):E409: Unknown group name: doxygen.*
  "
  " This happens when a group wildcard doesn't match *anything*. Why does Vim
  " always have to make everything so complicated? :-(
  let groups = ['.*String.*', '.*Comment.*']
  for group_name in ['cIncluded', 'cCppOut2', 'cCppInElse2', 'cCppOutIf2', 'pythonDocTest', 'pythonDocTest2']
    if hlexists(group_name)
      call add(groups, group_name)
    endif
  endfor
  " Doxygen is an "add-on syntax script", it's usually used in combination:
  "   :set syntax=c.doxygen
  " It gets special treatment because it defines a dozen or so groups :-)
  if hlexists('doxygenComment')
    call add(groups, 'doxygen.*')
  endif
  return join(groups, ',')
endfunction

" }}}
" Setting for each language {{{1
" Lua {{{2
if !exists('g:highlighter#syntax_lua')
  let g:highlighter#syntax_lua = [
        \ { 'hlgroup'       : 'HighlighterLuaFunction',
        \   'hlgroup_link'  : 'Function',
        \   'tagkinds'      : 'f',
        \   'syntax_type'   : 'keyword',
        \ }]
endif
" }}}
" C {{{2
if !exists('g:highlighter#syntax_c')
  let g:highlighter#syntax_c = [
        \ { 'hlgroup'       : 'HighlighterCType',
        \   'hlgroup_link'  : 'Type',
        \   'tagkinds'      : 'cgstu',
        \ },
        \ { 'hlgroup'       : 'HighlighterCEnum',
        \   'hlgroup_link'  : 'Identifier',
        \   'tagkinds'      : 'e',
        \ },
        \ { 'hlgroup'       : 'HighlighterCPreProc',
        \   'hlgroup_link'  : 'Identifier',
        \   'tagkinds'      : 'd',
        \ },
        \ { 'hlgroup'       : 'HighlighterCMember',
        \   'hlgroup_link'  : 'Identifier',
        \   'tagkinds'      : 'm',
        \ },
        \ { 'hlgroup'       : 'HighlighterCFunction',
        \   'hlgroup_link'  : 'Function',
        \   'tagkinds'      : 'fp',
        \   'syntax_type'   : 'match',
        \   'syntax_suffix' : '(\@=',
        \ }]
endif
" }}}
" C++ {{{2
if !exists('g:highlighter#syntax_cpp')
  let g:highlighter#syntax_cpp = [
        \ { 'hlgroup'       : 'HighlighterCppType',
        \   'hlgroup_link'  : 'Function',
        \   'tagkinds'      : 'cgstu',
        \ },
        \ { 'hlgroup'       : 'HighlighterCppEnum',
        \   'hlgroup_link'  : 'Identifier',
        \   'tagkinds'      : 'e',
        \ },
        \ { 'hlgroup'       : 'HighlighterCppPreProc',
        \   'hlgroup_link'  : 'Identifier',
        \   'tagkinds'      : 'd',
        \ },
        \ { 'hlgroup'       : 'HighlighterCppMember',
        \   'hlgroup_link'  : 'Identifier',
        \   'tagkinds'      : 'm',
        \ },
        \ { 'hlgroup'       : 'HighlighterCppFunction',
        \   'hlgroup_link'  : 'Function',
        \   'tagkinds'      : 'fp',
        \   'syntax_type'   : 'match',
        \   'syntax_suffix' : '(\@=',
        \ }]
endif
" }}}
" PHP {{{2
if !exists('g:highlighter#syntax_php')
  let g:highlighter#syntax_php = [
        \ { 'hlgroup'       : 'HighlighterPhpFunction',
        \   'hlgroup_link'  : 'Function',
        \   'tagkinds'      : 'f',
        \   'syntax_type'   : 'match',
        \   'syntax_suffix' : '(\@=',
        \ },
        \ { 'hlgroup'       : 'HighlighterPhpClass',
        \   'hlgroup_link'  : 'Function',
        \   'tagkinds'      : 'c',
        \ }]
endif
" }}}
" Python {{{2
if !exists('g:highlighter#syntax_python')
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
endif
" }}}
" Java {{{2
if !exists('g:highlighter#syntax_java')
  let g:highlighter#syntax_java = [
        \ { 'hlgroup'       : 'HighlighterJavaClass',
        \   'hlgroup_link'  : 'Identifier',
        \   'tagkinds'      : 'c',
        \ },
        \ { 'hlgroup'       : 'HighlighterJavaInterface',
        \   'hlgroup_link'  : 'Identifier',
        \   'tagkinds'      : 'i',
        \ },
        \ { 'hlgroup'       : 'HighlighterJavaMethod',
        \   'hlgroup_link'  : 'Function',
        \   'tagkinds'      : 'm',
        \ }]
endif
" }}}
" C# {{{2
if !exists('g:highlighter#syntax_cs')
  let g:highlighter#syntax_cs = [
        \ { 'hlgroup'       : 'HighlighterCsClass',
        \   'hlgroup_link'  : 'Identifier',
        \   'tagkinds'      : 'c',
        \ },
        \ { 'hlgroup'       : 'HighlighterCsMethod',
        \   'hlgroup_link'  : 'Function',
        \   'tagkinds'      : 'ms',
        \ }]
endif
" }}}
" Ruby {{{2
if !exists('g:highlighter#syntax_ruby')
  let g:highlighter#syntax_ruby = [
        \ { 'hlgroup'       : 'HighlighterRubyModule',
        \   'hlgroup_link'  : 'Type',
        \   'tagkinds'      : 'm',
        \ },
        \ { 'hlgroup'       : 'HighlighterRubyClass',
        \   'hlgroup_link'  : 'Type',
        \   'tagkinds'      : 'c',
        \ },
        \ { 'hlgroup'       : 'HighlighterRubyMethod',
        \   'hlgroup_link'  : 'Function',
        \   'tagkinds'      : 'fF',
        \ }]
endif
" }}}
" Perl {{{2
if !exists('g:highlighter#syntax_perl')
  let g:highlighter#syntax_perl = [
        \ { 'hlgroup'       : 'HighlighterPerlFunction',
        \   'hlgroup_link'  : 'Operator',
        \   'tagkinds'      : 's',
        \   'syntax_prefix' : '\%(\<sub\s\+\)\@<!\%(>\|\s\|&\|^\)\@<=\<',
        \ }]
endif
" }}}
" Julia {{{2
if !exists('g:highlighter#syntax_julia')
  let g:highlighter#syntax_julia = [
        \ { 'hlgroup'       : 'HighlighterJuliaFunction',
        \   'hlgroup_link'  : 'Function',
        \   'tagkinds'      : 'f',
        \   'syntax_type'   : 'match',
        \   'syntax_suffix' : '[(|{]\@=',
        \ },
        \ { 'hlgroup'       : 'HighlighterJuliaType',
        \   'hlgroup_link'  : 'Type',
        \   'tagkinds'      : 't',
        \   'syntax_type'   : 'keyword',
        \ }]
endif
" }}}
" }}}

function! highlighter#echo(object)
  echo a:object
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
