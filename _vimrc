source $LOCAL_ADMIN_SCRIPTS/master.vimrc
source $LOCAL_ADMIN_SCRIPTS/vim/pyre.vim
source $LOCAL_ADMIN_SCRIPTS/vim/toggle_comment.vim
source $LOCAL_ADMIN_SCRIPTS/vim/biggrep.vim
set number
set tags=tags;/

" for c++: fold #includes and namespaces
""""""""""""""""""""""""""""""""""""""""
function! Fold_Includes(ln)
  let cur_line = getline(a:ln)
  let prev_line = getline(a:ln - 1)

  " skip empty lines
  let empty_regex = '^\s*$'
  if cur_line =~ empty_regex
    return -1
  endif

  if cur_line[:8] == '#include '
    return (prev_line[:8] == '#include ' ||
          \ prev_line =~ empty_regex) ? 1 : '>1'
  endif

  if cur_line[:9] == 'namespace '
    return prev_line[:9] == 'namespace ' ? 1 : '>1'
  endif

  let end_ns_regex = '^}}*\s*//\s*namespace'
  if cur_line =~ end_ns_regex
    return prev_line =~ end_ns_regex ? 1 : '>1'
  endif

  return 0
endfunction

au FileType c,cpp setlocal foldexpr=Fold_Includes(v:lnum) foldmethod=expr
""""""""""""""""""""""""""""""""""""""""

set t_Co=256
execute pathogen#infect()
syntax enable
set background=dark
colorscheme solarized

" Format targets on save
autocmd BufWritePost TARGETS silent! exec \ '!~/fbsource/tools/third-party/buildifier/run_buildifier.py -i %' | :e

" fzf or myc depending on dir
if getcwd() =~ '/fbsource/fbcode$'
  nnoremap <leader>a :Fbgs<Space>
  nnoremap <C-p> :MYC<CR>
elseif getcwd() =~ '/configerator'
  nnoremap <leader>a :CBGS<Space>
  nnoremap <C-p> :Files<CR>
else
  nnoremap <Leader>a :Rg<CR>
  nnoremap <C-p> :Files<CR>
endif

nnoremap <leader>l :exec '!arc lint -a %'<cr>

" WHEN EDITING A TARGETS FILE, USE gf TO GO TO TARGETS FILE UNDER CURSOR#
autocmd BufNewFile,BufRead TARGETS setlocal includeexpr=substitute(v:fname,'//\\(.*\\)','\\1/TARGETS','g')
