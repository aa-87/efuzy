EFUZYUI ; efuzy page context builders
	;
	Q
	;
BUILDWS(CONF,REQ,CTX,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"workspace")
	S TCTX("page","title")="Workspace"
	S TCTX("page","heading")="Workspace"
	S TCTX("page","lead")="Stage files, preview claims, run workflows, and review published jobs."
	D COUNTS(.CONF,.TCTX)
	D LOADHIST(.CONF,.REQ,.TCTX,10,"recent")
	D LOADFILES^EFUZYFS(.CONF,8,.TCTX)
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	D LOADAUTOS^EFUZYCFG(.CONF,.TCTX)
	I $D(TCTX("files",1)) S TCTX("filesAny")=1
	I $D(TCTX("profiles",1)) S TCTX("profilesAny")=1
	I $D(TCTX("automation",1)) S TCTX("automationAny")=1
	D WORKFLOWS(.TCTX)
	Q
	;
BUILDPREV(CONF,REQ,CTX,JOBID,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"workspace")
	S TCTX("page","title")="Preview"
	S TCTX("page","heading")="Preview"
	S TCTX("page","lead")="Review summary counts, diagnostics, sampled claims, service lines, and traceability."
	S TCTX("job","id")=+$G(JOBID)
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	D LOADPREV(.CONF,+$G(JOBID),.TCTX)
	Q
	;
BUILDJOBS(CONF,REQ,CTX,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"jobs")
	S TCTX("page","title")="Jobs"
	S TCTX("page","heading")="Job History"
	S TCTX("page","lead")="Review published workflow runs, filter by status, and open detail pages or downloads."
	D LOADHIST(.CONF,.REQ,.TCTX,50,"jobs")
	Q
	;
BUILDPROFS(CONF,REQ,CTX,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"profiles")
	S TCTX("page","title")="Profiles"
	S TCTX("page","heading")="Export Profiles"
	S TCTX("page","lead")="Save field sets, column order, delimiter settings, and output naming rules."
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	I $D(TCTX("profiles",1)) S TCTX("profilesAny")=1
	D LOADMAPS^EFU837EXPMP(.TCTX)
	Q
	;
BUILDPROF(CONF,REQ,CTX,ID,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"profiles")
	S TCTX("page","title")="Profile"
	S TCTX("page","heading")="Profile Editor"
	S TCTX("page","lead")="Configure export mode, selected fields, headers, quoting, and file naming."
	D LOADPROF^EFUZYCFG(.CONF,ID,.TCTX)
	D LOADMAPS^EFU837EXPMP(.TCTX)
	Q
	;
BUILDAUTO(CONF,REQ,CTX,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"automation")
	S TCTX("page","title")="Automation"
	S TCTX("page","heading")="Automation"
	S TCTX("page","lead")="Bind folders, choose a profile, and define success and failure handling rules."
	D LOADAUTOS^EFUZYCFG(.CONF,.TCTX)
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	I $D(TCTX("automation",1)) S TCTX("automationAny")=1
	I $D(TCTX("profiles",1)) S TCTX("profilesAny")=1
	Q
	;
BUILDJOB(CONF,REQ,CTX,ID,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"jobs")
	S TCTX("page","title")="Job Detail"
	S TCTX("page","heading")="Job Detail"
	S TCTX("page","lead")="Inspect artifacts, diagnostics, preview data, and trace rows for a completed or failed job."
	S TCTX("job","id")=+$G(ID)
	D LOADJOB(.CONF,+$G(ID),.TCTX)
	Q
	;
BASE(TCTX)
	K TCTX
	S TCTX("app","name")="efuzy"
	S TCTX("app","tagline")="Self-hosted file-processing workflow workspace"
	S TCTX("theme","mode")="dark"
	S TCTX("nav",1,"key")="workspace"
	S TCTX("nav",1,"label")="Workspace"
	S TCTX("nav",1,"href")="/efuzy/workspace"
	S TCTX("nav",2,"key")="jobs"
	S TCTX("nav",2,"label")="Jobs"
	S TCTX("nav",2,"href")="/efuzy/jobs"
	S TCTX("nav",3,"key")="profiles"
	S TCTX("nav",3,"label")="Profiles"
	S TCTX("nav",3,"href")="/efuzy/profiles"
	S TCTX("nav",4,"key")="automation"
	S TCTX("nav",4,"label")="Automation"
	S TCTX("nav",4,"href")="/efuzy/automation"
	S TCTX("badges","mvp")="837 → CSV"
	Q
	;
ACT(TCTX,KEY)
	N I
	S I=0
	F  S I=$O(TCTX("nav",I)) Q:'I  S TCTX("nav",I,"isActive")=$S($G(TCTX("nav",I,"key"))=$G(KEY):1,1:0)
	Q
	;
COUNTS(CONF,TCTX)
	S TCTX("summarycards",1,"label")="Queued Jobs"
	S TCTX("summarycards",1,"value")=$$COUNTIDX("queued")
	S TCTX("summarycards",2,"label")="Running Jobs"
	S TCTX("summarycards",2,"value")=$$COUNTIDX("running")
	S TCTX("summarycards",3,"label")="Completed Jobs"
	S TCTX("summarycards",3,"value")=$$COUNTIDX("completed")
	S TCTX("summarycards",4,"label")="Staged Files"
	S TCTX("summarycards",4,"value")=$$FILECOUNT()
	Q
	;
COUNTIDX(STATUS)
	N C,ID
	S C=0,ID=0
	F  S ID=$O(^MIO("EFUZY","idx","job","status",STATUS,ID)) Q:'ID  S C=C+1
	Q C
	;
FILECOUNT()
	N C,ID
	S C=0,ID=0
	F  S ID=$O(^MIO("EFUZY","file",ID)) Q:'ID  S C=C+1
	Q C
	;
WORKFLOWS(TCTX)
	S TCTX("workflow",1,"name")="X12 837 → configurable CSV"
	S TCTX("workflow",1,"desc")="Preview claims and lines, export canonical CSV, and optionally rebuild deterministic X12."
	S TCTX("workflow",2,"name")="Watched folder automation"
	S TCTX("workflow",2,"desc")="Bind input, output, archive, and failure folders to a saved profile for repeatable processing."
	Q
	;
LOADHIST(CONF,REQ,TCTX,LIMIT,MODE)
	N ROOT,OPT,RES,N
	S ROOT=$NA(^TMP($J,"EFUZYUI","history",$H,$R(999999)))
	S OPT("limit")=+$G(LIMIT)
	S OPT("status")=$G(REQ("query","status"))
	S OPT("workflow")=$G(REQ("query","workflow"))
	S OPT("start_after")=+$G(REQ("query","start_after"))
	D HISTORY^EFUX12WEB(ROOT,.OPT,.RES)
	S TCTX("filter","status")=$G(OPT("status"))
	S TCTX("filter","workflow")=$G(OPT("workflow"))
	S TCTX("filter","start_after")=$G(OPT("start_after"))
	S N=0
	F  S N=$O(@ROOT@("response","job",N)) Q:'N  D
	. I $G(MODE)="recent" D
	. . M TCTX("recentJobs",N)=@ROOT@("response","job",N)
	. . S TCTX("recentJobs",N,"href")="/efuzy/preview/"_+$G(@ROOT@("response","job",N,"jobid"))
	. . S TCTX("recentJobs",N,"detailHref")="/efuzy/jobs/"_+$G(@ROOT@("response","job",N,"jobid"))
	. E  D
	. . M TCTX("jobs",N)=@ROOT@("response","job",N)
	. . S TCTX("jobs",N,"href")="/efuzy/jobs/"_+$G(@ROOT@("response","job",N,"jobid"))
	S TCTX("history","count")=+$G(@ROOT@("response","jobs"))
	I $D(TCTX("recentJobs",1)) S TCTX("recentAny")=1
	I $D(TCTX("jobs",1)) S TCTX("jobsAny")=1
	I '$D(TCTX("recentJobs")),$G(MODE)="recent" S TCTX("recentEmpty")=1
	I '$D(TCTX("jobs")),$G(MODE)'="recent" S TCTX("jobsEmpty")=1
	Q
	;
LOADPREV(CONF,JOBID,TCTX)
	N STATUS,FILEID,INPATH,ROOT,OPT,RES,WORKBASE
	I 'JOBID S TCTX("jobMissing")=1 Q
	S STATUS=$G(^MIO("EFUZY","job",JOBID,"status"))
	S FILEID=+$G(^MIO("EFUZY","job",JOBID,"fileId"))
	S INPATH=$$GETPATH^EFUZYFS(FILEID)
	S TCTX("job","fileId")=FILEID
	S TCTX("job","inputPath")=INPATH
	S TCTX("job","status")=STATUS
	I STATUS="completed"!(STATUS="failed") D  Q
	. D LOADJOB(.CONF,JOBID,.TCTX)
	I INPATH="" S TCTX("jobMissing")=1 Q
	S ROOT=$NA(^TMP($J,"EFUZYUI","preview",JOBID,$H,$R(999999)))
	S OPT("trace")=1
	S WORKBASE=$$WORKBASE^EFUZY(.CONF,JOBID,FILEID,"preview")
	D PREVIEW837^EFUX12WEB(INPATH,WORKBASE,ROOT,.OPT,.RES)
	D ADAPT(ROOT,.TCTX,JOBID,0)
	S TCTX("job","status")=$S(STATUS'="":STATUS,1:"queued")
	S TCTX("job","canRun")=1
	S TCTX("job","previewTransient")=1
	Q
	;
LOADJOB(CONF,JOBID,TCTX)
	N ROOT,OPT,RES
	I 'JOBID S TCTX("jobMissing")=1 Q
	S ROOT=$NA(^TMP($J,"EFUZYUI","detail",JOBID,$H,$R(999999)))
	S OPT("include_trace")=1
	D DETAIL^EFUX12WEB(JOBID,ROOT,.OPT,.RES)
	I '+$G(RES("ok")),$G(RES("http_status"))=404 S TCTX("jobMissing")=1 Q
	D ADAPT(ROOT,.TCTX,JOBID,1)
	S TCTX("job","canRun")=$S($G(TCTX("job","status"))'="running":1,1:0)
	Q
	;
ADAPT(ROOT,TCTX,JOBID,DETAIL)
	N RROOT,N,M,KEY,F,IDX
	S RROOT=$NA(@ROOT@("response"))
	S TCTX("job","id")=+$G(JOBID)
	S TCTX("job","status")=$G(@RROOT@("job","status"))
	S TCTX("job","workflow")=$G(@RROOT@("job","workflow"))
	S TCTX("job","inputPath")=$G(@RROOT@("job","input_path"))
	S TCTX("job","diagSummary")=$G(@RROOT@("job","diag_summary"))
	S TCTX("job","compareMode")=$G(@RROOT@("job","compare_mode"))
	S TCTX("job","artifactCount")=+$G(@RROOT@("job","artifact_count"))
	S TCTX("job","ok")=+$G(@RROOT@("ok"))
	S TCTX("job","mode")=$G(@RROOT@("mode"))
	S TCTX("job","isCompleted")=$S($G(@RROOT@("job","status"))="completed":1,1:0)
	S TCTX("job","isFailed")=$S($G(@RROOT@("job","status"))="failed":1,1:0)
	;
	K TCTX("summary")
	S TCTX("summary",1,"label")="Claims"
	S TCTX("summary",1,"value")=+$G(@RROOT@("summary","claims"))
	S TCTX("summary",2,"label")="Lines"
	S TCTX("summary",2,"value")=+$G(@RROOT@("summary","lines"))
	S TCTX("summary",3,"label")="Transactions"
	S TCTX("summary",3,"value")=+$G(@RROOT@("summary","transactions"))
	S TCTX("summary",4,"label")="Warnings"
	S TCTX("summary",4,"value")=+$G(@RROOT@("summary","warnings"),+$G(@RROOT@("diagnostic","warnings")))
	S TCTX("summary",5,"label")="Errors"
	S TCTX("summary",5,"value")=+$G(@RROOT@("summary","errors"),+$G(@RROOT@("diagnostic","errors")))
	S TCTX("summary",6,"label")="Round-trip"
	S TCTX("summary",6,"value")=$S(+$G(@RROOT@("summary","roundtrip_ok")):"ok",1:"n/a")
	;
	S TCTX("summaryData","claims")=+$G(@RROOT@("summary","claims"))
	S TCTX("summaryData","lines")=+$G(@RROOT@("summary","lines"))
	S TCTX("summaryData","transactions")=+$G(@RROOT@("summary","transactions"))
	S TCTX("summaryData","warnings")=+$G(@RROOT@("summary","warnings"),+$G(@RROOT@("diagnostic","warnings")))
	S TCTX("summaryData","errors")=+$G(@RROOT@("summary","errors"),+$G(@RROOT@("diagnostic","errors")))
	S TCTX("summaryData","roundtrip_ok")=+$G(@RROOT@("summary","roundtrip_ok"))
	S TCTX("trace","summary","fields")=+$G(@RROOT@("trace","summary","fields"))
	S TCTX("trace","summary","segments")=+$G(@RROOT@("trace","summary","segments"))
	;
	K TCTX("preview")
	S N=0 F  S N=$O(@RROOT@("preview","claim",N)) Q:'N  M TCTX("preview","claims",N)=@RROOT@("preview","claim",N)
	S N=0 F  S N=$O(@RROOT@("preview","line",N)) Q:'N  M TCTX("preview","lines",N)=@RROOT@("preview","line",N)
	S TCTX("preview","claimCount")=+$G(@RROOT@("preview","claims"),$O(TCTX("preview","claims",""),-1))
	S TCTX("preview","lineCount")=+$G(@RROOT@("preview","lines"),$O(TCTX("preview","lines",""),-1))
	I $D(TCTX("preview","claims",1)) S TCTX("preview","claimsAny")=1
	I $D(TCTX("preview","lines",1)) S TCTX("preview","linesAny")=1
	;
	K TCTX("diagnostic")
	S TCTX("diagnostic","warnings")=+$G(@RROOT@("diagnostic","warnings"))
	S TCTX("diagnostic","errors")=+$G(@RROOT@("diagnostic","errors"))
	F KEY="warning","error" D
	. S N=0
	. F  S N=$O(@RROOT@("diagnostic",KEY,N)) Q:'N  D
	. . M TCTX("diagnostic",KEY,N)=@RROOT@("diagnostic",KEY,N)
	. . I $G(TCTX("diagnostic",KEY,N,"msg"))="" S TCTX("diagnostic",KEY,N,"msg")=$G(TCTX("diagnostic",KEY,N,"message"))
	I $D(TCTX("diagnostic","warning",1)) S TCTX("diagnostic","warningAny")=1
	I $D(TCTX("diagnostic","error",1)) S TCTX("diagnostic","errorAny")=1
	;
	K TCTX("downloads")
	S N=0 F  S N=$O(@RROOT@("download",N)) Q:'N  D
	. M TCTX("downloads",N)=@RROOT@("download",N)
	. S KEY=$G(TCTX("downloads",N,"key"))
	. I +$G(JOBID)>0 S TCTX("downloads",N,"href")="/efuzy/download/"_+JOBID_"/"_KEY
	;
	I $D(TCTX("downloads",1)) S TCTX("downloadsAny")=1
	I '$D(TCTX("downloads",1)) S TCTX("downloadsEmpty")=1
	;
	K TCTX("trace","claim"),TCTX("trace","line")
	S N=0,IDX=0 F  S N=$O(@RROOT@("trace","claim",N)) Q:'N  D
	. S IDX=IDX+1
	. S TCTX("trace","claim",IDX,"cid")=$G(@RROOT@("trace","claim",N,"cid"),N)
	. S M=0,F="" F  S F=$O(@RROOT@("trace","claim",N,"field",F)) Q:F=""  D
	. . S M=M+1
	. . S TCTX("trace","claim",IDX,"field",M,"name")=F
	. . M TCTX("trace","claim",IDX,"field",M)=@RROOT@("trace","claim",N,"field",F)
	S N=0,IDX=0 F  S N=$O(@RROOT@("trace","line",N)) Q:'N  D
	. S IDX=IDX+1
	. S TCTX("trace","line",IDX,"cid")=$G(@RROOT@("trace","line",N,"cid"))
	. S TCTX("trace","line",IDX,"line")=$G(@RROOT@("trace","line",N,"line"),N)
	. S M=0,F="" F  S F=$O(@RROOT@("trace","line",N,"field",F)) Q:F=""  D
	. . S M=M+1
	. . S TCTX("trace","line",IDX,"field",M,"name")=F
	. . M TCTX("trace","line",IDX,"field",M)=@RROOT@("trace","line",N,"field",F)
	I $D(TCTX("trace","claim",1)) S TCTX("trace","claimAny")=1
	I $D(TCTX("trace","line",1)) S TCTX("trace","lineAny")=1
	Q
	;
	;
