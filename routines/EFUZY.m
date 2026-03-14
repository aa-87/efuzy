EFUZY ; efuzy workspace routes/controllers
	;
	Q
	;
REG(CONF)
	N META
	K META S META("authRequired")=0,META("roles")="operator,admin"
	D ADDM^MIOROUTE("GET","/efuzy","HOME^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/workspace","WORKSPACE^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/preview/:jobId","PREVIEW^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/profiles","PROFILES^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/profiles/:id","PROFILE^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/automation","AUTOMATION^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/jobs","JOBS^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/jobs/:id","JOBPAGE^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/download/:jobId/:artifactKey","DOWNLOAD^EFUZY",.META)
	K META S META("authRequired")=0,META("roles")="operator,admin"
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
JOBS(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDJOBS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_jobs.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
JOBPAGE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,ID S ID=$G(REQ("params","id"))
	D BUILDJOB^EFUZYUI(.CONF,.REQ,.CTX,ID,.TCTX)
	D RENDERPAGE^MIOTPL("pages/efuzy_job_detail.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT) Q
	;
DOWNLOAD(DEV,CONF,REQ,CTX)
	N JOBID,ARTKEY,ERR
	S JOBID=$G(REQ("params","jobId"))
	S ARTKEY=$G(REQ("params","artifactKey"))
	I '$$SENDART(.DEV,.CONF,JOBID,ARTKEY,.CTX,.ERR) D RESPERR(.DEV,.CONF,.CTX,404,$G(ERR("error"),"artifact_not_found"))
	Q
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
	N CT,MP,ERR,K
	K OUT
	S CT=$ZCONVERT($G(REQ("hdr","content-type")),"L")
	I CT["multipart/form-data" D  Q
	. I '$$PARSE^MIOHTTPMPU(.CONF,.REQ,.MP,.ERR) S OUT("raw")=$G(REQ("body")) Q
	. S K="" F  S K=$O(MP("field",K)) Q:K=""  S OUT(K)=$G(MP("field",K))
	. D FREE^MIOHTTPMPU(.MP)
	I $T(DECODEFORM^MIOFNC)'="" D DECODEFORM^MIOFNC($G(REQ("body")),.OUT) Q
	S OUT("raw")=$G(REQ("body"))
	Q
	;
RESPHTML(DEV,CONF,CTX,OUT)
	N HEAD S HEAD("Content-Type")="text/html; charset=utf-8"
	D RESPX^MIOHTTP(.DEV,.CONF,200,.HEAD,$G(OUT),$G(CTX("request_id")),.CTX) Q
RESPERR(DEV,CONF,CTX,STATUS,ERRTXT)
	N OBJ S OBJ("ok")=0,OBJ("error")=$G(ERRTXT)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,+$G(STATUS),.OBJ,$G(CTX("request_id")),.CTX) Q
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
	I $D(^MIO("EFUZY","job",+JOBID,"artifact","profile_export")) Q "profile_export"
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
WORKBASE(CONF,JOBID,FILEID,MODE)
	N ROOT
	S ROOT=$$ROOT^EFUZYFS(.CONF)
	Q ROOT_"/tmp/"_$G(MODE)_"-"_$G(JOBID)_"-"_$G(FILEID)
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