if exists("current_compiler")
	finish
endif

let current_compiler = "buck"

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=buck
CompilerSet errorformat=\%E%f:%l:%c:\ error:\ %m,
			\%W%f:%l:%c:\ warning:\ %m,
			\%I%f:%l:%c:\ note:\ %m,
			\%\\e

let &cpo = s:cpo_save
unlet s:cpo_save
