# -*- coding: utf-8 -*-
from vimenv import env
import saveable

BUFMGR_FILE=env.var("g:g_DataPath")+"\\bufmgr"

class CBufMgr(saveable.CSave):

    def __init__(self,sFile):
        saveable.CSave.__init__(self,sFile)
        self.m_Buffer={}#{id:file}
        self.m_TabBuf={}#{tab:bufset}
        self.ReadData()

    def BufAdd(self,iTab,iBuf,sBuf):
        if not iTab or not iBuf or not sBuf:
            return
        self.m_Buffer[iBuf]=sBuf
        bufset=self.m_TabBuf.get(iTab,set())
        bufset.add(iBuf)
        self.m_TabBuf[iTab]=bufset

    def BufDel(self,iBuf):
        if iBuf in self.m_Buffer:
            del self.m_Buffer[iBuf]
        for _,bufset in self.m_TabBuf.items():
            if iBuf in bufset:
                bufset.remove(iBuf)

    def ClearTabBufs(self,iTab):
        if not iTab in self.m_TabBuf:
            return
        del self.m_TabBuf[iTab]
	
    def GetNoUseBufs(self):
		allset=set(self.m_Buffer)
		tabset=set()
		for tmpset in self.m_TabBuf.values():
			tabset=tabset.union(tmpset)
		nouseset=allset-tabset
		return list(nouseset)

    def ChangeTabNum(self,lstTabNum):
        dOld=self.m_TabBuf.copy()
        self.m_TabBuf.clear()
        for iTab,iNum in enumerate(lstTabNum):
            iTab+=1
            self.m_TabBuf[iTab]=dOld.get(iNum,set())

    def TabBufs(self,iTab):
        iTab=int(iTab)
        if not iTab in self.m_TabBuf:
            return []
        return list(self.m_TabBuf[iTab])

    def Load(self,dData):
        if not dData:
            return
        dBuf=dData.get("buf",{})
        dTabBuf=dData.get("tabbuf",{})
        for iTab,bufset in dTabBuf.iteritems():
            for iBuf in bufset:
                sBuf=dBuf[iBuf]
                if env.var("bufloaded('%s')"%sBuf):
                    iBuf=int(env.var("bufnr('%s')"%sBuf))
                    self.BufAdd(iTab,iBuf,sBuf)

    def Save(self):
        return {"buf":self.m_Buffer,"tabbuf":self.m_TabBuf}

if not globals().has_key("g_BufMgr"):
    g_BufMgr=None

def CreateBufMgr():
    global g_BufMgr
    g_BufMgr=CBufMgr(BUFMGR_FILE)


