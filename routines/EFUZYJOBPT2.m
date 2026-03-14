EFUZYJOBPT2 ; additional efuzy job lifecycle hardening tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYJOBPT2"
 Q
 ;
ALL(FAIL)
 D T700(.FAIL)
 D T710(.FAIL)
 D T720(.FAIL)
 D T730(.FAIL)
 Q
 ;
T700(FAIL) ; start clears existing work/diag and moves status index
 N CONF,JOBID,ERR,DUMMY
 D RESET^EFUZYTESTU("")
 D EQ(.FAIL,"[T700][create ok]",$$CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR),1)
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_id")="OLD"
 S ^MIO("EFUZY","job",JOBID,"diag","warning",1)="old warn"
 D START^EFUZYJOB(JOBID)
 D EQ(.FAIL,"[T700][status]",$G(^MIO("EFUZY","job",JOBID,"status")),"running")
 D EQ(.FAIL,"[T700][queued removed]",$D(^MIO("EFUZY","idx","job","status","queued",JOBID))>0,0)
 D EQ(.FAIL,"[T700][running present]",$D(^MIO("EFUZY","idx","job","status","running",JOBID))>0,1)
 D EQ(.FAIL,"[T700][wrk cleared]",$D(^MIO("EFUZY","job",JOBID,"wrk"))>0,0)
 D EQ(.FAIL,"[T700][diag cleared]",$D(^MIO("EFUZY","job",JOBID,"diag"))>0,0)
 Q
 ;
T710(FAIL) ; warn and diag append in sequence
 N CONF,JOBID,ERR,DUMMY
 D RESET^EFUZYTESTU("")
 S ERR="",DUMMY=0
 S DUMMY=$$CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR)
 D WARN^EFUZYJOB(JOBID,"warn one")
 D WARN^EFUZYJOB(JOBID,"warn two")
 D DIAG^EFUZYJOB(JOBID,"detail one")
 D DIAG^EFUZYJOB(JOBID,"detail two")
 D EQ(.FAIL,"[T710][warning count]",+$G(^MIO("EFUZY","job",JOBID,"warningCount")),2)
 D EQ(.FAIL,"[T710][warn2]",$G(^MIO("EFUZY","job",JOBID,"diag","warning",2)),"warn two")
 D EQ(.FAIL,"[T710][detail2]",$G(^MIO("EFUZY","job",JOBID,"diag","detail",2)),"detail two")
 Q
 ;
T720(FAIL) ; finok and finerr move status indices cleanly
 N CONF,JOBID,ERR,DUMMY
 D RESET^EFUZYTESTU("")
 S ERR="",DUMMY=0
 S DUMMY=$$CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR)
 D START^EFUZYJOB(JOBID)
 D FINOK^EFUZYJOB(JOBID)
 D EQ(.FAIL,"[T720][completed status]",$G(^MIO("EFUZY","job",JOBID,"status")),"completed")
 D EQ(.FAIL,"[T720][completed idx]",$D(^MIO("EFUZY","idx","job","status","completed",JOBID))>0,1)
 D EQ(.FAIL,"[T720][running removed]",$D(^MIO("EFUZY","idx","job","status","running",JOBID))>0,0)
 D START^EFUZYJOB(JOBID)
 D FINERR^EFUZYJOB(JOBID,"parse_failed")
 D EQ(.FAIL,"[T720][failed idx]",$D(^MIO("EFUZY","idx","job","status","failed",JOBID))>0,1)
 D EQ(.FAIL,"[T720][diag summary]",$G(^MIO("EFUZY","job",JOBID,"diagSummary")),"parse_failed")
 Q
 ;
T730(FAIL) ; retry fails cleanly without file id and sequences increment
 N CONF,JOB1,JOB2,NEWID,ERR,DUMMY
 D RESET^EFUZYTESTU("")
 S ERR="",DUMMY=0
 S DUMMY=$$CREATEQ^EFUZYJOB(.CONF,11,"837_to_csv","manual",.JOB1,.ERR)
 S ERR="",DUMMY=0
 S DUMMY=$$CREATEQ^EFUZYJOB(.CONF,12,"837_to_csv","manual",.JOB2,.ERR)
 D EQ(.FAIL,"[T730][seq increment]",JOB2>JOB1,1)
 K ^MIO("EFUZY","job",JOB1,"fileId")
 D EQ(.FAIL,"[T730][retry missing file]",$$RETRY^EFUZYJOB(.CONF,JOB1,.NEWID,.ERR),0)
 D EQ(.FAIL,"[T730][retry error]",$G(ERR("error")),"job_missing_file")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
