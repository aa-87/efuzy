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
	S TCTX("page","lead")="Stage files, inspect recent runs, and move from queued upload to publish-ready X12 837 exports."
	S TCTX("page","eyebrow")="Operations workbench"
	D COUNTS(.CONF,.TCTX)
	D LOADHIST(.CONF,.REQ,.TCTX,10,"recent")
	D LOADFILES^EFUZYFS(.CONF,8,.TCTX)
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	D LOADAUTOS^EFUZYCFG(.CONF,.TCTX)
	I $D(TCTX("files",1)) S TCTX("filesAny")=1
	I $D(TCTX("profiles",1)) S TCTX("profilesAny")=1
	I $D(TCTX("automation",1)) S TCTX("automationAny")=1
	D POSTLIST(.TCTX)
	D WORKFLOWS(.TCTX)
	Q
	;
BUILDPREV(CONF,REQ,CTX,JOBID,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"workspace")
	S TCTX("page","title")="Preview"
	S TCTX("page","heading")="Preview"
	S TCTX("page","lead")="Review sampled claims, service lines, diagnostics, and trace before publishing canonical artifacts."
	S TCTX("page","eyebrow")="Workflow preview"
	S TCTX("job","id")=+$G(JOBID)
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	I $D(TCTX("profiles",1)) S TCTX("profilesAny")=1
	D LOADPREV(.CONF,+$G(JOBID),.TCTX)
	D PREPXP(.TCTX)
	D POSTPREV(.TCTX)
	Q
	;
BUILDJOBS(CONF,REQ,CTX,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"jobs")
	S TCTX("page","title")="Jobs"
	S TCTX("page","heading")="Job History"
	S TCTX("page","lead")="Review published workflow runs, filter by status, and open detail pages or artifact downloads."
	S TCTX("page","eyebrow")="Operational history"
	D LOADHIST(.CONF,.REQ,.TCTX,50,"jobs")
	Q
	;
BUILDPROFS(CONF,REQ,CTX,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"profiles")
	S TCTX("page","title")="Profiles"
	S TCTX("page","heading")="Export Profiles"
	S TCTX("page","lead")="Save field sets, column order, delimiter rules, and output naming for biller-friendly CSV exports."
	S TCTX("page","eyebrow")="Profile catalog"
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	I $D(TCTX("profiles",1)) S TCTX("profilesAny")=1
	D LOADMAPS^EFU837EXPMP(.TCTX)
	D POSTLIST(.TCTX)
	Q
	;
BUILDPROF(CONF,REQ,CTX,ID,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"profiles")
	S TCTX("page","title")="Profile"
	S TCTX("page","heading")="Profile Editor"
	S TCTX("page","lead")="Configure export mode, field selection, quoting, headers, and naming without leaving the SSR workspace."
	S TCTX("page","eyebrow")="Profile design"
	D LOADPROF^EFUZYCFG(.CONF,ID,.TCTX)
	D LOADMAPS^EFU837EXPMP(.TCTX)
	D MODESEL(.TCTX)
	D POSTPROF(.TCTX)
	Q
	;
BUILDAUTO(CONF,REQ,CTX,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"automation")
	S TCTX("page","title")="Automation"
	S TCTX("page","heading")="Automation"
	S TCTX("page","lead")="Bind folders, choose a profile, and define success or failure handling for repeatable watched-folder runs."
	S TCTX("page","eyebrow")="Folder pipelines"
	D LOADAUTOS^EFUZYCFG(.CONF,.TCTX)
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	I $D(TCTX("automation",1)) S TCTX("automationAny")=1
	I $D(TCTX("profiles",1)) S TCTX("profilesAny")=1
	D POSTLIST(.TCTX)
	Q
	;
BUILDJOB(CONF,REQ,CTX,ID,TCTX)
	K TCTX
	D BASE(.TCTX)
	D ACT(.TCTX,"jobs")
	S TCTX("page","title")="Job Detail"
	S TCTX("page","heading")="Job Detail"
	S TCTX("page","lead")="Inspect artifacts, diagnostics, preview data, and trace rows for a completed or failed job."
	S TCTX("page","eyebrow")="Published job"
	S TCTX("job","id")=+$G(ID)
	D LOADPROFL^EFUZYCFG(.CONF,.TCTX)
	I $D(TCTX("profiles",1)) S TCTX("profilesAny")=1
	D LOADJOB(.CONF,+$G(ID),.TCTX)
	D PREPXP(.TCTX)
	D POSTDETAIL(.TCTX)
	Q
	;
BASE(TCTX)
	K TCTX
	S TCTX("app","name")="efuzy"
	S TCTX("app","tagline")="Self-hosted file-processing workflow workspace"
	S TCTX("app","version")="MVP"
	S TCTX("theme","mode")="dark"
	S TCTX("theme","toggleLabel")="Toggle theme"
	S TCTX("shell","eyebrow")="efuzy / MUMPS.IO"
	S TCTX("badges","mvp")="837 to CSV"
	S TCTX("badges","arch")="SSR-first"
	S TCTX("nav",1,"key")="workspace"
	S TCTX("nav",1,"label")="Workspace"
	S TCTX("nav",1,"href")="/efuzy/workspace"
	S TCTX("nav",1,"hint")="Uploads, queues, recent jobs"
	S TCTX("nav",2,"key")="jobs"
	S TCTX("nav",2,"label")="Jobs"
	S TCTX("nav",2,"href")="/efuzy/jobs"
	S TCTX("nav",2,"hint")="Published runs and artifacts"
	S TCTX("nav",3,"key")="profiles"
	S TCTX("nav",3,"label")="Profiles"
	S TCTX("nav",3,"href")="/efuzy/profiles"
	S TCTX("nav",3,"hint")="CSV output definitions"
	S TCTX("nav",4,"key")="automation"
	S TCTX("nav",4,"label")="Automation"
	S TCTX("nav",4,"href")="/efuzy/automation"
	S TCTX("nav",4,"hint")="Folder-driven workflows"
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
	S TCTX("summarycards",1,"tone")="tone-amber"
	S TCTX("summarycards",2,"label")="Running Jobs"
	S TCTX("summarycards",2,"value")=$$COUNTIDX("running")
	S TCTX("summarycards",2,"tone")="tone-sky"
	S TCTX("summarycards",3,"label")="Completed Jobs"
	S TCTX("summarycards",3,"value")=$$COUNTIDX("completed")
	S TCTX("summarycards",3,"tone")="tone-emerald"
	S TCTX("summarycards",4,"label")="Staged Files"
	S TCTX("summarycards",4,"value")=$$FILECOUNT()
	S TCTX("summarycards",4,"tone")="tone-violet"
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
	S TCTX("workflow",1,"desc")="Preview claims and service lines, export canonical CSV, and optionally rebuild deterministic X12."
	S TCTX("workflow",1,"tag")="Primary MVP"
	S TCTX("workflow",2,"name")="Published job artifacts"
	S TCTX("workflow",2,"desc")="Keep canonical claims, canonical lines, manifests, round-trip output, and trace in one operator-facing job record."
	S TCTX("workflow",2,"tag")="Artifact contract"
	S TCTX("workflow",3,"name")="Watched folder automation"
	S TCTX("workflow",3,"desc")="Bind input, output, archive, and failure folders to a saved profile for repeatable processing."
	S TCTX("workflow",3,"tag")="No heavy SPA"
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
	. . D HISTSUP(+$G(TCTX("recentJobs",N,"jobid")),$NA(TCTX("recentJobs",N)))
	. . S TCTX("recentJobs",N,"href")="/efuzy/preview/"_+$G(@ROOT@("response","job",N,"jobid"))
	. . S TCTX("recentJobs",N,"detailHref")="/efuzy/jobs/"_+$G(@ROOT@("response","job",N,"jobid"))
	. . D STATUSMETA($NA(TCTX("recentJobs",N)))
	. E  D
	. . M TCTX("jobs",N)=@ROOT@("response","job",N)
	. . D HISTSUP(+$G(TCTX("jobs",N,"jobid")),$NA(TCTX("jobs",N)))
	. . S TCTX("jobs",N,"href")="/efuzy/jobs/"_+$G(@ROOT@("response","job",N,"jobid"))
	. . S TCTX("jobs",N,"previewHref")="/efuzy/preview/"_+$G(@ROOT@("response","job",N,"jobid"))
	. . D STATUSMETA($NA(TCTX("jobs",N)))
	S TCTX("history","count")=+$G(@ROOT@("response","jobs"))
	I $D(TCTX("recentJobs",1)) S TCTX("recentAny")=1
	I $D(TCTX("jobs",1)) S TCTX("jobsAny")=1
	I '$D(TCTX("recentJobs")),$G(MODE)="recent" S TCTX("recentEmpty")=1
	I '$D(TCTX("jobs")),$G(MODE)'="recent" S TCTX("jobsEmpty")=1
	Q
	;
LOADPREV(CONF,JOBID,TCTX)
	N STATUS,FILEID,INPATH,ROOT,OPT,RES,WORKBASE,LERR
	I 'JOBID S TCTX("jobMissing")=1 Q
	S STATUS=$G(^MIO("EFUZY","job",JOBID,"status"))
	S FILEID=+$G(^MIO("EFUZY","job",JOBID,"fileId"))
	S INPATH=$$GETPATH^EFUZYFS(FILEID)
	S TCTX("job","fileId")=FILEID
	S TCTX("job","inputPath")=INPATH
	S TCTX("job","status")=STATUS
	S TCTX("job","fileName")=$$GETNAME^EFUZYFS(FILEID)
	S TCTX("job","profileId")=+$G(^MIO("EFUZY","job",JOBID,"profileId"))
	I STATUS="completed"!(STATUS="failed") D  Q
	. D LOADJOB(.CONF,JOBID,.TCTX)
	. D TOPUPPREV(JOBID,.TCTX)
	I INPATH="" S TCTX("jobMissing")=1 Q
	S ROOT=$NA(^TMP($J,"EFUZYUI","preview",JOBID,$H,$R(999999)))
	S OPT("trace")=1
	S WORKBASE=$$WORKBASE^EFUZY(.CONF,JOBID,FILEID,"preview")
	D PREVIEW837^EFUX12WEB(INPATH,WORKBASE,ROOT,.OPT,.RES)
	I +$G(RES("ok")) D ADAPT(ROOT,.TCTX,JOBID,0)
	E  D
	. I $$PARSE^EFU837(INPATH,JOBID,.LERR) D PREVLEG(JOBID,.TCTX) Q
	. S TCTX("job","previewError")=$G(LERR("error"),"parse_failed")
	S TCTX("job","status")=$S(STATUS'="":STATUS,1:"queued")
	S TCTX("job","canRun")=1
	S TCTX("job","previewTransient")=1
	D STATUSMETA($NA(TCTX("job")))
	D POSTPREV(.TCTX)
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
	D STATUSMETA($NA(TCTX("job")))
	D POSTDETAIL(.TCTX)
	Q
	;
ADAPT(ROOT,TCTX,JOBID,DETAIL)
	N RROOT,N,M,KEY,F,IDX,RT,WT,ET
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
	S TCTX("job","profileId")=+$G(^MIO("EFUZY","job",JOBID,"profileId"))
	S TCTX("job","buildRebuilt")=+$G(^MIO("EFUZY","job",JOBID,"build_rebuilt"),+$G(@RROOT@("job","build_rebuilt"),1))
	S TCTX("job","roundtrip")=+$G(^MIO("EFUZY","job",JOBID,"roundtrip"),+$G(@RROOT@("job","roundtrip")))
	S TCTX("job","trace")=+$G(^MIO("EFUZY","job",JOBID,"trace"),1)
	S TCTX("job","isCompleted")=$S($G(@RROOT@("job","status"))="completed":1,1:0)
	S TCTX("job","isFailed")=$S($G(@RROOT@("job","status"))="failed":1,1:0)
	K TCTX("summary")
	S WT=+$G(@RROOT@("summary","warnings"),+$G(@RROOT@("diagnostic","warnings")))
	S ET=+$G(@RROOT@("summary","errors"),+$G(@RROOT@("diagnostic","errors")))
	S RT=+$G(@RROOT@("summary","roundtrip_ok"))
	S TCTX("summary",1,"label")="Claims"
	S TCTX("summary",1,"value")=+$G(@RROOT@("summary","claims"))
	S TCTX("summary",1,"tone")="tone-slate"
	S TCTX("summary",2,"label")="Lines"
	S TCTX("summary",2,"value")=+$G(@RROOT@("summary","lines"))
	S TCTX("summary",2,"tone")="tone-slate"
	S TCTX("summary",3,"label")="Transactions"
	S TCTX("summary",3,"value")=+$G(@RROOT@("summary","transactions"))
	S TCTX("summary",3,"tone")="tone-slate"
	S TCTX("summary",4,"label")="Warnings"
	S TCTX("summary",4,"value")=WT
	S TCTX("summary",4,"tone")=$S(WT>0:"tone-amber",1:"tone-slate")
	S TCTX("summary",5,"label")="Errors"
	S TCTX("summary",5,"value")=ET
	S TCTX("summary",5,"tone")=$S(ET>0:"tone-rose",1:"tone-slate")
	S TCTX("summary",6,"label")="Round-trip"
	S TCTX("summary",6,"value")=$S(RT:"ok",1:"n/a")
	S TCTX("summary",6,"tone")=$S(RT:"tone-emerald",1:"tone-slate")
	S TCTX("summaryData","claims")=+$G(@RROOT@("summary","claims"))
	S TCTX("summaryData","lines")=+$G(@RROOT@("summary","lines"))
	S TCTX("summaryData","transactions")=+$G(@RROOT@("summary","transactions"))
	S TCTX("summaryData","warnings")=WT
	S TCTX("summaryData","errors")=ET
	S TCTX("summaryData","roundtrip_ok")=RT
	S TCTX("trace","summary","fields")=+$G(@RROOT@("trace","summary","fields"))
	S TCTX("trace","summary","segments")=+$G(@RROOT@("trace","summary","segments"))
	K TCTX("preview")
	S N=0 F  S N=$O(@RROOT@("preview","claim",N)) Q:'N  M TCTX("preview","claims",N)=@RROOT@("preview","claim",N)
	S N=0 F  S N=$O(@RROOT@("preview","line",N)) Q:'N  M TCTX("preview","lines",N)=@RROOT@("preview","line",N)
	S TCTX("preview","claimCount")=+$G(@RROOT@("preview","claims"),$O(TCTX("preview","claims",""),-1))
	S TCTX("preview","lineCount")=+$G(@RROOT@("preview","lines"),$O(TCTX("preview","lines",""),-1))
	I $D(TCTX("preview","claims",1)) S TCTX("preview","claimsAny")=1
	I $D(TCTX("preview","lines",1)) S TCTX("preview","linesAny")=1
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
	K TCTX("downloads")
	S N=0 F  S N=$O(@RROOT@("download",N)) Q:'N  D
	. M TCTX("downloads",N)=@RROOT@("download",N)
	. S KEY=$G(TCTX("downloads",N,"key"))
	. I +$G(JOBID)>0 S TCTX("downloads",N,"href")="/efuzy/download/"_+JOBID_"/"_KEY
	. D DLMETA($NA(TCTX("downloads",N)))
	I $D(TCTX("downloads",1)) S TCTX("downloadsAny")=1
	I '$D(TCTX("downloads",1)) S TCTX("downloadsEmpty")=1
	K TCTX("trace","claim"),TCTX("trace","line")
	S N=0,IDX=0 F  S N=$O(@RROOT@("trace","claim",N)) Q:'N  D
	. S IDX=IDX+1
	. S TCTX("trace","claim",IDX,"cid")=$G(@RROOT@("trace","claim",N,"cid"),N)
	. S M=0,F="" F  S F=$O(@RROOT@("trace","claim",N,"field",F)) Q:F=""  D
	. . S M=M+1
	. . S TCTX("trace","claim",IDX,"field",M,"name")=F
	. . M TCTX("trace","claim",IDX,"field",M)=@RROOT@("trace","claim",N,"field",F)
	. . D TRACEF($NA(TCTX("trace","claim",IDX,"field",M)))
	S N=0,IDX=0 F  S N=$O(@RROOT@("trace","line",N)) Q:'N  D
	. S IDX=IDX+1
	. S TCTX("trace","line",IDX,"cid")=$G(@RROOT@("trace","line",N,"cid"))
	. S TCTX("trace","line",IDX,"line")=$G(@RROOT@("trace","line",N,"line"),N)
	. S M=0,F="" F  S F=$O(@RROOT@("trace","line",N,"field",F)) Q:F=""  D
	. . S M=M+1
	. . S TCTX("trace","line",IDX,"field",M,"name")=F
	. . M TCTX("trace","line",IDX,"field",M)=@RROOT@("trace","line",N,"field",F)
	. . D TRACEF($NA(TCTX("trace","line",IDX,"field",M)))
	I $D(TCTX("trace","claim",1)) S TCTX("trace","claimAny")=1
	I $D(TCTX("trace","line",1)) S TCTX("trace","lineAny")=1
	D LEGSUP(JOBID,.TCTX)
	D STATUSMETA($NA(TCTX("job")))
	D POSTPREV(.TCTX)
	Q
	;
HISTSUP(JOBID,REF)
	I 'JOBID Q
	I +$G(@REF@("claims"))<1 S @REF@("claims")=+$G(^MIO("EFUZY","job",JOBID,"stats","claimCount"))
	I +$G(@REF@("lines"))<1 S @REF@("lines")=+$G(^MIO("EFUZY","job",JOBID,"stats","serviceLineCount"))
	I $G(@REF@("diag_summary"))="" S @REF@("diag_summary")=$G(^MIO("EFUZY","job",JOBID,"diagSummary"))
	Q
	;
LEGSUP(JOBID,TCTX)
	N N,W,E
	I 'JOBID Q
	D HISTSUP(JOBID,$NA(TCTX("summaryData")))
	I +$G(TCTX("summaryData","claims"))<1 S TCTX("summaryData","claims")=+$G(^MIO("EFUZY","job",JOBID,"stats","claimCount"))
	I +$G(TCTX("summaryData","lines"))<1 S TCTX("summaryData","lines")=+$G(^MIO("EFUZY","job",JOBID,"stats","serviceLineCount"))
	I +$G(TCTX("summaryData","transactions"))<1 S TCTX("summaryData","transactions")=+$G(^MIO("EFUZY","job",JOBID,"stats","transactions"))
	S W=+$G(^MIO("EFUZY","job",JOBID,"warningCount"))
	S E=+$G(^MIO("EFUZY","job",JOBID,"errorCount"))
	I +$G(TCTX("summaryData","warnings"))<1 S TCTX("summaryData","warnings")=W
	I +$G(TCTX("summaryData","errors"))<1 S TCTX("summaryData","errors")=E
	S TCTX("summary",1,"value")=+$G(TCTX("summaryData","claims"))
	S TCTX("summary",2,"value")=+$G(TCTX("summaryData","lines"))
	S TCTX("summary",3,"value")=+$G(TCTX("summaryData","transactions"))
	S TCTX("summary",4,"value")=+$G(TCTX("summaryData","warnings"))
	S TCTX("summary",4,"tone")=$S(+$G(TCTX("summaryData","warnings"))>0:"tone-amber",1:"tone-slate")
	S TCTX("summary",5,"value")=+$G(TCTX("summaryData","errors"))
	S TCTX("summary",5,"tone")=$S(+$G(TCTX("summaryData","errors"))>0:"tone-rose",1:"tone-slate")
	I '$G(TCTX("downloadsAny")),$G(^MIO("EFUZY","job",JOBID,"outputPath"))'="" D
	. S TCTX("downloads",1,"key")="profile_export"
	. S TCTX("downloads",1,"name")=$G(^MIO("EFUZY","job",JOBID,"outputName"))
	. I TCTX("downloads",1,"name")="" S TCTX("downloads",1,"name")=$P($G(^MIO("EFUZY","job",JOBID,"outputPath")),"/",$L($G(^MIO("EFUZY","job",JOBID,"outputPath")),"/"))
	. S TCTX("downloads",1,"path")=$G(^MIO("EFUZY","job",JOBID,"outputPath"))
	. S TCTX("downloads",1,"type")="csv"
	. S TCTX("downloads",1,"href")="/efuzy/download/"_JOBID_"/profile_export"
	. D DLMETA($NA(TCTX("downloads",1)))
	. S TCTX("downloadsAny")=1
	. K TCTX("downloadsEmpty")
	D TOPUPPREV(JOBID,.TCTX)
	I '$G(TCTX("diagnostic","warningAny")),'$G(TCTX("diagnostic","errorAny")) D LEGDIAG(JOBID,.TCTX)
	I $G(^MIO("EFUZY","job",JOBID,"compat","parser"))'="" S TCTX("job","compatLegacy")=1
	Q
	;
PREVLEG(JOBID,TCTX)
	N I,N,L,F,SRC
	I +$G(TCTX("preview","claimCount"))<1 S TCTX("preview","claimCount")=+$G(^MIO("EFUZY","job",JOBID,"stats","claimCount"),+$G(^MIO("EFUZY","job",JOBID,"stats","claims")))
	I +$G(TCTX("preview","lineCount"))<1 S TCTX("preview","lineCount")=+$G(^MIO("EFUZY","job",JOBID,"stats","serviceLineCount"),+$G(^MIO("EFUZY","job",JOBID,"stats","lines")))
	I ('$G(TCTX("preview","claimsAny")))!($G(TCTX("preview","claims",1,"claim_id"))="") D
	. K TCTX("preview","claims")
	. S N=0,I=0,SRC="preview"
	. I '$D(^MIO("EFUZY","job",JOBID,"preview","claim",1)) S SRC="wrk"
	. F  S I=$O(^MIO("EFUZY","job",JOBID,SRC,"claim",I)) Q:'I!(N>=8)  D
	. . S N=N+1
	. . S TCTX("preview","claims",N,"claim_id")=$G(^MIO("EFUZY","job",JOBID,SRC,"claim",I,"claim_id"))
	. . S L=$G(^MIO("EFUZY","job",JOBID,SRC,"claim",I,"patient_last"))
	. . S F=$G(^MIO("EFUZY","job",JOBID,SRC,"claim",I,"patient_first"))
	. . I L="",F="" S TCTX("preview","claims",N,"patient_name")=$G(^MIO("EFUZY","job",JOBID,SRC,"claim",I,"patient_name"))
	. . E  S TCTX("preview","claims",N,"patient_name")=$$COMB(L,F)
	. . S L=$G(^MIO("EFUZY","job",JOBID,SRC,"claim",I,"subscriber_last"))
	. . S F=$G(^MIO("EFUZY","job",JOBID,SRC,"claim",I,"subscriber_first"))
	. . I L="",F="" S TCTX("preview","claims",N,"subscriber_name")=$G(^MIO("EFUZY","job",JOBID,SRC,"claim",I,"subscriber_name"))
	. . E  S TCTX("preview","claims",N,"subscriber_name")=$$COMB(L,F)
	. . S TCTX("preview","claims",N,"primary_payer_name")=$G(^MIO("EFUZY","job",JOBID,SRC,"claim",I,"payer_name"),$G(^MIO("EFUZY","job",JOBID,SRC,"claim",I,"primary_payer_name")))
	. . S TCTX("preview","claims",N,"total_charge")=$G(^MIO("EFUZY","job",JOBID,SRC,"claim",I,"total_charge"))
	I ('$G(TCTX("preview","linesAny")))!($G(TCTX("preview","lines",1,"procedure_code"))="") D
	. K TCTX("preview","lines")
	. S N=0,I=0,SRC="preview"
	. I '$D(^MIO("EFUZY","job",JOBID,"preview","line",1)) S SRC="wrk"
	. F  S I=$O(^MIO("EFUZY","job",JOBID,SRC,"line",I)) Q:'I!(N>=12)  D
	. . S N=N+1
	. . S TCTX("preview","lines",N,"claim_id")=$G(^MIO("EFUZY","job",JOBID,SRC,"line",I,"claim_id"))
	. . S TCTX("preview","lines",N,"line_no")=$G(^MIO("EFUZY","job",JOBID,SRC,"line",I,"line_number"),$G(^MIO("EFUZY","job",JOBID,SRC,"line",I,"line_no")))
	. . S TCTX("preview","lines",N,"procedure_code")=$G(^MIO("EFUZY","job",JOBID,SRC,"line",I,"procedure_code"))
	. . S TCTX("preview","lines",N,"charge")=$G(^MIO("EFUZY","job",JOBID,SRC,"line",I,"line_charge"),$G(^MIO("EFUZY","job",JOBID,SRC,"line",I,"charge")))
	. . S TCTX("preview","lines",N,"svc_date")=$G(^MIO("EFUZY","job",JOBID,SRC,"line",I,"line_service_date"),$G(^MIO("EFUZY","job",JOBID,SRC,"line",I,"svc_date")))
	I $D(TCTX("preview","claims",1)) S TCTX("preview","claimsAny")=1
	I $D(TCTX("preview","lines",1)) S TCTX("preview","linesAny")=1
	I +$G(TCTX("preview","claimCount"))<1 S TCTX("preview","claimCount")=$O(TCTX("preview","claims",""),-1)
	I +$G(TCTX("preview","lineCount"))<1 S TCTX("preview","lineCount")=$O(TCTX("preview","lines",""),-1)
	S TCTX("job","compatLegacy")=1
	Q
	;
TOPUPPREV(JOBID,TCTX)
	I 'JOBID Q
	I '$G(TCTX("preview","claimsAny")) D PREVLEG(JOBID,.TCTX) Q
	I $G(TCTX("preview","claims",1,"claim_id"))="" D PREVLEG(JOBID,.TCTX) Q
	I '$G(TCTX("preview","linesAny")) D PREVLEG(JOBID,.TCTX) Q
	I $G(TCTX("preview","lines",1,"procedure_code"))="" D PREVLEG(JOBID,.TCTX)
	Q
	;
COMB(L,F)
	Q $G(L)_$S($G(L)'=""&($G(F)'=""):", ",1:"")_$G(F)
	;
LEGDIAG(JOBID,TCTX)
	N TYPE,N,OUT,LIM
	S LIM=25
	F TYPE="warning","error" D
	. S N=0,OUT=0
	. F  S N=$O(^MIO("EFUZY","job",JOBID,"diag",TYPE,N)) Q:'N!(OUT>=LIM)  D
	. . S OUT=OUT+1
	. . S TCTX("diagnostic",TYPE,OUT,"msg")=$G(^MIO("EFUZY","job",JOBID,"diag",TYPE,N))
	. S TCTX("diagnostic",TYPE_"s")=OUT
	. I OUT>0 S TCTX("diagnostic",TYPE_"Any")=1
	S TCTX("diagnostic","warnings")=+$G(^MIO("EFUZY","job",JOBID,"warningCount"))
	S TCTX("diagnostic","errors")=+$G(^MIO("EFUZY","job",JOBID,"errorCount"))
	Q
	;
STATUSMETA(REF)
	N ST,LBL,TN
	S ST=$ZCONVERT($G(@REF@("status")),"L")
	I ST="" S ST="queued"
	S LBL=$$STATUSLBL(ST)
	S TN=$$STATUSTN(ST)
	S @REF@("status")=ST
	S @REF@("statusLabel")=LBL
	S @REF@("statusTone")=TN
	S @REF@("isQueued")=$S(ST="queued":1,1:0)
	S @REF@("isRunning")=$S(ST="running":1,1:0)
	S @REF@("isCompleted")=$S(ST="completed":1,1:0)
	S @REF@("isFailed")=$S(ST="failed":1,1:0)
	Q
	;
STATUSLBL(ST)
	I $G(ST)="completed" Q "Completed"
	I $G(ST)="failed" Q "Failed"
	I $G(ST)="running" Q "Running"
	I $G(ST)="queued" Q "Queued"
	Q $$UP($G(ST))
	;
STATUSTN(ST)
	I $G(ST)="completed" Q "badge-emerald"
	I $G(ST)="failed" Q "badge-rose"
	I $G(ST)="running" Q "badge-sky"
	I $G(ST)="queued" Q "badge-amber"
	Q "badge-slate"
	;
DLMETA(REF)
	N K,T
	S K=$G(@REF@("key"))
	S T=$G(@REF@("type"))
	S @REF@("badge")=$S(K["canonical":"Canonical",K["rebuilt":"Rebuilt",K["roundtrip":"Round-trip",K["trace":"Trace",1:"Artifact")
	S @REF@("tone")=$S(K["canonical":"tone-sky",K["rebuilt":"tone-emerald",K["roundtrip":"tone-violet",K["trace":"tone-amber",1:"tone-slate")
	I $G(@REF@("name"))="" S @REF@("name")=$S(K'="":K,1:"download")
	I $G(@REF@("type"))="" S @REF@("type")=$S(K["x12":"edi",1:"file")
	Q
	;
TRACEF(REF)
	S @REF@("exactLabel")=$S(+$G(@REF@("exact")):"Exact",1:"Best effort")
	S @REF@("exactTone")=$S(+$G(@REF@("exact")):"badge-emerald",1:"badge-amber")
	Q
	;
PREPXP(TCTX)
	N PID,N,KEY,IDX,GROUP,REF
	S PID=+$G(TCTX("job","profileId"))
	S TCTX("job","profileId")=PID
	S TCTX("job","hasProfile")=$S(PID>0:1,1:0)
	S TCTX("job","buildRebuiltOn")=$S(+$G(TCTX("job","buildRebuilt"),1):1,1:0)
	S TCTX("job","roundtripOn")=$S(+$G(TCTX("job","roundtrip")):1,1:0)
	S TCTX("job","traceOn")=$S(+$G(TCTX("job","trace"),1):1,1:0)
	S TCTX("job","buildRebuiltChecked")=$S(+$G(TCTX("job","buildRebuilt"),1):"checked",1:"")
	S TCTX("job","roundtripChecked")=$S(+$G(TCTX("job","roundtrip")):"checked",1:"")
	S TCTX("job","traceChecked")=$S(+$G(TCTX("job","trace"),1):"checked",1:"")
	S TCTX("job","compareExportSafe")=$S($G(TCTX("job","compareMode"),"export_safe")="export_safe":"selected",1:"")
	S TCTX("job","compareStrict")=$S($G(TCTX("job","compareMode"))="strict":"selected",1:"")
	S TCTX("job","compareLenient")=$S($G(TCTX("job","compareMode"))="lenient":"selected",1:"")
	S N=0
	F  S N=$O(TCTX("profiles",N)) Q:'N  D
	. S TCTX("profiles",N,"fieldCount")=$$CSVCT($G(TCTX("profiles",N,"selectedFields")))
	. S TCTX("profiles",N,"modeLabel")=$$UP($TR($G(TCTX("profiles",N,"exportMode")),"_"," "))
	. S TCTX("profiles",N,"rowSource")=$S($G(TCTX("profiles",N,"exportMode"))'="":$$ROWSRC^EFU837EXPMP($G(TCTX("profiles",N,"exportMode"))),1:$G(TCTX("profiles",N,"rowSource")))
	. S TCTX("profiles",N,"selectedAttr")=""
	. S TCTX("profiles",N,"selectedBadge")=""
	. I PID>0,+$G(TCTX("profiles",N,"id"))=PID D
	. . S TCTX("profiles",N,"selectedAttr")="selected"
	. . S TCTX("profiles",N,"selectedBadge")="Current"
	. S TCTX("profiles",N,"rowSourceLabel")=$$UP($G(TCTX("profiles",N,"rowSource")))
	. I $G(TCTX("profiles",N,"rowSourceLabel"))="" S TCTX("profiles",N,"rowSourceLabel")="Claim"
	I PID>0 D
	. S N=0
	. F  S N=$O(TCTX("profiles",N)) Q:'N  I +$G(TCTX("profiles",N,"id"))=PID D  Q
	. . M TCTX("selectedProfile")=TCTX("profiles",N)
	. . S TCTX("selectedProfileAny")=1
	. . S TCTX("selectedProfile","fieldSummary")=$G(TCTX("profiles",N,"fieldCount"))_" fields"
	. . S TCTX("selectedProfile","modeText")=$G(TCTX("profiles",N,"modeLabel"))
	. . S TCTX("selectedProfile","href")="/efuzy/profiles/"_PID
	I '$G(TCTX("selectedProfileAny")),$D(TCTX("profiles",1)) D
	. M TCTX("selectedProfile")=TCTX("profiles",1)
	. S TCTX("selectedProfile","fieldSummary")=$G(TCTX("profiles",1,"fieldCount"))_" fields"
	. S TCTX("selectedProfile","modeText")=$G(TCTX("profiles",1,"modeLabel"))
	. S TCTX("selectedProfile","href")="/efuzy/profiles/"_+$G(TCTX("profiles",1,"id"))
	. S TCTX("selectedProfile","suggested")=1
	. S TCTX("selectedProfileSuggested")=1
	K TCTX("exportPlan")
	S TCTX("exportPlan",1,"name")="Canonical claims CSV"
	S TCTX("exportPlan",1,"desc")="Stable claim-level package for downstream loads and audit-safe comparison."
	S TCTX("exportPlan",1,"badge")="Always"
	S TCTX("exportPlan",1,"tone")="tone-sky"
	S TCTX("exportPlan",2,"name")="Canonical lines CSV"
	S TCTX("exportPlan",2,"desc")="Normalized service-line rows for analytics, QA, and reload operations."
	S TCTX("exportPlan",2,"badge")="Always"
	S TCTX("exportPlan",2,"tone")="tone-sky"
	S TCTX("exportPlan",3,"name")="Canonical manifest"
	S TCTX("exportPlan",3,"desc")="Package summary with counts, mode, and artifact references."
	S TCTX("exportPlan",3,"badge")="Always"
	S TCTX("exportPlan",3,"tone")="tone-slate"
	S TCTX("exportPlan",4,"name")=$S($G(TCTX("selectedProfileAny")):$G(TCTX("selectedProfile","name"))_" profile CSV",1:"Profile CSV output")
	S TCTX("exportPlan",4,"desc")=$S($G(TCTX("selectedProfileAny")):"Biller-facing export using "_$G(TCTX("selectedProfile","modeText"))_" with "_$G(TCTX("selectedProfile","fieldSummary"))_".",1:"Select a saved profile to publish an operator-facing CSV alongside canonical outputs.")
	S TCTX("exportPlan",4,"badge")=$S($G(TCTX("selectedProfileAny")):"Selected",1:"Optional")
	S TCTX("exportPlan",4,"tone")=$S($G(TCTX("selectedProfileAny")):"tone-violet",1:"tone-slate")
	S TCTX("exportPlan",5,"name")="Rebuilt deterministic X12"
	S TCTX("exportPlan",5,"desc")="Useful for writer validation and deterministic round-trip inspection."
	S TCTX("exportPlan",5,"badge")=$S($G(TCTX("job","buildRebuiltOn")):"On",1:"Optional")
	S TCTX("exportPlan",5,"tone")=$S($G(TCTX("job","buildRebuiltOn")):"tone-emerald",1:"tone-slate")
	S TCTX("exportPlan",6,"name")="Round-trip report"
	S TCTX("exportPlan",6,"desc")="Compare canonical output against rebuilt X12 for deterministic pipeline checks."
	S TCTX("exportPlan",6,"badge")=$S($G(TCTX("job","roundtripOn")):"On",1:"Optional")
	S TCTX("exportPlan",6,"tone")=$S($G(TCTX("job","roundtripOn")):"tone-violet",1:"tone-slate")
	I $G(TCTX("job","compatLegacy")) D
	. S TCTX("exportPlan",1,"badge")="Fallback"
	. S TCTX("exportPlan",1,"desc")="This file is currently publishing through the compatibility claim exporter so operators still receive a CSV."
	. S TCTX("exportPlan",2,"badge")="Pending"
	. S TCTX("exportPlan",2,"tone")="tone-slate"
	. S TCTX("exportPlan",2,"desc")="Canonical line packaging is not yet attached for this compatibility run."
	. S TCTX("exportPlan",3,"badge")="Pending"
	. S TCTX("exportPlan",3,"tone")="tone-slate"
	. S TCTX("exportPlan",5,"badge")="Skipped"
	. S TCTX("exportPlan",5,"tone")="tone-slate"
	. S TCTX("exportPlan",6,"badge")="Skipped"
	. S TCTX("exportPlan",6,"tone")="tone-slate"
	K TCTX("downloadGroup")
	S N=0,IDX=0
	F  S N=$O(TCTX("downloads",N)) Q:'N  D
	. S KEY=$G(TCTX("downloads",N,"key"))
	. S GROUP=$S(KEY["canonical":"canonical",KEY["profile":"profile",KEY["rebuilt":"rebuild",KEY["roundtrip":"report",KEY["trace":"trace",1:"other")
	. S IDX=1+$O(TCTX("downloadGroup",GROUP,"item",""),-1)
	. M TCTX("downloadGroup",GROUP,"item",IDX)=TCTX("downloads",N)
	. S TCTX("downloadGroup",GROUP,"hasItems")=1
	S TCTX("downloadGroup","canonical","label")="Canonical package"
	S TCTX("downloadGroup","canonical","desc")="Claims, lines, and manifest produced by the stable engine contract."
	S TCTX("downloadGroup","canonical","tone")="tone-sky"
	S TCTX("downloadGroup","profile","label")="Profile outputs"
	S TCTX("downloadGroup","profile","desc")="Operator-facing CSV artifacts shaped by saved profile rules."
	S TCTX("downloadGroup","profile","tone")="tone-violet"
	S TCTX("downloadGroup","rebuild","label")="Rebuilt X12"
	S TCTX("downloadGroup","rebuild","desc")="Deterministic writer output generated during publish."
	S TCTX("downloadGroup","rebuild","tone")="tone-emerald"
	S TCTX("downloadGroup","report","label")="Reports"
	S TCTX("downloadGroup","report","desc")="Round-trip and audit-style outputs for validation review."
	S TCTX("downloadGroup","report","tone")="tone-amber"
	S TCTX("downloadGroup","trace","label")="Trace artifacts"
	S TCTX("downloadGroup","trace","desc")="Provenance and traceability material captured during processing."
	S TCTX("downloadGroup","trace","tone")="tone-amber"
	S TCTX("downloadGroup","other","label")="Other artifacts"
	S TCTX("downloadGroup","other","desc")="Additional files staged under the job package."
	S TCTX("downloadGroup","other","tone")="tone-slate"
	Q
	;
	
MODESEL(TCTX)
	N I,MODE
	S MODE=$G(TCTX("profile","exportMode")) I MODE="" S MODE="claim_summary"
	S I=0
	F  S I=$O(TCTX("maps","modes",I)) Q:'I  D
	. S TCTX("maps","modes",I,"isSelected")=$S($G(TCTX("maps","modes",I,"id"))=MODE:1,1:0)
	S TCTX("profile","isClaimSummary")=$S(MODE="claim_summary":1,1:0)
	S TCTX("profile","isServiceLine")=$S(MODE="service_line":1,1:0)
	S TCTX("profile","isSubscriberPatient")=$S(MODE="subscriber_patient":1,1:0)
	S TCTX("profile","isProviderContext")=$S(MODE="provider_context":1,1:0)
	S TCTX("profile","isCustom")=$S(MODE="custom":1,1:0)
	S TCTX("profile","headerOn")=$S(+$G(TCTX("profile","header"),1):1,1:0)
	S TCTX("profile","headerOff")=$S(+$G(TCTX("profile","header"),1):0,1:1)
	S TCTX("profile","quoteMinimal")=$S($G(TCTX("profile","quoteMode"),"minimal")="minimal":1,1:0)
	S TCTX("profile","quoteAll")=$S($G(TCTX("profile","quoteMode"))="all":1,1:0)
	S TCTX("profile","quoteNone")=$S($G(TCTX("profile","quoteMode"))="none":1,1:0)
	S TCTX("profile","rowClaim")=$S($G(TCTX("profile","rowSource"),"claim")="claim":1,1:0)
	S TCTX("profile","rowLine")=$S($G(TCTX("profile","rowSource"))="line":1,1:0)
	Q
	;
POSTLIST(TCTX)
	N N
	S N=0 F  S N=$O(TCTX("profiles",N)) Q:'N  D
	. S TCTX("profiles",N,"fieldCount")=$$CSVCT($G(TCTX("profiles",N,"selectedFields")))
	. S TCTX("profiles",N,"modeLabel")=$$UP($TR($G(TCTX("profiles",N,"exportMode")),"_"," "))
	. S TCTX("profiles",N,"rowSource")=$S($G(TCTX("profiles",N,"exportMode"))'="":$$ROWSRC^EFU837EXPMP($G(TCTX("profiles",N,"exportMode"))),1:$G(TCTX("profiles",N,"rowSource")))
	S N=0 F  S N=$O(TCTX("files",N)) Q:'N  D
	. S TCTX("files",N,"sizeText")=$$HUMAN($G(TCTX("files",N,"size")))
	S N=0 F  S N=$O(TCTX("automation",N)) Q:'N  D
	. S TCTX("automation",N,"enabledLabel")=$S(+$G(TCTX("automation",N,"enabled")):"Enabled",1:"Disabled")
	. S TCTX("automation",N,"enabledTone")=$S(+$G(TCTX("automation",N,"enabled")):"badge-emerald",1:"badge-slate")
	Q
	;
POSTPREV(TCTX)
	S TCTX("job","compareModeLabel")=$$UP($TR($G(TCTX("job","compareMode")),"_"," "))
	I $G(TCTX("job","compareModeLabel"))="" S TCTX("job","compareModeLabel")="Export safe"
	S TCTX("job","traceLabel")=$S(+$G(TCTX("trace","summary","fields"))>0:"Trace ready",1:"Trace sample pending")
	S TCTX("job","profileLabel")=$S($G(TCTX("selectedProfileAny")):$G(TCTX("selectedProfile","name")),1:"No profile selected")
	S TCTX("job","profileModeLabel")=$S($G(TCTX("selectedProfileAny")):$G(TCTX("selectedProfile","modeText")),1:"Canonical only")
	Q
	;
POSTDETAIL(TCTX)
	D POSTPREV(.TCTX)
	Q
	;
POSTPROF(TCTX)
	S TCTX("profile","selectedFieldCount")=$$CSVCT($G(TCTX("profile","selectedFieldsText")))
	S TCTX("profile","fieldOrderCount")=$$CSVCT($G(TCTX("profile","fieldOrderText")))
	Q
	;
CSVCT(X)
	N I,C,P
	S C=0
	F I=1:1:$L($G(X),",") S P=$$TRIM^MIOUTIL($P($G(X),",",I)) I P'="" S C=C+1
	Q C
	;
HUMAN(N)
	N X
	S X=+$G(N)
	I X>999999 Q $J(X/1000000,0,1)_" MB"
	I X>999 Q $J(X/1000,0,1)_" KB"
	Q X_" B"
	;
UP(X)
	N Y,I,C,O,PREV
	S Y=$ZCONVERT($G(X),"L"),O="",PREV=" "
	F I=1:1:$L(Y) S C=$E(Y,I) D
	. I PREV=" " S O=O_$ZCONVERT(C,"U") S PREV=C Q
	. S O=O_C,PREV=C
	Q O
	;
	;
