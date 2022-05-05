" pyre.vim - Python typechecker integration for vim
" Language:  Python
" Copyright: (c) 2014, Facebook Inc.  All rights reserved.

if !exists('g:pyre#pyre')
  let g:pyre#pyre = 'pyre'
endif

" The %-G part is used to ignore noisy pyre logging outputs like the below. I
" wish there were a way pyre can silence them, but not as far as I can find.
"   || ƛ Fetching GKs...
"   || ƛ  Repopulating the environment...
let s:pyre_errorformat = '%f:%l:%c %m,%-G%.%#'

function! pyre#typecheck()
  if !executable(g:pyre#pyre)
    echom 'WARNING: unable to find pyre binary `' . g:pyre#pyre . '`'
  endif

  " We strip the trailing newline to avoid an empty error. We also concatenate
  " with the empty string because otherwise cgetexpr complains about not
  " having a String argument, even though type(hh_result) == 1.
  let result = system(g:pyre#pyre)[:-2].''

  let old_format = &errorformat
  let &errorformat = s:pyre_errorformat

  cgetexpr result
  botright copen

  let &errorformat = old_format
endfunction

" Commands and auto-typecheck.
command! PyreTypeCheck call pyre#typecheck()


" Integrate with neomake (https://github.com/neomake/neomake)
" Usage: 
"   pyre should be automatically run when editing python files. Errors are
"   reported in the sign (gutter) column. Also they are reported in the
"   location list ('lope').
"
"   To manually trigger pyre, use ':Neomake! pyre'
let g:neomake_python_pyre_maker = {
    \ 'exe': 'pyre',
    \ 'cwd': '%:p:h',
    \ 'append_file': 0,
    \ 'errorformat': s:pyre_errorformat,
    \ }

fun s:ft_enable(ftype) abort
    if exists(':Neomake')
        exec 'let makers = ' . 'neomake#GetEnabledMakers("' . a:ftype . '")'
        let makers = map(makers, {_, m -> m['name']})
        let makers += ['pyre']

        let runnable_makers = []
        for maker_name in makers
            let maker = neomake#GetMaker(maker_name)
            if executable(maker.exe)
                let runnable_makers += [maker.name]
            endif
        endfor

        let varname = 'b:neomake_'.a:ftype.'_enabled_makers'
        let str = 'let ' . varname . ' = ' . string(runnable_makers)
        exec str
    endif
endfunc

augroup pyre
    au!
    au Filetype python call s:ft_enable('python')
augroup END
