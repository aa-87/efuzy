EFUZYUIPT ; profile editor and export visibility tests
 D START Q
 ;
START
 N FAIL S FAIL=0
 D T300(.FAIL)
 D T310(.FAIL)
 I 'FAIL W !,"OK - EFUZYUIPT"
 Q
 ;
SEEDJOB(JOBID,PID)
 N CONF,ERR
 S ^MIO("EFUZY","file",1,"id")=1
 S ^MIO("EFUZY","file",1,"name")="demo.837"
 S ^MIO("EFUZY","file",1,"path")="tmp/demo.837"
 D CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR)
 S ^MIO("EFUZY","job",JOBID,"profileId")=PID
 S ^MIO("EFUZY","job",JOBID,"preview","claim",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"preview","line",1,"procedure_code")="99213"
 S ^MIO("EFUZY","job",JOBID,"outputPath")="tmp/demo-claims.csv"
 S ^MIO("EFUZY","job",JOBID,"outputName")="demo-claims.csv"
 D FINOK^EFUZYJOB(JOBID)
 Q
 ;
T300(FAIL)
 N CONF,REQ,CTX,TCTX,POST,ID,ERR
 D RESET^EFUZYTESTU("")
 S POST("name")="UI Custom"
 S POST("exportMode")="custom"
 S POST("selectedFields")="claim_id,total_charge,patient_last"
 S POST("fieldOrder")="patient_last,claim_id,total_charge"
 S POST("outputNamingRule")="{{source_base}}-claims-{{job_id}}.csv"
 D EQ(.FAIL,"[T300][save ok]",$$SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR),1)
 D BUILDPROF^EFUZYUI(.CONF,.REQ,.CTX,ID,.TCTX)
 D EQ(.FAIL,"[T300][catalog first]",$G(TCTX("profile","catalog",1,"name"))'="",1)
 D EQ(.FAIL,"[T300][selected first]",$G(TCTX("profile","selectedColumns",1,"name")),"patient_last")
 D EQ(.FAIL,"[T300][selected second]",$G(TCTX("profile","selectedColumns",2,"name")),"claim_id")
 D EQ(.FAIL,"[T300][naming preview]",$G(TCTX("profile","namingPreview"))["sample-837-claims-",1)
 Q
 ;
T310(FAIL)
 N CONF,REQ,CTX,TCTX,POST,PID,ERR
 D RESET^EFUZYTESTU("")
 S POST("name")="Visible Export"
 S POST("exportMode")="claim_summary"
 D EQ(.FAIL,"[T310][save ok]",$$SAVE^EFUZYCFG(.CONF,.POST,.PID,.ERR),1)
 D SEEDJOB(1,PID)
 D BUILDPREV^EFUZYUI(.CONF,.REQ,.CTX,1,.TCTX)
 D EQ(.FAIL,"[T310][output name]",$G(TCTX("job","outputName")),"demo-claims.csv")
 D EQ(.FAIL,"[T310][download name]",$G(TCTX("downloads",1,"name")),"demo-claims.csv")
 D EQ(.FAIL,"[T310][profile selected]",+$G(TCTX("selectedProfile","id")),PID)
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
