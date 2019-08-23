" QuickFix filetype plugin
" Language:	qf
" Author:	Dylan McClure <dylnmc@gmail.com>
" Date:		23 Aug 2019

" Only do this when not done yet for this buffer
if get(b:, 'did_ftplugin', 0) ==# 42
	finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 42

if get(b:, 'no_plugin_maps')
	finish
endif

" Delete quickfix with d + motion
nnoremap <buffer> <silent> d :set opfunc=qfilter#delete<cr>g@
xnoremap <buffer> <silent> d :<c-u>call qfilter#delete(visualmode())<cr>
nmap <buffer> dd Vd

" :Reject pattern
command -buffer -nargs=1 Reject      call qfilter#reject(<f-args>)
command -buffer -nargs=1 RejectFiles call qfilter#reject_files(<f-args>)
command -buffer -nargs=1 RejectAll   call qfilter#reject_all(<f-args>)

" :Keep pattern
command -buffer -nargs=1 Keep      call qfilter#keep(<f-args>)
command -buffer -nargs=1 KeepFiles call qfilter#keep_files(<f-args>)
command -buffer -nargs=1 KeepAll   call qfilter#keep_all(<f-args>)

" let cleanup function know that maps added
let b:did_add_maps = 1

let b:undo_ftplugin = { s -> s.(empty(s) ? '' : '|').'call qfilter#cleanup()' }(get(b:, 'undo_ftplugin', ''))

