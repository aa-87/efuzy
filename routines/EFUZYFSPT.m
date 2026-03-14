EFUZYFSPT ; efuzy filesystem hardening tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYFSPT"
 Q
 ;
ALL(FAIL)
 D T500(.FAIL)
 D T510(.FAIL)
 D T520(.FAIL)
 D T530(.FAIL)
 Q
 ;
T500(FAIL) ; roots, dirs, and safe name helpers
 N CONF,ROOT
 D RESET^EFUZYTESTU("")
 S ROOT=$$TMPROOT^EFUZYTESTU("fspt-500")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 D EQ(.FAIL,"[T500][root]",$$ROOT^EFUZYFS(.CONF),ROOT)
 D EQ(.FAIL,"[T500][upload dir]",$$UPLOADDIR^EFUZYFS(.CONF),ROOT_"/uploads")
 D EQ(.FAIL,"[T500][export dir]",$$EXPORTDIR^EFUZYFS(.CONF),ROOT_"/exports")
 D EQ(.FAIL,"[T500][safe spaces]",$$SAFEFN^EFUZYFS("A B C.txt"),"A_B_C.txt")
 D EQ(.FAIL,"[T500][safe punct]",$$SAFE^EFUZYFS("..*bad name?.x12"),".._bad_name_.x12")
 Q
 ;
T510(FAIL) ; first file detection
 N MP
 K MP
 S MP("part",2,"filename")=""
 S MP("part",3,"filename")="claim.edi"
 S MP("part",4,"filename")="later.edi"
 D EQ(.FAIL,"[T510][first file]",$$FIRSTFILE^EFUZYFS(.MP),3)
 K MP
 D EQ(.FAIL,"[T510][no file]",$$FIRSTFILE^EFUZYFS(.MP),0)
 Q
 ;
T520(FAIL) ; loadfiles sorts latest first and marks empty
 N CONF,TCTX
 D RESET^EFUZYTESTU("")
 D LOADFILES^EFUZYFS(.CONF,5,.TCTX)
 D EQ(.FAIL,"[T520][empty flag]",+$G(TCTX("filesEmpty")),1)
 K TCTX
 S ^MIO("EFUZY","file",1,"id")=1
 S ^MIO("EFUZY","file",1,"name")="one.x12"
 S ^MIO("EFUZY","file",2,"id")=2
 S ^MIO("EFUZY","file",2,"name")="two.x12"
 S ^MIO("EFUZY","file",3,"id")=3
 S ^MIO("EFUZY","file",3,"name")="three.x12"
 D LOADFILES^EFUZYFS(.CONF,2,.TCTX)
 D EQ(.FAIL,"[T520][latest first]",+$G(TCTX("files",1,"id")),3)
 D EQ(.FAIL,"[T520][second latest]",+$G(TCTX("files",2,"id")),2)
 Q
 ;
T530(FAIL) ; listfiles and getters surface stored metadata
 N CONF,OBJ
 D RESET^EFUZYTESTU("")
 S ^MIO("EFUZY","file",7,"id")=7
 S ^MIO("EFUZY","file",7,"name")="demo.837"
 S ^MIO("EFUZY","file",7,"path")="tmp/demo.837"
 S ^MIO("EFUZY","file",7,"size")=123
 D LISTFILES^EFUZYFS(.CONF,.OBJ)
 D EQ(.FAIL,"[T530][ok]",+$G(OBJ("ok")),1)
 D EQ(.FAIL,"[T530][file id]",+$G(OBJ("files",1,"id")),7)
 D EQ(.FAIL,"[T530][file name]",$G(OBJ("files",1,"name")),"demo.837")
 D EQ(.FAIL,"[T530][get path]",$$GETPATH^EFUZYFS(7),"tmp/demo.837")
 D EQ(.FAIL,"[T530][get name]",$$GETNAME^EFUZYFS(7),"demo.837")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
