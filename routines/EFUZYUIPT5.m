EFUZYUIPT5 ; desktop phase 2 SSR tests
	; Quiet on success.;
	;
	D START Q
	;
START ; default entry
	N FAIL
	S FAIL=0
	D ALL(.FAIL)
	I 'FAIL W !,"OK - EFUZYUIPT5"
	Q
	;
ALL(FAIL)
	D T940(.FAIL)
	D T950(.FAIL)
	Q
	;
SEED
	N CONF,POST,PID,AID,ERR,JOBID1,JOBID2
	D SEED^EFUZYCFG
	S POST("name")="Desktop Panel Profile"
	S POST("exportMode")="claim_summary"
	D SAVE^EFUZYCFG(.CONF,.POST,.PID,.ERR)
	K POST
	S POST("name")="Watched Desktop"
	S POST("inputFolder")="/watched/input"
	S POST("enabled")=1
	S POST("selectedProfile")=PID
	D SAVEAUTO^EFUZYCFG(.CONF,.POST,.AID,.ERR)
	S ^MIO("EFUZY","file",1,"id")=1
	S ^MIO("EFUZY","file",1,"name")="desktop-good.837"
	S ^MIO("EFUZY","file",1,"path")="tmp/desktop-good.837"
	S ^MIO("EFUZY","file",1,"size")=2048
	S ^MIO("EFUZY","file",1,"createdAt")="2026-03-15T09:00:00Z"
	S ^MIO("EFUZY","file",2,"id")=2
	S ^MIO("EFUZY","file",2,"name")="desktop-bad.837"
	S ^MIO("EFUZY","file",2,"path")="tmp/desktop-bad.837"
	S ^MIO("EFUZY","file",2,"size")=1024
	S ^MIO("EFUZY","file",2,"createdAt")="2026-03-15T09:05:00Z"
	D CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID1,.ERR)
	D START^EFUZYJOB(JOBID1)
	D SETSTAT^EFUZYJOB(JOBID1,"claimCount",2)
	D SETSTAT^EFUZYJOB(JOBID1,"serviceLineCount",4)
	D FINOK^EFUZYJOB(JOBID1)
	D CREATEQ^EFUZYJOB(.CONF,2,"837_to_csv","manual",.JOBID2,.ERR)
	D START^EFUZYJOB(JOBID2)
	D SETSTAT^EFUZYJOB(JOBID2,"claimCount",1)
	D SETSTAT^EFUZYJOB(JOBID2,"serviceLineCount",1)
	D FINERR^EFUZYJOB(JOBID2,"validation failed")
	Q
	;
T940(FAIL) ; desktop phase 2 context exposes folder panels and inspector
	N CONF,REQ,CTX,TCTX
	D RESET^EFUZYTESTU("")
	D SEED
	D BUILDDESK^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D EQ(.FAIL,"[T940][panel input]",$G(TCTX("desktop","panel",1,"key")),"input")
	D EQ(.FAIL,"[T940][panel output]",$G(TCTX("desktop","panel",2,"key")),"output")
	D EQ(.FAIL,"[T940][panel error]",$G(TCTX("desktop","panel",3,"key")),"error")
	D EQ(.FAIL,"[T940][input files any]",+$G(TCTX("desktop","inputAny")),1)
	D EQ(.FAIL,"[T940][output jobs any]",+$G(TCTX("desktop","outputAny")),1)
	D EQ(.FAIL,"[T940][error jobs any]",+$G(TCTX("desktop","errorAny")),1)
	D EQ(.FAIL,"[T940][archive jobs any]",+$G(TCTX("desktop","archiveAny")),1)
	D EQ(.FAIL,"[T940][inspector any]",+$G(TCTX("desktop","inspectorAny")),1)
	Q
	;
T950(FAIL) ; desktop phase 2 template renders panels, progress, and drawer hooks
	N CONF,REQ,CTX,TCTX,OUT,ERR
	D RESET^EFUZYTESTU("")
	D SEED
	S CONF("server","templateDir")="templates"
	D START^MIOTPL(.CONF)
	D BUILDDESK^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_desktop.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	D EQ(.FAIL,"[T950][render ok]",$D(ERR),0)
	D EQ(.FAIL,"[T950][panel output hook]",$F(OUT,"data-desktop-panel=""output""")>0,1)
	D EQ(.FAIL,"[T950][progress hook]",$F(OUT,"data-desktop-progress-bar")>0,1)
	D EQ(.FAIL,"[T950][drawer hook]",$F(OUT,"data-desktop-drawer")>0,1)
	D EQ(.FAIL,"[T950][job launch hook]",$F(OUT,"data-desktop-job-launch")>0,1)
	Q
	;
EQ(FAIL,LABEL,GOT,EXP)
	I $G(GOT)=$G(EXP) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
	Q
	;
	;