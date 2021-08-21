" isort-vim-2.vim
" Author: David Szotten
" Requires: Vim Ver7.0+
" Version:  1.0
"
" Documentation:
"   This plugin formats Python imports.
"
" History:
"  1.0:
"    - initial version

if v:version < 700 || !has('python3')
    func! __UNSUPPORTED()
        echo "The isort-vim-2.vim plugin requires vim7.0+ with Python 3.6 support."
    endfunc
    command! Isort :call __UNSUPPORTED()
    command! IsortUpgrade :call __UNSUPPORTED()
    command! IsortVersion :call __UNSUPPORTED()
    finish
endif

if exists("g:load_isort")
  finish
endif

let g:load_isort = "py1.0"
if !exists("g:isort_virtualenv")
  if has("nvim")
    let g:isort_virtualenv = "~/.local/share/nvim/isort"
  else
    let g:isort_virtualenv = "~/.vim/isort"
  endif
endif
if !exists("g:isort_quiet")
  let g:isort_quiet = 0
endif


command! Isort :call isort#Isort()
command! IsortUpgrade :call isort#IsortUpgrade()
command! IsortVersion :call isort#IsortVersion()
