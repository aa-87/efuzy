EFUZYUIPT3 ; extra SSR view-model tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYUIPT3"
 Q
 ;
ALL(FAIL)
 D T890(.FAIL)
 D T900(.FAIL)
 D T910(.FAIL)
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
 D SETSTAT^EFUZYJOB(JOBID,"claimCount",1)
 D SETSTAT^EFUZYJOB(JOBID,"lineCount",1)
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_date")="20260301"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"procedure_code")="99213"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_service_date")="20260301"
 D FINOK^EFUZYJOB(JOBID)
 Q
 ;
T890(FAIL) ; profiles page shows seeded defaults and links
 N CONF,REQ,CTX,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 D BUILDPROFS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
 D EQ(.FAIL,"[T890][title]",$G(TCTX("page","title")),"Profiles")
 D EQ(.FAIL,"[T890][has first]",$D(TCTX("profiles",1))>0,1)
 D EQ(.FAIL,"[T890][first href]",$G(TCTX("profiles",1,"href"))["/efuzy/profiles/",1)
 D EQ(.FAIL,"[T890][onboarding]",$G(TCTX("onboarding","reopenLabel")),"Onboarding")
 Q
 ;
T900(FAIL) ; preview suggests a profile and exposes samples
 N CONF,REQ,CTX,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 D BUILDPREV^EFUZYUI(.CONF,.REQ,.CTX,1,.TCTX)
 D EQ(.FAIL,"[T900][profiles any]",+$G(TCTX("profilesAny")),1)
 D EQ(.FAIL,"[T900][selected profile]",$G(TCTX("selectedProfile","name"))'="",1)
 D EQ(.FAIL,"[T900][claim sample]",$G(TCTX("preview","claims",1,"claim_id")),"CLM0001")
 Q
 ;
T910(FAIL) ; profile editor default state has catalog and ordering
 N CONF,REQ,CTX,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 D BUILDPROF^EFUZYUI(.CONF,.REQ,.CTX,"new",.TCTX)
 D EQ(.FAIL,"[T910][title]",$G(TCTX("page","title")),"Profile")
 D EQ(.FAIL,"[T910][catalog]",$D(TCTX("maps","fields","claim_summary",1))>0,1)
 D EQ(.FAIL,"[T910][selected]",$D(TCTX("profile","selectedFields",1))>0,1)
 D EQ(.FAIL,"[T910][naming rule]",$G(TCTX("profile","outputNamingRule"))["source_base",1)
 D EQ(.FAIL,"[T910][mobile shell label]",$G(TCTX("shell","menuLabel")),"Open navigation")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
