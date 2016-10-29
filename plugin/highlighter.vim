" FILE: highlighter.vim
" AUTHOR: Keita Nakamura
" License: MIT license


if exists("g:loaded_highlighter")
  finish
endif
let g:loaded_highlighter = 1

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:highlighter#auto_update')
  let g:highlighter#auto_update = 0
endif


if g:highlighter#auto_update == 1
  augroup highlighter
    autocmd!
    autocmd BufWritePost * silent! HighlighterUpdate
  augroup END
elseif g:highlighter#auto_update == 2
  augroup highlighter
    autocmd!
    autocmd BufWritePost * silent! HighlighterUpdate
    autocmd BufReadPost * silent! HighlighterUpdate
  augroup END
endif


let &cpo = s:save_cpo
unlet s:save_cpo
