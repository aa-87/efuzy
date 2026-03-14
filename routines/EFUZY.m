EFUZY ; efuzy workspace routes/controllers
	;
	Q
	;
REG(CONF)
	N META
	K META S META("authRequired")=1,META("roles")="operator,admin"
	D REG1("GET","/efuzy","HOME^EFUZY",.META)
	D REG1("GET","/efuzy/workspace","WORKSPACE^EFUZY",.META)
	D REG1("GET","/efuzy/preview/:jobId","PREVIEW^EFUZY",.META)
	D REG1("GET","/efuzy/profiles","PROFILES^EFUZY",.META)
	D REG1("GET","/efuzy/profiles/:id","PROFILE^EFUZY",.META)
	D REG1("GET","/efuzy/automation","AUTOMATION^EFUZY",.META)
	D REG1("GET","/efuzy/jobs/:id","JOBPAGE^EFUZY",.META)
	K META S META("authRequired")=1,META("roles")="operator,admin"
	D REG1("POST","/efuzy/api/upload","APIUPLOAD^EFUZY",.META)
	D REG1("POST","/efuzy/api/run","APIRUN^EFUZY",.META)
	D REG1("GET","/efuzy/api/jobs","APIJOBS^EFUZY",.META)
	D REG1("GET","/efuzy/api/job/:id","APIJOB^EFUZY",.META)
	D REG1("GET","/efuzy/api/files","APIFILES^EFUZY",.META)
	D REG1("GET","/efuzy/api/export/:jobId","APIEXPORT^EFUZY",.META)
	D REG1("POST","/efuzy/api/job/retry","APIRETRY^EFUZY",.META)
	D REG1("POST","/efuzy/api/profile/save","APIPROFS^EFUZY",.META)
	D REG1("POST","/efuzy/api/profile/delete","APIPROFD^EFUZY",.META)
	D REG1("POST","/efuzy/api/automation/save","APIAUTOS^EFUZY",.META)
	D REG1("POST","/efuzy/api/automation/delete","APIAUTOD^EFUZY",.META)
	Q
	;
REG1(METHOD,PATH,TARGET,META)
	D ADDM^MIOROUTE($G(METHOD),$G(PATH),$G(TARGET),.META)
	S ^MIO("ROUTE","META",$G(METHOD),$G(PATH),"authRequired")=+$G(META("authRequired"))
	S ^MIO("ROUTE","META",$G(METHOD),$G(PATH),"roles")=$G(META("roles"))
	Q
	;
HOME(DEV,CONF,REQ,CTX) D WORKSPACE(.DEV,.CONF,.REQ,.CTX) Q
WORKSPACE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDWS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_workspace.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT) Q
PREVIEW(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,JOBID S JOBID=$G(REQ("params","jobId"))
	D BUILDPREV^EFUZYUI(.CONF,.REQ,.CTX,JOBID,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_preview.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT) Q
PROFILES(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDPROFS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_profiles.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT) Q
PROFILE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,ID S ID=$G(REQ("params","id"))
	D BUILDPROF^EFUZYUI(.CONF,.REQ,.CTX,ID,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_profile_edit.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT) Q
AUTOMATION(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDAUTO^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_automation.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT) Q
JOBPAGE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,ID S ID=$G(REQ("params","id"))
	D BUILDJOB^EFUZYUI(.CONF,.REQ,.CTX,ID,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_job_detail.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT) Q
	;
APIUPLOAD(DEV,CONF,REQ,CTX)
	N MP,ERR,FILEID,JOBID,OBJ,PROFILEID
	I '$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"multipart_parse_failed")) Q
	S PROFILEID=$G(MP("field","profileId"))
	I '$$STAGEUPLOAD^EFUZYFS(.CONF,.MP,.FILEID,.ERR) D  Q
	. D FREE^MIOHTTPMPU(.MP)
	. D RESPERR(.DEV,.CONF,.CTX,500,$G(ERR("error"),"stage_failed"))
	D FREE^MIOHTTPMPU(.MP)
	I '$$CREATEQ^EFUZYJOB(.CONF,FILEID,"837_to_csv","manual",.JOBID,.ERR) D RESPERR(.DEV,.CONF,.CTX,500,$G(ERR("error"),"job_create_failed")) Q
	I PROFILEID'="" S ^MIO("EFUZY","job",JOBID,"profileId")=PROFILEID
	S OBJ("ok")=1,OBJ("fileId")=FILEID,OBJ("jobId")=JOBID,OBJ("redirect")="/efuzy/preview/"_JOBID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,201,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIRUN(DEV,CONF,REQ,CTX)
	N POST,JOBID,ERR,OBJ,PROFILEID
	D PARSEFORM(.CONF,.REQ,.POST)
	S JOBID=$G(POST("jobId")),PROFILEID=$G(POST("profileId"))
	I JOBID="" D RESPERR(.DEV,.CONF,.CTX,400,"job_id_required") Q
	I PROFILEID'="" S ^MIO("EFUZY","job",JOBID,"profileId")=PROFILEID
	I '$$RUN^EFUWFRUN(.CONF,JOBID,.ERR) D RESPERR(.DEV,.CONF,.CTX,500,$G(ERR("error"),"run_failed")) Q
	S OBJ("ok")=1,OBJ("jobId")=JOBID,OBJ("redirect")="/efuzy/preview/"_JOBID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
APIJOBS(DEV,CONF,REQ,CTX)
	N OBJ D LISTJSON^EFUWFHIST(.CONF,.REQ,.OBJ) D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX) Q
APIJOB(DEV,CONF,REQ,CTX)
	N OBJ,ID S ID=$G(REQ("params","id")) I '$$GETJSON^EFUWFHIST(.CONF,ID,.OBJ) D RESPERR(.DEV,.CONF,.CTX,404,"job_not_found") Q
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX) Q
APIFILES(DEV,CONF,REQ,CTX)
	N OBJ D LISTFILES^EFUZYFS(.CONF,.OBJ) D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX) Q
APIEXPORT(DEV,CONF,REQ,CTX)
	N JOBID,ERR S JOBID=$G(REQ("params","jobId")) I '$$SEND^EFUWFOUT(.DEV,.CONF,JOBID,.CTX,.ERR) D RESPERR(.DEV,.CONF,.CTX,404,$G(ERR("error"),"export_not_found")) Q
	Q
APIRETRY(DEV,CONF,REQ,CTX)
	N POST,JOBID,NEWID,ERR,OBJ
	D PARSEFORM(.CONF,.REQ,.POST)
	S JOBID=$G(POST("jobId")) I JOBID="" D RESPERR(.DEV,.CONF,.CTX,400,"job_id_required") Q
	I '$$RETRY^EFUZYJOB(.CONF,JOBID,.NEWID,.ERR) D RESPERR(.DEV,.CONF,.CTX,500,$G(ERR("error"),"retry_failed")) Q
	S OBJ("ok")=1,OBJ("jobId")=NEWID,OBJ("redirect")="/efuzy/preview/"_NEWID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX) Q
APIPROFS(DEV,CONF,REQ,CTX)
	N POST,ID,ERR,OBJ
	D PARSEFORM(.CONF,.REQ,.POST)
	I '$$SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"profile_save_failed")) Q
	S OBJ("ok")=1,OBJ("id")=ID,OBJ("redirect")="/efuzy/profiles/"_ID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX) Q
APIPROFD(DEV,CONF,REQ,CTX)
	N POST,ERR,OBJ
	D PARSEFORM(.CONF,.REQ,.POST)
	I '$$DELPROF^EFUZYCFG(.CONF,$G(POST("id")),.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"profile_delete_failed")) Q
	S OBJ("ok")=1,OBJ("redirect")="/efuzy/profiles"
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX) Q
APIAUTOS(DEV,CONF,REQ,CTX)
	N POST,ID,ERR,OBJ
	D PARSEFORM(.CONF,.REQ,.POST)
	I '$$SAVEAUTO^EFUZYCFG(.CONF,.POST,.ID,.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"automation_save_failed")) Q
	S OBJ("ok")=1,OBJ("id")=ID D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX) Q
APIAUTOD(DEV,CONF,REQ,CTX)
	N POST,ERR,OBJ
	D PARSEFORM(.CONF,.REQ,.POST)
	I '$$DELAUTO^EFUZYCFG(.CONF,$G(POST("id")),.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"automation_delete_failed")) Q
	S OBJ("ok")=1 D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX) Q
	;
PARSEFORM(CONF,REQ,OUT)
	N CT,BODY,MP,ERR,K
	; Backward-compatible support for both call styles:
	;   D PARSEFORM^EFUZY(.REQ,.OUT)
	;   D PARSEFORM^EFUZY(.CONF,.REQ,.OUT)
	; In the 2-arg style, CONF is actually the request source and REQ is the output target.;
	I '$D(OUT),$D(CONF("body")) D  Q
	. K REQ
	. S CT=$$LC($G(CONF("hdr","content-type")))
	. S BODY=$G(CONF("body"))
	. I CT["multipart/form-data" D  Q
	. . I '$$PARSE^MIOHTTPMPU(.CONF,.CONF,.MP,.ERR) S REQ("raw")=BODY Q
	. . S K="" F  S K=$O(MP("field",K)) Q:K=""  S REQ(K)=$G(MP("field",K))
	. . D FREE^MIOHTTPMPU(.MP)
	. I BODY["=" D URLDEC(BODY,.REQ) I $D(REQ)>0 Q
	. S REQ("raw")=BODY
	K OUT
	S CT=$$LC($G(REQ("hdr","content-type")))
	S BODY=$G(REQ("body"))
	I CT["multipart/form-data" D  Q
	. I '$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR) S OUT("raw")=BODY Q
	. S K="" F  S K=$O(MP("field",K)) Q:K=""  S OUT(K)=$G(MP("field",K))
	. D FREE^MIOHTTPMPU(.MP)
	I BODY["=" D URLDEC(BODY,.OUT) I $D(OUT)>0 Q
	S OUT("raw")=BODY
	Q
	;
URLDEC(BODY,OUT)
	N I,PAIR,K,V
	K OUT
	F I=1:1:$L($G(BODY),"&") S PAIR=$P($G(BODY),"&",I) D
	. S K=$$URLU($P(PAIR,"=",1))
	. S V=$$URLU($P(PAIR,"=",2,999))
	. I K'="" S OUT(K)=V
	Q
	;
URLU(X)
	N I,C,RES,HEX
	S X=$G(X),RES="",I=1
	F  Q:I>$L(X)  D
	. S C=$E(X,I)
	. I C="+" S RES=RES_" ",I=I+1 Q
	. I C="%",I+2<=$L(X) D  Q
	. . S HEX=$E(X,I+1,I+2)
	. . I $$ISHEX(HEX) S RES=RES_$C($$HEXDEC(HEX)),I=I+3 Q
	. . S RES=RES_C,I=I+1
	. S RES=RES_C,I=I+1
	Q RES
	;
LC(X)
	Q $ZCONVERT($G(X),"L")
	;
ISHEX(X)
	N I,C,Q S Q=1
	I $L($G(X))'=2 Q 0
	F I=1:1:2 S C=$E(X,I) I "0123456789ABCDEFabcdef"'[C S Q=0 Q
	Q Q
	;
HEXDEC(X)
	Q ($$HEXVAL($E(X,1))*16)+$$HEXVAL($E(X,2))
	;
HEXVAL(C)
	S C=$ZCONVERT($G(C),"U")
	I C?1N Q C
	Q $F("ABCDEF",C)-2+10
	;
RESPHTML(DEV,CONF,CTX,OUT)
	N HEAD S HEAD("Content-Type")="text/html; charset=utf-8"
	D RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,$G(OUT),$G(CTX("request_id")),.CTX) Q
RESPERR(DEV,CONF,CTX,STATUS,ERRTXT)
	N OBJ S OBJ("ok")=0,OBJ("error")=$G(ERRTXT)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,+$G(STATUS),.OBJ,$G(CTX("request_id")),.CTX) Q
	;
WORKBASE(CONF,JOBID,FILEID,MODE)
	N ROOT
	S ROOT=$$ROOT^EFUZYFS(.CONF)
	Q ROOT_"tmp/"_$G(MODE)_"-"_$G(JOBID)_"-"_$G(FILEID)
	;
GetRoutineList(routine,result)
	N %ZR K result,%ZR
	do SILENT^%RSEL(routine,"CALL")
	M result=%ZR
	K %ZR
	Q
	;
link
	N R,RTN
	D GetRoutineList("EFU*",.R)
	N A S A="" F  S A=$O(R(A)) Q:A=""  D
	. S RTN=A
	. I $E(RTN)="%" S $E(RTN)="_"
	. W !,"ZL " ZL RTN_".m" W RTN_".m"
	Q	