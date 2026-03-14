EFUZY ; efuzy workspace routes/controllers
	;
	; SSR-first product shell for the efuzy workspace.;
	; Reuses MIOROUTE + MIOHTTP + MIOTPL + MIOAUTHZ.;
	;
	Q
	;
link
	N R,RTN
	D GetRoutineList^MIO("EFU*",.R)
	N A S A="" F  S A=$O(R(A)) Q:A=""  D
	. S RTN=A
	. I $E(RTN)="%" S $E(RTN)="_"
	. W !,"ZL " ZL RTN_".m" W RTN_".m"
	Q	 
REG(CONF)
	N META
	;
	; Operator/admin pages
	K META
	S META("authRequired")=1,META("roles")="operator,admin"
	D ADDM^MIOROUTE("GET","/efuzy","HOME^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/workspace","WORKSPACE^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/preview/:jobId","PREVIEW^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/jobs","JOBS^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/jobs/:id","JOBPAGE^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/download/:jobId/:artifactKey","DOWNLOAD^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/profiles","PROFILES^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/profiles/:id","PROFILE^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/automation","AUTOMATION^EFUZY",.META)
	;
	; Operator/admin APIs
	K META
	S META("authRequired")=1,META("roles")="operator,admin"
	D ADDM^MIOROUTE("POST","/efuzy/api/upload","APIUPLOAD^EFUZY",.META)
	D ADDM^MIOROUTE("POST","/efuzy/api/run","APIRUN^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/api/jobs","APIJOBS^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/api/job/:id","APIJOB^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/api/files","APIFILES^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/api/export/:jobId","APIEXPORT^EFUZY",.META)
	D ADDM^MIOROUTE("POST","/efuzy/api/job/retry","APIRETRY^EFUZY",.META)
	D ADDM^MIOROUTE("POST","/efuzy/api/profile/save","APIPROFS^EFUZY",.META)
	D ADDM^MIOROUTE("POST","/efuzy/api/profile/delete","APIPROFD^EFUZY",.META)
	D ADDM^MIOROUTE("POST","/efuzy/api/automation/save","APIAUTOS^EFUZY",.META)
	D ADDM^MIOROUTE("POST","/efuzy/api/automation/delete","APIAUTOD^EFUZY",.META)
	Q
	;
HOME(DEV,CONF,REQ,CTX)
	D WORKSPACE(.DEV,.CONF,.REQ,.CTX)
	Q
	;
WORKSPACE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDWS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_workspace.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
PREVIEW(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,JOBID
	S JOBID=$G(REQ("params","jobId"))
	D BUILDPREV^EFUZYUI(.CONF,.REQ,.CTX,JOBID,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_preview.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
JOBS(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDJOBS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_jobs.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
PROFILES(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDPROFS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_profiles.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
PROFILE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,ID
	S ID=$G(REQ("params","id"))
	D BUILDPROF^EFUZYUI(.CONF,.REQ,.CTX,ID,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_profile_edit.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
AUTOMATION(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDAUTO^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_automation.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
JOBPAGE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,ID
	S ID=$G(REQ("params","id"))
	D BUILDJOB^EFUZYUI(.CONF,.REQ,.CTX,ID,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_job_detail.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
DOWNLOAD(DEV,CONF,REQ,CTX)
	N JOBID,ARTKEY,ERR
	S JOBID=$G(REQ("params","jobId"))
	S ARTKEY=$G(REQ("params","artifactKey"))
	I '$$SENDART(.DEV,.CONF,JOBID,ARTKEY,.CTX,.ERR) D RESPERR(.DEV,.CONF,.CTX,404,$G(ERR("error"),"artifact_not_found"))
	Q
	;
APIUPLOAD(DEV,CONF,REQ,CTX)
	; Multipart upload.;
	N MP,ERR,FILEID,JOBID,OBJ,PROFILEID
	I '$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"multipart_parse_failed")) Q
	S PROFILEID=$G(MP("field","profileId"))
	I '$$STAGEUPLOAD^EFUZYFS(.CONF,.MP,.FILEID,.ERR) D  Q
	. D FREE^MIOHTTPMPU(.MP)
	. D RESPERR(.DEV,.CONF,.CTX,500,$G(ERR("error"),"stage_failed"))
	D FREE^MIOHTTPMPU(.MP)
	I '$$CREATEQ^EFUZYJOB(.CONF,FILEID,"837_to_csv","manual",.JOBID,.ERR) D RESPERR(.DEV,.CONF,.CTX,500,$G(ERR("error"),"job_create_failed")) Q
	I PROFILEID'="" S ^MIO("EFUZY","job",JOBID,"profileId")=PROFILEID
	S OBJ("ok")=1
	S OBJ("fileId")=FILEID
	S OBJ("jobId")=JOBID
	S OBJ("redirect")="/efuzy/preview/"_JOBID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,201,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIRUN(DEV,CONF,REQ,CTX)
	N POST,JOBID,ERR,OBJ,PROFILEID,FILEID,INPATH,WORKBASE,OPT,RES,JROOT,STATUS,WF
	D PARSEFORM(.CONF,.REQ,.POST)
	S JOBID=+$G(POST("jobId")) M ^AHM=POST
	S PROFILEID=$G(POST("profileId"))
	I 'JOBID D RESPERR(.DEV,.CONF,.CTX,400,"job_id_required") Q
	S FILEID=+$G(^MIO("EFUZY","job",JOBID,"fileId"))
	S INPATH=$$GETPATH^EFUZYFS(FILEID)
	I INPATH="" D RESPERR(.DEV,.CONF,.CTX,400,"file_path_missing") Q
	I PROFILEID'="" S ^MIO("EFUZY","job",JOBID,"profileId")=PROFILEID
	S WF=$G(^MIO("EFUZY","job",JOBID,"workflowType")) I WF="" S WF="837_to_csv"
	S OPT("jobid")=JOBID
	S OPT("workflow")=WF
	S OPT("trace")=$$BOOL($G(POST("trace")),1)
	S OPT("build_rebuilt")=$$BOOL($G(POST("build_rebuilt")),1)
	S OPT("roundtrip")=$$BOOL($G(POST("roundtrip")),0)
	S OPT("compare_mode")=$S($G(POST("compareMode"))'="":$G(POST("compareMode")),1:"export_safe")
	S ^MIO("EFUZY","job",JOBID,"inputPath")=INPATH
	S ^MIO("EFUZY","job",JOBID,"compareMode")=$G(OPT("compare_mode"))
	S ^MIO("EFUZY","job",JOBID,"build_rebuilt")=+$G(OPT("build_rebuilt"))
	S ^MIO("EFUZY","job",JOBID,"roundtrip")=+$G(OPT("roundtrip"))
	S ^MIO("EFUZY","job",JOBID,"trace")=+$G(OPT("trace"))
	S WORKBASE=$$WORKBASE(.CONF,JOBID,FILEID,"run")
	S JROOT=$NA(^TMP($J,"EFUZY","run",JOBID,$H))
	I '$$RUNJOB(.CONF,JOBID,INPATH,WORKBASE,JROOT,.OPT,.RES,.ERR) D  Q
	. S STATUS=$S(+$G(ERR("http_status"))>0:+$G(ERR("http_status")),$G(RES("status"))="failed":422,1:500)
	. D RESPERR(.DEV,.CONF,.CTX,STATUS,$S($G(ERR("error"))'="":$G(ERR("error")),1:"run_failed"))
	S OBJ("ok")=1,OBJ("jobId")=JOBID,OBJ("redirect")="/efuzy/preview/"_JOBID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
RUNJOB(CONF,JOBID,INPATH,WORKBASE,JROOT,OPT,RES,ERR)
	N LERR,ECODE,ETXT
	K ERR
	D RUN837^EFUX12JOB(INPATH,WORKBASE,JROOT,.OPT,.RES)
	I +$G(RES("ok")) Q 1
	S ECODE=$G(@JROOT@("meta","error_code"))
	S ETXT=$G(@JROOT@("meta","error_text"))
	I ECODE="" S ECODE=$S($G(RES("error"))'="":$G(RES("error")),1:"run_failed")
	I ETXT="" S ETXT=ECODE
	S ERR("error")=ETXT
	S ERR("http_status")=$S($G(RES("status"))="failed":422,1:500)
	I ECODE'="parse_failed" Q 0
	I '$$RUN^EFUWFRUN(.CONF,JOBID,.LERR) D  Q 0
	. S ERR("error")=$S($G(LERR("error"))'="":$G(LERR("error")),1:ETXT)
	. S ERR("http_status")=422
	D LEGSYNC(JOBID)
	S RES("ok")=1
	S RES("status")="completed"
	S RES("fallback")="legacy_workflow"
	Q 1
	;
LEGSYNC(JOBID)
	N PATH,NAME,N
	S PATH=$G(^MIO("EFUZY","job",JOBID,"outputPath"))
	S NAME=$G(^MIO("EFUZY","job",JOBID,"outputName"))
	S ^MIO("EFUZY","job",JOBID,"compat","parser")="legacy_workflow"
	S ^MIO("EFUZY","job",JOBID,"stats","claims")=+$G(^MIO("EFUZY","job",JOBID,"stats","claims"),+$G(^MIO("EFUZY","job",JOBID,"stats","claimCount")))
	S ^MIO("EFUZY","job",JOBID,"stats","lines")=+$G(^MIO("EFUZY","job",JOBID,"stats","lines"),+$G(^MIO("EFUZY","job",JOBID,"stats","serviceLineCount")))
	S ^MIO("EFUZY","job",JOBID,"stats","segments")=+$G(^MIO("EFUZY","job",JOBID,"stats","segments"),+$G(^MIO("EFUZY","job",JOBID,"stats","segmentCount")))
	I PATH="" Q
	I NAME="" S NAME=$P(PATH,"/",$L(PATH,"/"))
	S N=+$G(^MIO("EFUZY","job",JOBID,"artifact_last"))
	I '$D(^MIO("EFUZY","job",JOBID,"artifact","profile_export")) S N=N+1
	S ^MIO("EFUZY","job",JOBID,"artifact_last")=N
	S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","id")=N
	S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","key")="profile_export"
	S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","role")="profile"
	S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","path")=PATH
	S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","type")="csv"
	S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","name")=NAME
	S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","exists")=1
	S ^MIO("EFUZY","job",JOBID,"artifact_by_id",N)="profile_export"
	S ^MIO("EFUZY","job",JOBID,"artifact_by_role","profile","profile_export")=""
	Q
	;
APIJOBS(DEV,CONF,REQ,CTX)
	N ROOT,OPT,RES,OBJ
	S ROOT=$NA(^TMP($J,"EFUZY","api","jobs",$H))
	S OPT("limit")=+$$RQQ(.REQ,"limit")
	S OPT("status")=$$RQQ(.REQ,"status")
	S OPT("workflow")=$$RQQ(.REQ,"workflow")
	S OPT("start_after")=+$$RQQ(.REQ,"start_after")
	D HISTORY^EFUX12WEB(ROOT,.OPT,.RES)
	M OBJ=@ROOT@("response")
	D RESPJSONX^MIOHTTP(.DEV,.CONF,+$G(RES("http_status"),200),.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIJOB(DEV,CONF,REQ,CTX)
	N ROOT,OPT,RES,OBJ,ID
	S ROOT=$NA(^TMP($J,"EFUZY","api","job",$H))
	S ID=$G(REQ("params","id"))
	S OPT("include_trace")=$$BOOL($$RQQ(.REQ,"include_trace"),0)
	D DETAIL^EFUX12WEB(ID,ROOT,.OPT,.RES)
	M OBJ=@ROOT@("response")
	D RESPJSONX^MIOHTTP(.DEV,.CONF,+$G(RES("http_status"),200),.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIFILES(DEV,CONF,REQ,CTX)
	N OBJ
	D LISTFILES^EFUZYFS(.CONF,.OBJ)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIEXPORT(DEV,CONF,REQ,CTX)
	N JOBID,ARTKEY,ERR
	S JOBID=$G(REQ("params","jobId"))
	S ARTKEY=$$RQQ(.REQ,"key")
	I '$$SENDART(.DEV,.CONF,JOBID,ARTKEY,.CTX,.ERR) D RESPERR(.DEV,.CONF,.CTX,404,$G(ERR("error"),"export_not_found"))
	Q
	;
APIRETRY(DEV,CONF,REQ,CTX)
	N POST,JOBID,NEWID,ERR,OBJ
	D PARSEFORM(.CONF,.REQ,.POST)
	S JOBID=$G(POST("jobId"))
	I JOBID="" D RESPERR(.DEV,.CONF,.CTX,400,"job_id_required") Q
	I '$$RETRY^EFUZYJOB(.CONF,JOBID,.NEWID,.ERR) D RESPERR(.DEV,.CONF,.CTX,500,$G(ERR("error"),"retry_failed")) Q
	S OBJ("ok")=1,OBJ("jobId")=NEWID,OBJ("redirect")="/efuzy/preview/"_NEWID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIPROFS(DEV,CONF,REQ,CTX)
	N POST,ID,ERR,OBJ
	D PARSEFORM(.CONF,.REQ,.POST)
	I '$$SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"profile_save_failed")) Q
	S OBJ("ok")=1,OBJ("id")=ID,OBJ("redirect")="/efuzy/profiles/"_ID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIPROFD(DEV,CONF,REQ,CTX)
	N POST,ERR,OBJ
	D PARSEFORM(.CONF,.REQ,.POST)
	I '$$DELPROF^EFUZYCFG(.CONF,$G(POST("id")),.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"profile_delete_failed")) Q
	S OBJ("ok")=1,OBJ("redirect")="/efuzy/profiles"
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIAUTOS(DEV,CONF,REQ,CTX)
	N POST,ID,ERR,OBJ
	D PARSEFORM(.CONF,.REQ,.POST)
	I '$$SAVEAUTO^EFUZYCFG(.CONF,.POST,.ID,.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"automation_save_failed")) Q
	S OBJ("ok")=1,OBJ("id")=ID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIAUTOD(DEV,CONF,REQ,CTX)
	N POST,ERR,OBJ
	D PARSEFORM(.CONF,.REQ,.POST)
	I '$$DELAUTO^EFUZYCFG(.CONF,$G(POST("id")),.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"automation_delete_failed")) Q
	S OBJ("ok")=1
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
SENDART(DEV,CONF,JOBID,ARTKEY,CTX,ERR)
	N PATH,NAME,TYPE,HEAD,KEY
	K ERR
	S JOBID=+JOBID
	I 'JOBID S ERR("error")="job_id_required" Q 0
	S KEY=$$SAFEKEY($G(ARTKEY))
	I KEY="" S KEY=$$DEFART(JOBID)
	I KEY'="",$D(^MIO("EFUZY","job",JOBID,"artifact",KEY)) D
	. S PATH=$G(^MIO("EFUZY","job",JOBID,"artifact",KEY,"path"))
	. S TYPE=$G(^MIO("EFUZY","job",JOBID,"artifact",KEY,"type"))
	. S NAME=$G(^MIO("EFUZY","job",JOBID,"artifact",KEY,"name"))
	E  D
	. S PATH=$G(^MIO("EFUZY","job",JOBID,"outputPath"))
	. S NAME=$G(^MIO("EFUZY","job",JOBID,"outputName"))
	. S TYPE="csv"
	I PATH="" S ERR("error")="artifact_not_found" Q 0
	I NAME="" S NAME=$$SAFEKEY($S(KEY'="":KEY,1:"download"))
	S HEAD("Content-Type")=$$MIME(TYPE,PATH)
	S HEAD("Content-Disposition")="attachment; filename="""_NAME_""""
	Q $$SENDFILE^MIOHTTP(.DEV,.CONF,PATH,.HEAD,$G(CTX("request_id")),.CTX,"GET")
	;
DEFART(JOBID)
	I $D(^MIO("EFUZY","job",+JOBID,"artifact","canonical_claims")) Q "canonical_claims"
	I $D(^MIO("EFUZY","job",+JOBID,"artifact","canonical_lines")) Q "canonical_lines"
	I $D(^MIO("EFUZY","job",+JOBID,"artifact","rebuilt_x12")) Q "rebuilt_x12"
	Q ""
	;
SAFEKEY(X)
	N I,C,O
	S O=""
	F I=1:1:$L($G(X)) S C=$E(X,I) D
	. I C?1AN S O=O_C Q
	. I "-_.,"[C S O=O_C Q
	Q O
	;
MIME(TYPE,PATH)
	N T
	S T=$ZCONVERT($G(TYPE),"L")
	I T="csv" Q "text/csv; charset=utf-8"
	I T="text" Q "text/plain; charset=utf-8"
	I T="edi" Q "application/edi-x12"
	I T="json" Q "application/json"
	I $E($G(PATH),$L($G(PATH))-3,$L($G(PATH)))=".csv" Q "text/csv; charset=utf-8"
	I $E($G(PATH),$L($G(PATH))-3,$L($G(PATH)))=".txt" Q "text/plain; charset=utf-8"
	Q "application/octet-stream"
	;
WORKBASE(CONF,JOBID,FILEID,TAG)
	N ROOT
	S ROOT=$G(CONF("x12","workbase"))
	I ROOT'="" Q ROOT_"/efuzy-"_$TR($G(TAG)," /","__")_"-"_+$G(JOBID)_"-"_+$G(FILEID)_"-"_$J_"-"_$R(999999)
	Q "/tmp/efuzy-"_$TR($G(TAG)," /","__")_"-"_+$G(JOBID)_"-"_+$G(FILEID)_"-"_$J_"-"_$R(999999)
	;
RQQ(REQ,KEY)
	I $D(REQ("query",KEY)) Q $G(REQ("query",KEY))
	I $D(REQ("params",KEY)) Q $G(REQ("params",KEY))
	Q ""
	;
BOOL(VAL,DEF)
	I $G(VAL)="" Q +$G(DEF)
	I $G(VAL)?1N.N Q +VAL
	I $ZCONVERT($G(VAL),"L")="false" Q 0
	I $ZCONVERT($G(VAL),"L")="no" Q 0
	I $ZCONVERT($G(VAL),"L")="off" Q 0
	Q 1
	;
PARSEFORM(CONF,REQ,OUT)
	N CT,MP,ERR,NAME
	K OUT
	S CT=$ZCONVERT($G(REQ("hdr","content-type")),"L")
	I CT["multipart/form-data",$T(PARSE^MIOHTTPMPU)'="" D  Q
	. I '$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR) S OUT("raw")=$G(REQ("body")) Q
	. S NAME=""
	. F  S NAME=$O(MP("field",NAME)) Q:NAME=""  S OUT(NAME)=$G(MP("field",NAME))
	. D FREE^MIOHTTPMPU(.MP)
	I $T(DECODEFORM^MIOFNC)'="" D  Q
	. D DECODEFORM^MIOFNC($G(REQ("body")),.OUT)
	S OUT("raw")=$G(REQ("body"))
	Q
	;
RESPHTML(DEV,CONF,CTX,OUT)
	N HEAD
	S HEAD("Content-Type")="text/html; charset=utf-8"
	D RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,$G(OUT),$G(CTX("request_id")),.CTX)
	Q
	;
RESPERR(DEV,CONF,CTX,STATUS,ERRTXT)
	N OBJ
	S OBJ("ok")=0
	S OBJ("error")=$G(ERRTXT)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,+$G(STATUS),.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
	;
	;