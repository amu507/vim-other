let g:g_selectcmd={
\'insert num'	:'%s/^/\=line(".") . "."/gc',
\'insert line'	:'%s/$/\="\n"/gc',
\'del duplicate':'g/^/m0|g/^\(.*\)\ze\n\%(.*\n\)*\1$/d|g/^/m0',
\}

nnoremap <Leader>sc :call SelectCmd()<cr>
function! SelectCmd()
	let lstTmp=["select"]
	let lstKey=keys(g:g_selectcmd)
	for i in range(0,len(lstKey)-1)
		call add(lstTmp, lstKey[i] . "---->" . (i+1))
	endfor
	let iFile=inputlist(lstTmp)
	if iFile==#0
		return
	endif
	for c in split(g:g_selectcmd[lstKey[iFile-1]],'|')
		execute(c)
	endfor
endfunction

