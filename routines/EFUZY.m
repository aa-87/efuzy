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
	D ADDM^MIOROUTE("GET","/efuzy/profiles","PROFILES^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/profiles/:id","PROFILE^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/automation","AUTOMATION^EFUZY",.META)
	D ADDM^MIOROUTE("GET","/efuzy/jobs/:id","JOBPAGE^EFUZY",.META)
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
	 ;D START^MIOTPL(.CONF)
	D RENDERPAGE^MIOTPL("pages/efuzy_workspace.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
PREVIEW(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,JOBID
	S JOBID=$G(REQ("params","jobId"))
	D BUILDPREV^EFUZYUI(.CONF,.REQ,.CTX,JOBID,.TCTX)
	 ;D START^MIOTPL(.CONF)
	D RENDERPAGE^MIOTPL("pages/efuzy_preview.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
PROFILES(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDPROFS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	 ; ;D START^MIOTPL(.CONF)
	D RENDERPAGE^MIOTPL("pages/efuzy_profiles.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
PROFILE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,ID
	S ID=$G(REQ("params","id")) S ^A=ID
	D BUILDPROF^EFUZYUI(.CONF,.REQ,.CTX,ID,.TCTX)
	 ;D START^MIOTPL(.CONF)
	D RENDERPAGE^MIOTPL("pages/efuzy_profile_edit.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
AUTOMATION(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR
	D BUILDAUTO^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	 ;D START^MIOTPL(.CONF)
	D RENDERPAGE^MIOTPL("pages/efuzy_automation.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
	Q
	;
JOBPAGE(DEV,CONF,REQ,CTX)
	N TCTX,OUT,ERR,ID
	S ID=$G(REQ("params","id"))
	D BUILDJOB^EFUZYUI(.CONF,.REQ,.CTX,ID,.TCTX)
	 ;D START^MIOTPL(.CONF)
	D RENDERPAGE^MIOTPL("pages/efuzy_job_detail.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
	I $D(ERR) D RESPERR(.DEV,.CONF,.CTX,500,"template_error") Q
	D RESPHTML(.DEV,.CONF,.CTX,.OUT)
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
	N POST,JOBID,ERR,OBJ,PROFILEID
	D PARSEFORM(.REQ,.POST)
	S JOBID=$G(POST("jobId"))
	S PROFILEID=$G(POST("profileId"))
	I JOBID="" D RESPERR(.DEV,.CONF,.CTX,400,"job_id_required") Q
	I PROFILEID'="" S ^MIO("EFUZY","job",JOBID,"profileId")=PROFILEID
	I '$$RUN^EFUWFRUN(.CONF,JOBID,.ERR) D RESPERR(.DEV,.CONF,.CTX,500,$G(ERR("error"),"run_failed")) Q
	S OBJ("ok")=1,OBJ("jobId")=JOBID,OBJ("redirect")="/efuzy/preview/"_JOBID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIJOBS(DEV,CONF,REQ,CTX)
	N OBJ
	D LISTJSON^EFUWFHIST(.CONF,.REQ,.OBJ)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIJOB(DEV,CONF,REQ,CTX)
	N OBJ,ID
	S ID=$G(REQ("params","id"))
	I '$$GETJSON^EFUWFHIST(.CONF,ID,.OBJ) D RESPERR(.DEV,.CONF,.CTX,404,"job_not_found") Q
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIFILES(DEV,CONF,REQ,CTX)
	N OBJ
	D LISTFILES^EFUZYFS(.CONF,.OBJ)
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIEXPORT(DEV,CONF,REQ,CTX)
	N JOBID,ERR
	S JOBID=$G(REQ("params","jobId"))
	I '$$SEND^EFUWFOUT(.DEV,.CONF,JOBID,.CTX,.ERR) D RESPERR(.DEV,.CONF,.CTX,404,$G(ERR("error"),"export_not_found")) Q
	Q
	;
APIRETRY(DEV,CONF,REQ,CTX)
	N POST,JOBID,NEWID,ERR,OBJ
	D PARSEFORM(.REQ,.POST)
	S JOBID=$G(POST("jobId"))
	I JOBID="" D RESPERR(.DEV,.CONF,.CTX,400,"job_id_required") Q
	I '$$RETRY^EFUZYJOB(.CONF,JOBID,.NEWID,.ERR) D RESPERR(.DEV,.CONF,.CTX,500,$G(ERR("error"),"retry_failed")) Q
	S OBJ("ok")=1,OBJ("jobId")=NEWID,OBJ("redirect")="/efuzy/preview/"_NEWID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIPROFS(DEV,CONF,REQ,CTX)
	N POST,ID,ERR,OBJ
	D PARSEFORM(.REQ,.POST)
	I '$$SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"profile_save_failed")) Q
	S OBJ("ok")=1,OBJ("id")=ID,OBJ("redirect")="/efuzy/profiles/"_ID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIPROFD(DEV,CONF,REQ,CTX)
	N POST,ERR,OBJ
	D PARSEFORM(.REQ,.POST)
	I '$$DELPROF^EFUZYCFG(.CONF,$G(POST("id")),.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"profile_delete_failed")) Q
	S OBJ("ok")=1,OBJ("redirect")="/efuzy/profiles"
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIAUTOS(DEV,CONF,REQ,CTX)
	N POST,ID,ERR,OBJ
	D PARSEFORM(.REQ,.POST)
	I '$$SAVEAUTO^EFUZYCFG(.CONF,.POST,.ID,.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"automation_save_failed")) Q
	S OBJ("ok")=1,OBJ("id")=ID
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
APIAUTOD(DEV,CONF,REQ,CTX)
	N POST,ERR,OBJ
	D PARSEFORM(.REQ,.POST)
	I '$$DELAUTO^EFUZYCFG(.CONF,$G(POST("id")),.ERR) D RESPERR(.DEV,.CONF,.CTX,400,$G(ERR("error"),"automation_delete_failed")) Q
	S OBJ("ok")=1
	D RESPJSONX^MIOHTTP(.DEV,.CONF,200,.OBJ,$G(CTX("request_id")),.CTX)
	Q
	;
PARSEFORM(REQ,OUT)
	K OUT
	I $T(DECODEFORM^MIOFNC)'="" D DECODEFORM^MIOFNC($G(REQ("body")),.OUT) Q
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