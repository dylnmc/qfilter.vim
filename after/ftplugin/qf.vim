
" delete quickfix with d + motion
nnoremap <buffer> <silent> d :set opfunc=qf#delete<cr>g@
xnoremap <buffer> <silent> d :<c-u>call qf#delete(visualmode())<cr>
nmap <buffer> dd Vd

" :Reject pattern
command -buffer -nargs=1 Reject      call qf#reject(<f-args>)
command -buffer -nargs=1 RejectFiles call qf#reject_files(<f-args>)
command -buffer -nargs=1 RejectAll   call qf#reject_all(<f-args>)

" :Keep pattern
command -buffer -nargs=1 Keep      call qf#keep(<f-args>)
command -buffer -nargs=1 KeepFiles call qf#keep_files(<f-args>)
command -buffer -nargs=1 KeepAll   call qf#keep_all(<f-args>)

