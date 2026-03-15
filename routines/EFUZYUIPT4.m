EFUZYUIPT4 ; render smoke tests for polished efuzy SSR pages
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYUIPT4"
 Q
 ;
ALL(FAIL)
 D T920(.FAIL)
 D T930(.FAIL)
 D T940(.FAIL)
 D T950(.FAIL)
 Q
 ;
SEED
 N CONF,POST,PID,ERR,JOBID
 D SEED^EFUZYCFG
 S POST("name")="Render Profile"
 S POST("exportMode")="claim_summary"
 S POST("selectedFields")="claim_id,total_charge,patient_last"
 S POST("fieldOrder")="claim_id,total_charge,patient_last"
 D SAVE^EFUZYCFG(.CONF,.POST,.PID,.ERR)
 S ^MIO("EFUZY","file",1,"id")=1
 S ^MIO("EFUZY","file",1,"name")="demo.837"
 S ^MIO("EFUZY","file",1,"path")="tmp/demo.837"
 D CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR)
 S ^MIO("EFUZY","job",JOBID,"profileId")=PID
 D START^EFUZYJOB(JOBID)
 D SETSTAT^EFUZYJOB(JOBID,"claimCount",1)
 D SETSTAT^EFUZYJOB(JOBID,"lineCount",1)
 D WARN^EFUZYJOB(JOBID,"warning one")
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_date")="20260301"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"patient_last")="DOE"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"patient_first")="JANE"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_number")="1"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"procedure_code")="99213"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_service_date")="20260301"
 D FINOK^EFUZYJOB(JOBID)
 Q
 ;
TPLCONF(CONF)
 K CONF
 S CONF("server","templateDir")="templates"
 D START^MIOTPL(.CONF)
 Q
 ;
T920(FAIL) ; workspace render includes mobile nav and first-login onboarding, excludes automation link
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D RESET^EFUZYTESTU("")
 D SEED
 D TPLCONF(.CONF)
 S CTX("efuzy","userId")=1,CTX("efuzy","login")="demo",CTX("efuzy","showOnboarding")=1
 D BUILDWS^EFUZYUI(.CONF,.REQ,.CTX,.TCTX)
 D RENDERPAGE^MIOTPL("pages/efuzy_workspace.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T920][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T920][mobile nav]",$F(OUT,"data-open-mobile-nav")>0,1)
 D EQ(.FAIL,"[T920][onboarding title]",$F(OUT,"Get started in under a minute")>0,1)
 D EQ(.FAIL,"[T920][first run]",$F(OUT,"First-run checklist")>0,1)
 D EQ(.FAIL,"[T920][numbered step]",$F(OUT,"Step 1")>0,1)
 D EQ(.FAIL,"[T920][no automation nav]",$F(OUT,"/efuzy/automation")>0,0)
 Q
 ;
T930(FAIL) ; preview render keeps onboarding launcher and no automation shortcut
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D RESET^EFUZYTESTU("")
 D SEED
 D TPLCONF(.CONF)
 D BUILDPREV^EFUZYUI(.CONF,.REQ,.CTX,1,.TCTX)
 D RENDERPAGE^MIOTPL("pages/efuzy_preview.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T930][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T930][no toolbar onboarding]",$F(OUT,"Onboarding")>0,0)
 D EQ(.FAIL,"[T930][claims]",$F(OUT,"Claims")>0,1)
 D EQ(.FAIL,"[T930][dos heading]",$F(OUT,"Date of service")>0,1)
 D EQ(.FAIL,"[T930][no automation nav]",$F(OUT,"/efuzy/automation")>0,0)
 Q
 ;
T940(FAIL) ; profile editor render keeps dense controls and guided overlay
 N CONF,REQ,CTX,TCTX,OUT,ERR
 D RESET^EFUZYTESTU("")
 D SEED
 D TPLCONF(.CONF)
 D BUILDPROF^EFUZYUI(.CONF,.REQ,.CTX,"new",.TCTX)
 D RENDERPAGE^MIOTPL("pages/efuzy_profile_edit.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T940][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T940][search]",$F(OUT,"data-field-search")>0,1)
 D EQ(.FAIL,"[T940][walkthrough]",$F(OUT,"Step 1")>0,1)
 D EQ(.FAIL,"[T940][mobile nav]",$F(OUT,"data-open-mobile-nav")>0,1)
 Q
 ;
T950(FAIL) ; demo auth render does not auto-launch onboarding before signup
 N CONF,REQ,CTX,STATE,TCTX,OUT,ERR
 D RESET^EFUZYTESTU("")
 D TPLCONF(.CONF)
 D BUILDPAGE^EFUZYAUTH(.CONF,.REQ,.CTX,.STATE,.TCTX)
 D RENDERPAGE^MIOTPL("pages/efuzy_demo_auth.html","layouts/efuzy_layout.html",.CONF,.TCTX,.OUT,.ERR)
 D EQ(.FAIL,"[T950][render ok]",$D(ERR)=0,1)
 D EQ(.FAIL,"[T950][heading]",$F(OUT,"Create evaluation access")>0,1)
 D EQ(.FAIL,"[T950][no auto onboarding flag]",$F(OUT,"var autoOnboarding = '1'")>0,0)
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
