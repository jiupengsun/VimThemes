" A function for executing BigGrep from within vim.
" To use it, put 'source ~admin/scripts/vim/biggrep.vim' in your .vimrc.
" Run ':TBGS some_string' to search for a string in www/trunk.
" Similar for TBGR, TBGF, FBGS, FBGR, FBGF, CBGS, CBGR, and CBGF.
" Bonus! [TFC]BGW will search for the word under the cursor.
"
" Of course, you can press enter on the results to jump to them.
" If pressing Enter in the quickfix list doesn't work for you, add this to your
" .vimrc:
"    au BufReadPost quickfix map <buffer> <Enter> :.cc<CR>
"
" This works only when your working directory is a descendant of the www,
" fbcode, configerator, or android roots.
"
" @author dreiss

function! BigGrep(corpus, query, search)
  let subst = ""

  " Attempts to reconcile a git vs mercurial repo by checking for errors
  let corpus_path = system('git rev-parse --show-cdup')
  if v:shell_error
    let corpus_path = system('hg root')
    let corpus_path = substitute(corpus_path, '\n$', '', '').'/'
  else
    let corpus_path = substitute(corpus_path, '\n$', '', '')
  endif

  " Detect if current repo is fbsource
  let fbsource = system('hg config grep.biggrepcorpus') =~ "fbsource"

  if a:corpus == "t"
    if fbsource
      let corpus_path = corpus_path . "www/"
    endif
    let subst = "s:^www/:".corpus_path.":"
  elseif a:corpus == "f"
    if fbsource
      let corpus_path = corpus_path . "fbcode/"
    endif
    let subst = "s:^fbsource/fbcode/:".corpus_path.":"
  elseif a:corpus == "a"
    if fbsource
      let corpus_path = corpus_path . "android/"
    endif
    let subst = "s:^android/:".corpus_path.":"
  elseif a:corpus == "c"
    let subst = "s:^configerator/:".corpus_path.":"
  elseif a:corpus == "o"
    let subst = "s:^opsfiles/:".corpus_path.":"
  elseif a:corpus == "ig"
    let subst = "s:^instagram/:".corpus_path.":"
  elseif a:corpus == "i"
    if fbsource
      let corpus_path = corpus_path . "fbobj/"
    endif
    let subst = "s:^fbobj/:".corpus_path.":"
  endif

  let old_grep = &grepprg
  let old_gfmt = &grepformat

  let &grepprg = a:corpus . "bg" . a:query . " $* \\| sed -e '".subst."'"

  " Default grep format for CentOS
  let &grepformat = "%f:%l:%c:%m,%f:%l:%c:"

  " OSX uses a different implementation of biggrep then dev servers, and on
  " OSX there is no column number in the output.
  " See: https://fb.workplace.com/groups/2096103163999420/permalink/2698225497120514/
  if system('uname -s') == "Darwin\n"
    let &grepformat = "%f:%l:%m"
  endif


  " The GNU Bourne-Again SHell has driven me to this.
  let search = substitute(a:search, "'", "'\"'\"'", "g")
  execute "silent grep! " . search
  copen
  execute "normal \<c-w>J"
  redraw!

  let &grepprg = old_grep
  let &grepformat = old_gfmt
endfunction

command! TBGW call BigGrep("t", "s", expand("<cword>"))
command! -nargs=1 TBGS call BigGrep("t","s",<q-args>)
command! -nargs=1 TBGR call BigGrep("t","r",<q-args>)
command! -nargs=1 TBGF call BigGrep("t","f",<q-args>)

command! FBGW call BigGrep("f", "s", expand("<cword>"))
command! -nargs=1 FBGS call BigGrep("f","s",<q-args>)
command! -nargs=1 FBGR call BigGrep("f","r",<q-args>)
command! -nargs=1 FBGF call BigGrep("f","f",<q-args>)

command! ABGW call BigGrep("a", "s", expand("<cword>"))
command! -nargs=1 ABGS call BigGrep("a","s",<q-args>)
command! -nargs=1 ABGR call BigGrep("a","r",<q-args>)
command! -nargs=1 ABGF call BigGrep("a","f",<q-args>)

" Configerator
command! CBGW call BigGrep("c", "s", expand("<cword>"))
command! -nargs=1 CBGS call BigGrep("c","s",<q-args>)
command! -nargs=1 CBGR call BigGrep("c","r",<q-args>)
command! -nargs=1 CBGF call BigGrep("c","f",<q-args>)

" Opsfiles
command! OBGW call BigGrep("o", "s", expand("<cword>"))
command! -nargs=1 OBGS call BigGrep("o","s",<q-args>)
command! -nargs=1 OBGR call BigGrep("o","r",<q-args>)
command! -nargs=1 OBGF call BigGrep("o","f",<q-args>)

" Instagram
command! IGBGW call BigGrep("ig", "s", expand("<cword>"))
command! -nargs=1 IGBGS call BigGrep("ig","s",<q-args>)
command! -nargs=1 IGBGR call BigGrep("ig","r",<q-args>)
command! -nargs=1 IGBGF call BigGrep("ig","f",<q-args>)

" fobjc
command! IBGW call BigGrep("i", "s", expand("<cword>"))
command! -nargs=1 IBGS call BigGrep("i","s",<q-args>)
command! -nargs=1 IBGR call BigGrep("i","r",<q-args>)
command! -nargs=1 IBGF call BigGrep("i","f",<q-args>)

" xplat
command! XPBGW call BigGrep("xp", "s", expand("<cword>"))
command! -nargs=1 XPBGS call BigGrep("xp","s",<q-args>)
command! -nargs=1 XPBGR call BigGrep("xp","r",<q-args>)
command! -nargs=1 XPBGF call BigGrep("xp","f",<q-args>)

" All repos
command! ZBGW call BigGrep("z", "s", expand("<cword>"))
command! -nargs=1 ZBGS call BigGrep("z","s",<q-args>)
command! -nargs=1 ZBGR call BigGrep("z","r",<q-args>)
command! -nargs=1 ZBGF call BigGrep("z","f",<q-args>)
