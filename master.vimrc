" master.vimrc file
" Maintainer:   Max Wang <mwang@fb.com>
" Last Change:  April 4, 2014
"
" Usage: There are a number of ways to reasonably make use of our master
" configs:
"
" 1/  Source this file; e.g., include the line
"
"   source $ADMIN_SCRIPTS/master.vimrc
"
" somewhere in your ~/.vimrc file (towards the top, probably, so that you can
" override any options you want to).  By default, this will include the
" scripts in the admin vim/ directory, but you can disable this (and
" ~everything else in this file) with config parameters, described below.
"
" Note that only scripts in the vim-recognized subdirectories of
" $ADMIN_SCRIPTS/vim will be recognized.  If you want to use the *.vim files
" in the toplevel $ADMIN_SCRIPTS/vim directory, you'll have to source them
" explicitly or link to them in your ~/.vim.
"
" 2/  Use vim-pathogen (https://github.com/tpope/vim-pathogen) to manage your
" configs, and add $ADMIN_SCRIPTS/vim as a bundle by running
"
"   ln -s $ADMIN_SCRIPTS/vim $HOME/.vim/bundle/fb-admin
"
" This is the recommended way of using the master configs if you don't
" particularly care for the environment set up here.  The stuff that is
" included with the bundle is fairly minimal, mostly syntax and plugin support
" for FB-developed languages and augments like XHP, Hack, and Thrift.
"
" 3/  Just source things you want manually, or link to them in your ~/.vim.
" If you want any of the miscellaneous utility scripts, you'll have to do this
" for them.
"
" If you're new to vim and you want ideas for setting up your environment,
" peek at the ~/.vimrc's of other engineers.  You can also look for ideas in
" the internal wiki page:
"
"     https://our.intern.facebook.com/intern/wiki/index.php/Vim
"
" or post in the internal vim FB group:
"
"     https://www.facebook.com/groups/vim/


set nocompatible

if $ADMIN_SCRIPTS == ""
  let $ADMIN_SCRIPTS = "/mnt/vol/engshare/admin/scripts"
endif

if $LOCAL_ADMIN_SCRIPTS == ""
  let $LOCAL_ADMIN_SCRIPTS = "/usr/facebook/ops/rc/"
endif


""""""""""""""""""""""""""""""""""""""""""
" Sources.
""""""""""""""""""""""""""""""""""""""""""

if !exists("g:fb_source_admin") | let g:fb_source_admin = 1 | endif

if g:fb_source_admin
  set runtimepath^=$LOCAL_ADMIN_SCRIPTS/vim
  set runtimepath+=$LOCAL_ADMIN_SCRIPTS/vim/after
endif


""""""""""""""""""""""""""""""""""""""""""
" Default options.
""""""""""""""""""""""""""""""""""""""""""

" Facebook indent style; override these explicitly to turn them off.
set shiftwidth=2    " two spaces per indent
set tabstop=2       " number of spaces per tab in display
set softtabstop=2   " number of spaces per tab when inserting
set expandtab       " substitute spaces for tabs

if !exists("g:fb_default_opts") | let g:fb_default_opts = 1 | endif

if g:fb_default_opts

  " Turn things on.  We need to run `filetype off` first because vim defaults
  " to `filetype on`, and unless we toggle it, our custom filetype detections
  " won't be run.
  filetype off
  filetype indent plugin on
  syntax enable

  " Display.
  set ruler           " show cursor position
  set nonumber        " hide line numbers
  set nolist          " hide tabs and EOL chars
  set showcmd         " show normal mode commands as they are entered
  set showmode        " show editing mode in status (-- INSERT --)
  set showmatch       " flash matching delimiters

  " Scrolling.
  set scrolljump=5    " scroll five lines at a time vertically
  set sidescroll=10   " minumum columns to scroll horizontally

  " Search.
  set nohlsearch      " don't persist search highlighting
  set incsearch       " search with typeahead

  " Indent.
  set autoindent      " carry indent over to new lines

  " Other.
  set noerrorbells      " no bells in terminal

  set backspace=indent,eol,start  " backspace over everything
  set tags=tags;/       " search up the directory tree for tags

  set undolevels=1000   " number of undos stored
  set viminfo='50,"50   " '=marks for x files, "=registers for x files

  set modelines=0       " modelines are bad for your health

endif


""""""""""""""""""""""""""""""""""""""""""
" Miscellaneous
""""""""""""""""""""""""""""""""""""""""""

" Kill any trailing whitespace on save.
if !exists("g:fb_kill_whitespace") | let g:fb_kill_whitespace = 1 | endif
if g:fb_kill_whitespace
  fu! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
  endfu
  au FileType c,cabal,cpp,haskell,javascript,php,python,ruby,readme,tex,text,thrift
    \ au BufWritePre <buffer>
    \ :call <SID>StripTrailingWhitespaces()
endif

" Automatically load svn-commit template.
if !exists("g:fb_svn_template") | let g:fb_svn_template = 1 | endif
if g:fb_svn_template
  if $SVN_COMMIT_TEMPLATE == ""
    let $SVN_COMMIT_TEMPLATE = "$ADMIN_SCRIPTS/templates/svn-commit-template.txt"
  endif
  autocmd BufNewFile,BufRead svn-commit.*tmp :0r $SVN_COMMIT_TEMPLATE
endif

" Error log, hzhao's nemo.
if !exists("g:fb_hzhao_nemo") | let g:fb_hzhao_nemo = 1 | endif
if g:fb_hzhao_nemo
  set errorformat+=%.%#PHP:\ %m\ \(in\ %f\ on\ line\ %l\)%.%#,
    \%E%[0-9]%#.%m:%f?rev=%.%##L%l\ %.%#,%C%.%#
endif
