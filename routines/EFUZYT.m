EFUZYT ; tests for EFUZYUI page contexts and smoke data shaping
	;
	; Run:
	;   YDB>D START^EFUZYT
	;
	Q
	;
START
	D T001
	D T002
	D T003
	D T004
	D T005
	D T006
	Q
	;
SEED
	N CONF,POST,ID,ERR,JOBID
	D SEED^EFUZYCFG
	S ^MIO("EFUZY","file",1,"id")=1
	S ^MIO("EFUZY","file",1,"name")="demo.837"
	S ^MIO("EFUZY","file",1,"path")="/tmp/demo.837"
	S ^MIO("EFUZY","file",1,"size")=123
	D CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR)
	D START^EFUZYJOB(JOBID)
	D SETSTAT^EFUZYJOB(JOBID,"claimCount",1)
	D WARN^EFUZYJOB(JOBID,"warning one")
	S ^MIO("EFUZY","job",JOBID,"preview","claim",1,"claim_id")="CLM0001"
	S ^MIO("EFUZY","job",JOBID,"preview","claim",1,"patient_name")="DOE, JANE"
	S ^MIO("EFUZY","job",JOBID,"preview","line",1,"claim_id")="CLM0001"
	S ^MIO("EFUZY","job",JOBID,"preview","line",1,"procedure_code")="99213"
	S ^MIO("EFUZY","job",JOBID,"diag","warning",1,"msg")="warning one"
	S ^MIO("EFUZY","job",JOBID,"artifact","canonical_claims","path")="/tmp/demo-claims.csv"
	S ^MIO("EFUZY","job",JOBID,"artifact","canonical_claims","name")="demo-claims.csv"
	S ^MIO("EFUZY","job",JOBID,"artifact","canonical_claims","type")="csv"
	S ^MIO("EFUZY","job",JOBID,"stats","claims")=1
	S ^MIO("EFUZY","job",JOBID,"stats","lines")=1
	S ^MIO("EFUZY","job",JOBID,"stats","transactions")=1
	S ^MIO("EFUZY","job",JOBID,"stats","traceFields")=4
	S ^MIO("EFUZY","job",JOBID,"stats","traceSegments")=3
	D FINOK^EFUZYJOB(JOBID)
	S POST("name")="Auto One"
	S POST("inputFolder")="/in"
	D SAVEAUTO^EFUZYCFG(.CONF,.POST,.ID,.ERR)
	Q
	;
T001 ; workspace context includes summaries files jobs profiles automation
	N CONF,REQ,CTX,TCTX
	D RESET^EFUZYTESTU("")
	D SEED
	D BUILDWS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOTASSERT($G(TCTX("page","title")),"Workspace","[T001][title]")
	D EQ^MIOTASSERT($G(TCTX("nav",1,"isActive")),1,"[T001][workspace active]")
	D EQ^MIOTASSERT($G(TCTX("summarycards",3,"value")),1,"[T001][completed count]")
	D EQ^MIOTASSERT($G(TCTX("files",1,"name")),"demo.837","[T001][file]")
	D OK^MIOTASSERT($D(TCTX("profiles",1))>0,"[T001][profiles loaded]")
	D OK^MIOTASSERT($D(TCTX("automation",1))>0,"[T001][automation loaded]")
	Q
	;
T002 ; preview context includes claims and lines
	N CONF,REQ,CTX,TCTX
	D RESET^EFUZYTESTU("")
	D SEED
	D BUILDPREV^EFUZYUI(.CONF,.REQ,.CTX,1,.TCTX)
	D EQ^MIOTASSERT($G(TCTX("page","title")),"Preview","[T002][title]")
	D EQ^MIOTASSERT($G(TCTX("job","id")),1,"[T002][job id]")
	D EQ^MIOTASSERT($G(TCTX("preview","claims",1,"claim_id")),"CLM0001","[T002][claim preview]")
	D EQ^MIOTASSERT($G(TCTX("downloads",1,"name")),"demo-claims.csv","[T002][download name]")
	Q
	;
T003 ; profiles and profile editor contexts
	N CONF,REQ,CTX,TCTX
	D RESET^EFUZYTESTU("")
	D SEED
	D BUILDPROFS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOTASSERT($G(TCTX("nav",3,"isActive")),1,"[T003][profiles active]")
	D OK^MIOTASSERT($D(TCTX("maps","modes",1))>0,"[T003][maps loaded]")
	D BUILDPROF^EFUZYUI(.CONF,.REQ,.CTX,"new",.TCTX)
	D EQ^MIOTASSERT($G(TCTX("profile","exportMode")),"claim_summary","[T003][new profile mode]")
	Q
	;
T004 ; automation and job detail contexts
	N CONF,REQ,CTX,TCTX
	D RESET^EFUZYTESTU("")
	D SEED
	D BUILDAUTO^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOTASSERT($G(TCTX("nav",4,"isActive")),1,"[T004][automation active]")
	D EQ^MIOTASSERT($G(TCTX("automation",1,"name")),"Auto One","[T004][automation name]")
	D BUILDJOB^EFUZYUI(.CONF,.REQ,.CTX,1,.TCTX)
	D EQ^MIOTASSERT($G(TCTX("job","status")),"completed","[T004][job status]")
	D EQ^MIOTASSERT($G(TCTX("preview","claims",1,"claim_id")),"CLM0001","[T004][job preview]")
	Q
	;
T005 ; jobs page context uses published history payload
	N CONF,REQ,CTX,TCTX
	D RESET^EFUZYTESTU("")
	D SEED
	D BUILDJOBS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOTASSERT($G(TCTX("nav",2,"isActive")),1,"[T005][jobs active]")
	D EQ^MIOTASSERT($G(TCTX("jobs",1,"jobid")),1,"[T005][history job id]")
	D EQ^MIOTASSERT($G(TCTX("jobs",1,"href")),"/efuzy/jobs/1","[T005][history href]")
	Q
	;
T006 ; workspace recent jobs are adapted from web history payload
	N CONF,REQ,CTX,TCTX
	D RESET^EFUZYTESTU("")
	D SEED
	D BUILDWS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
	D EQ^MIOTASSERT($G(TCTX("recentJobs",1,"jobid")),1,"[T006][recent job id]")
	D EQ^MIOTASSERT($G(TCTX("recentJobs",1,"detailHref")),"/efuzy/jobs/1","[T006][recent detail href]")
	Q
	;
	;