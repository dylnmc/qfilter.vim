" qfilter.vim: filter results in qf window
" Author:	Dylan McClure <dylnmc@gmail.com>
" Date:		23 Aug 2019

" Check if current buffer is loclist
function! s:is_loclist() abort
	return getwininfo(win_getid())[0].loclist
endfunction

" Get (q|loc)list
function! s:xgetlist(...) abort
	if s:is_loclist()
		return call('getloclist', extend([0], a:000))
	else
		return call('getqflist', a:000)
	endif
endfunction

" Set (q|loc)list
function! s:xsetlist(...) abort
	if s:is_loclist()
		return call('setloclist', extend([0], a:000))
	else
		return call('setqflist', a:000)
	endif
endfunction

" modify title if (q|loc)list changed
function! s:gettitle() abort
	let l:title = s:xgetlist({'title': 0}).title
	return l:title[-3:] ==# '[+]' ? l:title : (l:title . ' [+]')
endfunction

" set new (q|loc)list only if items were removed
function! s:setnewitems(items) abort
	if len(a:items) ==# s:xgetlist({'size': 1}).size
		return 0
	endif
	return s:xsetlist([], 'r', { 'items': a:items, 'title': s:gettitle() })
endfunction


" Quickfix |d|eletion
" ~~~~~~~~~~~~~~~~~~~

" delete function for 'opfunc'
function! qfilter#delete(type) abort
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
	call s:xsetlist([], 'r', { 'items': filter(s:xgetlist(), { idx,_ -> index(l:lines, idx+1) ==# -1 }), title: s:gettitle() })
endfunction


" Quickfix :Reject
" ~~~~~~~~~~~~~~~~

" Reject based on text (regex)
function! qfilter#reject(m) abort
	let l:m = substitute(a:m, '^\([^[:alnum:]]\)\(.*\)\1$', '\2', '')
	let l:new = filter(s:xgetlist(), { _,line -> line.text !~# l:m })
	return s:setnewitems(l:new)
endfunction

" Reject based on bufname (literal)
function! qfilter#reject_files(m) abort
	let l:m = fnameescape(substitute(a:m, '^\([^[:alnum:]]\)\(.*\)\1$', '\2', ''))
	let l:new = filter(s:xgetlist(), { _,line -> stridx(bufname(line.bufnr), l:m) ==# -1 })
	return s:setnewitems(l:new)
endfunction

" Reject based on text and bufname (both regex)
function! qfilter#reject_all(m) abort
	let l:m = substitute(a:m, '^\([^[:alnum:]]\)\(.*\)\1$', '\2', '')
	let l:new = filter(s:xgetlist(), { _,line -> line.text !~# l:m && bufname(line.bufnr) !~# l:m })
	return s:setnewitems(l:new)
endfunction


" Quickfix :Keep
" ~~~~~~~~~~~~~~

" keep based on text (regex)
function! qfilter#keep(m) abort
	let l:m = a:m =~# '^\([^[:alnum:]]\).*\1$' ? substitute(a:m, '.\(.*\).', '\1', '') : a:m
	let l:new = filter(s:xgetlist(), { _,line -> line.text =~# l:m })
	return s:setnewitems(l:new)
endfunction

" Keep based on bufname (literal)
function! qfilter#keep_files(m) abort
	let l:m = fnameescape(substitute(a:m, '^\([^[:alnum:]]\)\(.*\)\1$', '\2', ''))
	let l:new = filter(s:xgetlist(), { _,line -> stridx(bufname(line.bufnr), l:m) !=# -1 })
	return s:setnewitems(l:new)
endfunction

" Keep based on text and bufname (both regex)
function! qfilter#keep_all(m) abort
	let l:m = a:m =~# '^\([^[:alnum:]]\).*\1$' ? substitute(a:m, '.\(.*\).', '\1', '') : a:m
	let l:new = filter(s:xgetlist(), { _,line -> line.text =~# l:m && bufname(line.bufnr) =~# l:m })
	return s:setnewitems(l:new)
endfunction


" File jump
" ~~~~~~~~~

" jump to next filename
function! qfilter#filejump(forward) abort
	if !a:forward
		let l:index = line('$') - line('.')
		let l:list = reverse(map(s:xgetlist(), { i,line -> extend(line, { 'index':i }) }))[l:index:]
	else
		let l:index = line('.') - 1
		let l:list = map(s:xgetlist(), { i,line -> extend(line, { 'index':i }) })[l:index:]
	endif
	let l:bufnr = l:list[0].bufnr
	let l:index = -1
	while !empty(l:list)
		let l:line = remove(l:list, 0)
		if l:line.valid && l:line.bufnr !=# l:bufnr
			let l:index = l:line.index
			break
		endif
	endwhile
	if l:index ==# -1
		return
	endif
	if !a:forward
		let l:bufnr = l:line.bufnr
		for l:line in l:list
			if !l:line.valid || l:line.bufnr !=# l:bufnr
				break
			endif
			let l:index = l:line.index
		endfor
	endif
	call setpos('.', [bufnr(''), l:index+1, 1, 0, 1])
endfunction


" Clean up
" ~~~~~~~~

function! qfilter#cleanup()
	silent! delcommand Reject
	silent! delcommand RejectFiles
	silent! delcommand RejectAll
	silent! delcommand Keep
	silent! delcommand KeepFiles
	silent! delcommand KeepAll
	if !get(b:, 'did_add_maps')
		return
	endif
	silent! nunmap <buffer> d
	silent! xunmap <buffer> d
	silent! nunmap <buffer> dd
	silent! nunmap {
	silent! nunmap }
endfunction

