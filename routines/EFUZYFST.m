EFUZYFST ; tests for EFUZYFS
 ;
 Q
 ;
START
 D T001
 D T002
 D T003
 D T004
 Q
 ;
T001 ; root and folder defaults
 N CONF
 D RESET^EFUZYTESTU("")
 D EQ^MIOTASSERT($$ROOT^EFUZYFS(.CONF),"tmp/efuzy","[T001][default root]")
 S CONF("efuzy","rootDir")="/srv/efuzy"
 D EQ^MIOTASSERT($$UPLOADDIR^EFUZYFS(.CONF),"/srv/efuzy/uploads","[T001][upload dir]")
 D EQ^MIOTASSERT($$EXPORTDIR^EFUZYFS(.CONF),"/srv/efuzy/exports","[T001][export dir]")
 Q
 ;
T002 ; safe filename and safe alias
 D RESET^EFUZYTESTU("")
 D EQ^MIOTASSERT($$SAFEFN^EFUZYFS("../bad name?.x12"),".._bad_name_.x12","[T002][safefn]")
 D EQ^MIOTASSERT($$SAFE^EFUZYFS("A B&C.txt"),"A_B_C.txt","[T002][safe]")
 Q
 ;
T003 ; firstfile selects first file part
 N MP
 D RESET^EFUZYTESTU("")
 S MP("part",1,"name")="profileId"
 S MP("part",2,"filename")="demo.837"
 S MP("part",3,"filename")="demo2.837"
 D EQ^MIOTASSERT($$FIRSTFILE^EFUZYFS(.MP),2,"[T003][first file]")
 Q
 ;
T004 ; load and list file records
 N CONF,TCTX,OBJ
 D RESET^EFUZYTESTU("")
 S ^MIO("EFUZY","file",1,"id")=1
 S ^MIO("EFUZY","file",1,"name")="a.x12"
 S ^MIO("EFUZY","file",1,"path")="tmp/a.x12"
 S ^MIO("EFUZY","file",1,"size")=10
 S ^MIO("EFUZY","file",1,"createdAt")="2026-03-09T00:00:00Z"
 S ^MIO("EFUZY","file",2,"id")=2
 S ^MIO("EFUZY","file",2,"name")="b.x12"
 S ^MIO("EFUZY","file",2,"path")="tmp/b.x12"
 S ^MIO("EFUZY","file",2,"size")=20
 S ^MIO("EFUZY","file",2,"createdAt")="2026-03-09T00:01:00Z"
 D LOADFILES^EFUZYFS(.CONF,1,.TCTX)
 D EQ^MIOTASSERT($G(TCTX("files",1,"id")),2,"[T004][load latest id]")
 D EQ^MIOTASSERT($$GETPATH^EFUZYFS(1),"tmp/a.x12","[T004][get path]")
 D EQ^MIOTASSERT($$GETNAME^EFUZYFS(2),"b.x12","[T004][get name]")
 D LISTFILES^EFUZYFS(.CONF,.OBJ)
 D EQ^MIOTASSERT($G(OBJ("ok")),1,"[T004][list ok]")
 D EQ^MIOTASSERT($G(OBJ("files",2,"name")),"b.x12","[T004][list second]")
 Q
 ;
