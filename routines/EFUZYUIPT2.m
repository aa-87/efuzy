EFUZYUIPT2 ; additional efuzy SSR view-model tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYUIPT2"
 Q
 ;
ALL(FAIL)
 D T850(.FAIL)
 D T860(.FAIL)
 D T870(.FAIL)
 D T880(.FAIL)
 Q
 ;
SEED
 N CONF,POST,ID,ERR,JOBID
 D SEED^EFUZYCFG
 S ^MIO("EFUZY","file",1,"id")=1
 S ^MIO("EFUZY","file",1,"name")="demo.837"
 S ^MIO("EFUZY","file",1,"path")="tmp/demo.837"
 D CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR)
 D START^EFUZYJOB(JOBID)
 D WARN^EFUZYJOB(JOBID,"warning one")
 D DIAG^EFUZYJOB(JOBID,"detail one")
 D SETSTAT^EFUZYJOB(JOBID,"claimCount",1)
 D SETSTAT^EFUZYJOB(JOBID,"lineCount",1)
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_date")="20260301"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"patient_last")="DOE"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"patient_first")="JANE"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_number")="1"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"procedure_code")="99213"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_service_date")="20260301"
 D FINOK^EFUZYJOB(JOBID)
 S POST("name")="Night Job"
 S POST("inputFolder")="/in"
 D SAVEAUTO^EFUZYCFG(.CONF,.POST,.ID,.ERR)
 Q
 ;
T850(FAIL) ; workspace empty state, onboarding, and trimmed nav
 N CONF,REQ,CTX,TCTX
 D RESET^EFUZYTESTU("")
 D BUILDWS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ(.FAIL,"[T850][title]",$G(TCTX("page","title")),"Workspace")
 D EQ(.FAIL,"[T850][nav active]",+$G(TCTX("nav",1,"isActive")),1)
 D EQ(.FAIL,"[T850][nav count]",$O(TCTX("nav",""),-1),3)
 D EQ(.FAIL,"[T850][files empty]",+$G(TCTX("filesEmpty")),1)
 D EQ(.FAIL,"[T850][recent empty]",+$G(TCTX("recentEmpty")),1)
 D EQ(.FAIL,"[T850][onboarding]",$G(TCTX("onboarding","reopenLabel")),"Onboarding")
 Q
 ;
T860(FAIL) ; preview page includes claim and line samples
 N CONF,REQ,CTX,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 D BUILDPREV^EFUZYUI(.CONF,.REQ,.CTX,1,.TCTX)
 D EQ(.FAIL,"[T860][title]",$G(TCTX("page","title")),"Preview")
 D EQ(.FAIL,"[T860][claim]",$G(TCTX("preview","claims",1,"claim_id")),"CLM0001")
 D EQ(.FAIL,"[T860][line]",$G(TCTX("preview","lines",1,"procedure_code")),"99213")
 D EQ(.FAIL,"[T860][claim dos]",$G(TCTX("preview","claims",1,"date_of_service")),"20260301")
 D EQ(.FAIL,"[T860][line dos]",$G(TCTX("preview","lines",1,"date_of_service")),"20260301")
 D EQ(.FAIL,"[T860][job id]",+$G(TCTX("job","id")),1)
 Q
 ;
T870(FAIL) ; profiles list and editor expose maps and defaults
 N CONF,REQ,CTX,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 D BUILDPROFS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ(.FAIL,"[T870][profiles active]",+$G(TCTX("nav",3,"isActive")),1)
 D EQ(.FAIL,"[T870][profiles present]",$D(TCTX("profiles",1))>0,1)
 D EQ(.FAIL,"[T870][maps modes]",$D(TCTX("maps","modes",1))>0,1)
 D BUILDPROF^EFUZYUI(.CONF,.REQ,.CTX,"new",.TCTX)
 D EQ(.FAIL,"[T870][editor title]",$G(TCTX("page","title")),"Profile")
 D EQ(.FAIL,"[T870][default export mode]",$G(TCTX("profile","exportMode")),"claim_summary")
 D EQ(.FAIL,"[T870][selected token]",$G(TCTX("profile","selectedFields",1,"name")),"claim_id")
 Q
 ;
T880(FAIL) ; job detail exposes seeded data and keeps guided labels
 N CONF,REQ,CTX,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 D BUILDJOB^EFUZYUI(.CONF,.REQ,.CTX,1,.TCTX)
 D EQ(.FAIL,"[T880][job title]",$G(TCTX("page","title")),"Job Detail")
 D EQ(.FAIL,"[T880][job status]",$G(TCTX("job","status")),"completed")
 D EQ(.FAIL,"[T880][warning]",$G(TCTX("diagnostic","warning",1,"msg")),"warning one")
 D EQ(.FAIL,"[T880][warning count]",+$G(TCTX("summaryData","warnings")),1)
 D EQ(.FAIL,"[T880][guided label]",$G(TCTX("onboarding","primaryLabel")),"Show walkthrough")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
