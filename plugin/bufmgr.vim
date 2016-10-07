augroup bufmgr 
    autocmd!
    autocmd BufDelete      *        call OnBufDel()
    autocmd BufRead * call OnBufAdd("read") 
    autocmd BufNewFile * call OnBufAdd("new") 
    autocmd BufEnter * call OnBufAdd("enter") 
    autocmd TabEnter * call OnTabEnter("enter") 
augroup END

function! ClearTabBufs(...)
python << EOF
import bufmgr 
from vimenv import env
if bufmgr.g_BufMgr:
    iTab=int(env.var("tabpagenr()"))
    print "cleartab%s"%iTab
    bufmgr.g_BufMgr.ClearTabBufs(iTab)
    env.exe("MBEup")
EOF
endfunction

function! OnBufAdd(...)
python << EOF
import bufmgr 
from vimenv import env
if bufmgr.g_BufMgr:
    iBuf=int(env.var("expand('<abuf>')"))
    sBuf=env.var("bufname(%s)"%(iBuf))
    iTab=int(env.var("tabpagenr()"))
    if sBuf:
        sBuf=env.var("fnamemodify('%s',':p')"%sBuf)
    bufmgr.g_BufMgr.BufAdd(iTab,iBuf,sBuf)
    #    print env.var("a:000"),iTab,iBuf,sBuf,env.var("bufnr('%')")
EOF
endfunction

function! OnTabEnter(...)
    MBEup
    let lstTabNum=[]
    for iTab in range(1,tabpagenr('$')) 
        let iNum=gettabvar(iTab,"num")
        if iNum==#""
            call add(lstTabNum,iTab)
            call settabvar(iTab,"num",iTab)
        elseif iNum!=#iTab
            call add(lstTabNum,iNum)
            call settabvar(iTab,"num",iTab)
        else
            call add(lstTabNum,iNum)
        endif
    endfor
python << EOF
import bufmgr 
from vimenv import env
if bufmgr.g_BufMgr:
    lstTabNum=env.var("lstTabNum")
    lstTabNum=[int(i) for i in lstTabNum]#var get strlist
    bufmgr.g_BufMgr.ChangeTabNum(lstTabNum)
EOF
endfunction

function! OnBufDel()
python << EOF
import bufmgr 
from vimenv import env
if bufmgr.g_BufMgr:
    iBuf=int(env.var("expand('<abuf>')"))
    bufmgr.g_BufMgr.BufDel(iBuf)
EOF
endfunction

function! SaveBufMgr(...)
python << EOF
import bufmgr 
bufmgr.g_BufMgr.WriteData()
EOF
endfunction

function! CreateBufMgr(...)
python << EOF
import bufmgr 
bufmgr.CreateBufMgr()
EOF
for iTab in range(1,tabpagenr('$'))
    call settabvar(iTab,"num",iTab)
endfor
endfunction

function! GetTabBufs(...)
python << EOF
import bufmgr 
lstArgs=env.var("a:000")
if not lstArgs:
    lstArgs=[env.var("tabpagenr()")]
lstBuf=[]
if bufmgr.g_BufMgr:
    lstBuf=bufmgr.g_BufMgr.TabBufs(*lstArgs)
env.exe("let l:lstRet=%s"%(str(lstBuf)))
EOF
return l:lstRet
endfunction

function! OnlyTabBuff(...)
	let iCurBuf=bufnr("%")
	let lstBuf=GetTabBufs()
	for iNum in lstBuf
		if iNum!=#iCurBuf && BufModifiable(iNum)==#1
			execute(iNum . "bd")
		endif
	endfor
endfunction

function! ClearNoUseBuff(...)
	let l:lstRet=[]
python << EOF
import bufmgr 
lstBuf=[]
if bufmgr.g_BufMgr:
	lstBuf=bufmgr.g_BufMgr.GetNoUseBufs()
env.exe("let l:lstRet=%s"%(str(lstBuf)))
EOF
	for iBuf in l:lstRet
		silent! execute(iBuf . "bd")
	endfor
endfunction

