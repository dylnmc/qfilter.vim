
" check if current buffer is loclist
function! s:is_loclist() abort
	return getwininfo(win_getid())[0].loclist
endfunction

" get (q|loc)list
function! s:xgetlist(...) abort
	if s:is_loclist()
		return call('getloclist', extend([0], a:000))
	else
		return call('getqflist', a:000)
	endif
endfunction

" set (q|loc)list
function! s:xsetlist(...) abort
	if s:is_loclist()
		return call('setloclist', extend([0], a:000))
	else
		return call('setqflist', a:000)
	endif
endfunction

" modify title if (q|loc)list changed
function! s:settitle() abort
	let l:title = s:xgetlist({'title': 0}).title
	return l:title[-3:] ==# '[+]' ? l:title : (l:title . ' [+]')
endfunction

" quickfix deletion
" ~~~~~~~~~~~~~~~~~

" delete function for 'opfunc'
function! qf#delete(type) abort
	let l:start = -1
	let l:end = -1
	if a:type ==# 'char' || a:type ==# 'line'
		let l:start = line("'[")
		let l:end = line("']")
	elseif a:type ==# 'v' || a:type ==# 'V' || a:type ==# "\<c-v>"
		let l:start = line("'<")
		let l:end = line("'>")
	else
		let l:start = line("'[")
		let l:end = line("']")
	endif
	if l:start ==# -1 || l:end ==# -1 || l:end < l:start
		echohl ErrorMsg
		echon 'QF delete operator has invalid range: ('.l:start.','.l:end.')'
		echohl NONE
		return
	endif
	let l:lines = range(l:start, l:end)
	call s:xsetlist([], 'r', { 'items': filter(s:xgetlist(), { idx,_ -> index(l:lines, idx+1) ==# -1 }), title: s:settitle() })
endfunction


" quickfix reject
" ~~~~~~~~~~~~~~~

" Reject based on text (regex)
function! qf#reject(m) abort
	let l:m = a:m =~# '^\([^[:alnum:]]\).*\1$' ? substitute(a:m, '.\(.*\).', '\1', '') : a:m
	call s:xsetlist([], 'r', { 'items': filter(s:xgetlist(), { _,line -> line.text !~# l:m }), 'title': s:settitle() })
endfunction

" Reject based on bufname (literal)
function! qf#reject_files(m) abort
	let l:m = fnameescape(a:m =~# '^\([^[:alnum:]]\).*\1$' ? substitute(a:m, '.\(.*\).', '\1', '') : a:m)
	call s:xsetlist([], 'r', { 'items': filter(s:xgetlist(), { _,line -> stridx(bufname(line.bufnr), l:m) ==# -1 }), 'title': s:settitle() })
endfunction

" Reject based on text and bufname (both regex)
function! qf#reject_all(m) abort
	let l:m = a:m =~# '^\([^[:alnum:]]\).*\1$' ? substitute(a:m, '.\(.*\).', '\1', '') : a:m
	call s:xsetlist([], 'r', { 'items': filter(s:xgetlist(), { _,line -> line.text !~# l:m && bufname(line.bufnr) !~# l:m }), 'title': s:settitle() })
endfunction


" quickfix keep
" ~~~~~~~~~~~~~

" keep based on text (regex)
function! qf#keep(m) abort
	let l:m = a:m =~# '^\([^[:alnum:]]\).*\1$' ? substitute(a:m, '.\(.*\).', '\1', '') : a:m
	call s:xsetlist([], 'r', { 'items': filter(s:xgetlist(), { _,line -> line.text =~# l:m }), 'title': s:settitle() })
endfunction

" Keep based on bufname (literal)
function! qf#keep_files(m) abort
	let l:m = fnameescape(a:m =~# '^\([^[:alnum:]]\).*\1$' ? substitute(a:m, '.\(.*\).', '\1', '') : a:m)
	call s:xsetlist([], 'r', { 'items': filter(s:xgetlist(), { _,line -> stridx(bufname(line.bufnr), l:m) !=# -1 }), 'title': s:settitle() })
endfunction

" Keep based on text and bufname (both regex)
function! qf#keep_all(m) abort
	let l:m = a:m =~# '^\([^[:alnum:]]\).*\1$' ? substitute(a:m, '.\(.*\).', '\1', '') : a:m
	call s:xsetlist([], 'r', { 'items': filter(s:xgetlist(), { _,line -> line.text =~# l:m && bufname(line.bufnr) =~# l:m }), 'title': s:settitle() })
endfunction

