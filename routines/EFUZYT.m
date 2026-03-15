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
 Q
 ;
SEED
 N CONF,POST,ID,ERR,JOBID,PID
 D SEED^EFUZYCFG
 ; explicit profile so tests do not depend on seed side effects
 K POST
 S POST("name")="Seed Profile"
 S POST("exportMode")="claim_summary"
 S POST("selectedFields")="claim_id,total_charge,patient_last"
 S POST("fieldOrder")="claim_id,total_charge,patient_last"
 D SAVE^EFUZYCFG(.CONF,.POST,.PID,.ERR)
 ; staged file / job
 S ^MIO("EFUZY","file",1,"id")=1
 S ^MIO("EFUZY","file",1,"name")="demo.837"
 S ^MIO("EFUZY","file",1,"path")="tmp/demo.837"
 S ^MIO("EFUZY","file",1,"size")=123
 D CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR)
 D START^EFUZYJOB(JOBID)
 D SETSTAT^EFUZYJOB(JOBID,"claimCount",1)
 D WARN^EFUZYJOB(JOBID,"warning one")
 ; legacy wrk rows
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_date")="20260301"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"total_charge")="100"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"patient_last")="DOE"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"patient_first")="JANE"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"payer_name")="PAYER"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_number")="1"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"procedure_code")="99213"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_charge")="75"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_service_date")="20260301"
 ; current preview nodes too
 S ^MIO("EFUZY","job",JOBID,"preview","claim",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"preview","line",1,"procedure_code")="99213"
 D FINOK^EFUZYJOB(JOBID)
 ; explicit automation so list is populated
 K POST
 S POST("name")="Auto One"
 S POST("inputFolder")="tmp/in"
 S POST("enabled")=1
 S POST("selectedProfile")=PID
 D SAVEAUTO^EFUZYCFG(.CONF,.POST,.ID,.ERR)
 Q
 ;
T001 ; workspace context includes summaries files jobs profiles and onboarding
 N CONF,REQ,CTX,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 D BUILDWS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOTASSERT($G(TCTX("page","title")),"Workspace","[T001][title]")
 D EQ^MIOTASSERT($G(TCTX("nav",1,"isActive")),1,"[T001][workspace active]")
 D EQ^MIOTASSERT($G(TCTX("summarycards",3,"value")),1,"[T001][completed count]")
 D EQ^MIOTASSERT($G(TCTX("files",1,"name")),"demo.837","[T001][file]")
 D OK^MIOTASSERT($D(TCTX("profiles",1))>0,"[T001][profiles loaded]")
 D EQ^MIOTASSERT($O(TCTX("nav",""),-1),3,"[T001][nav count]")
 D EQ^MIOTASSERT($G(TCTX("workflow",3,"name")),"Saved export profiles","[T001][workflow card]")
 D EQ^MIOTASSERT($G(TCTX("onboarding","step",1,"title")),"Stage an 837 file","[T001][onboarding]")
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
 D EQ^MIOTASSERT($G(TCTX("preview","lines",1,"procedure_code")),"99213","[T002][line preview]")
 D EQ^MIOTASSERT($G(TCTX("preview","claims",1,"date_of_service")),"20260301","[T002][claim dos]")
 D EQ^MIOTASSERT($G(TCTX("preview","lines",1,"date_of_service")),"20260301","[T002][line dos]")
 Q
 ;
T003 ; profiles and profile editor contexts
 N CONF,REQ,CTX,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 D BUILDPROFS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ^MIOTASSERT($G(TCTX("nav",3,"isActive")),1,"[T003][profiles active]")
 D OK^MIOTASSERT($D(TCTX("profiles",1))>0,"[T003][profiles list]")
 D BUILDPROF^EFUZYUI(.CONF,.REQ,.CTX,"new",.TCTX)
 D OK^MIOTASSERT($D(TCTX("profile","catalog",1))>0,"[T003][maps loaded]")
 D EQ^MIOTASSERT($G(TCTX("profile","exportMode")),"claim_summary","[T003][new profile mode]")
 Q
 ;
T004 ; job detail keeps preview and authenticated first-login onboarding context
 N CONF,REQ,CTX,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 S CTX("efuzy","userId")=1,CTX("efuzy","login")="demo",CTX("efuzy","showOnboarding")=1
 D BUILDJOB^EFUZYUI(.CONF,.REQ,.CTX,1,.TCTX)
 D EQ^MIOTASSERT($G(TCTX("job","status")),"completed","[T004][job status]")
 D EQ^MIOTASSERT($G(TCTX("preview","claims",1,"claim_id")),"CLM0001","[T004][job preview]")
 D EQ^MIOTASSERT($G(TCTX("onboarding","reopenLabel")),"Onboarding","[T004][onboarding label]")
 D EQ^MIOTASSERT(+$G(TCTX("session","showOnboarding")),1,"[T004][auto onboarding flag]")
 Q
 ;
