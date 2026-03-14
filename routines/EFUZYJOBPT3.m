EFUZYJOBPT3 ; extra efuzy job lifecycle tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYJOBPT3"
 Q
 ;
ALL(FAIL)
 D T700(.FAIL)
 D T710(.FAIL)
 D T720(.FAIL)
 Q
 ;
T700(FAIL) ; finish error stamps failed status and summary
 N CONF,JOBID,ERR
 D RESET^EFUZYTESTU("")
 D CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR)
 D FINERR^EFUZYJOB(JOBID,"parse_failed")
 D EQ(.FAIL,"[T700][status]",$G(^MIO("EFUZY","job",JOBID,"status")),"failed")
 D EQ(.FAIL,"[T700][summary]",$G(^MIO("EFUZY","job",JOBID,"diagSummary")),"parse_failed")
 D EQ(.FAIL,"[T700][errorcount]",+$G(^MIO("EFUZY","job",JOBID,"errorCount")),1)
 D EQ(.FAIL,"[T700][index]",$D(^MIO("EFUZY","idx","job","status","failed",JOBID))>0,1)
 Q
 ;
T710(FAIL) ; warnings append in order and counts increment
 N CONF,JOBID,ERR
 D RESET^EFUZYTESTU("")
 D CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR)
 D WARN^EFUZYJOB(JOBID,"warn one")
 D WARN^EFUZYJOB(JOBID,"warn two")
 D EQ(.FAIL,"[T710][count]",+$G(^MIO("EFUZY","job",JOBID,"warningCount")),2)
 D EQ(.FAIL,"[T710][first]",$G(^MIO("EFUZY","job",JOBID,"diag","warning",1)),"warn one")
 D EQ(.FAIL,"[T710][second]",$G(^MIO("EFUZY","job",JOBID,"diag","warning",2)),"warn two")
 Q
 ;
T720(FAIL) ; start clears stale work and diag content
 N CONF,JOBID,ERR
 D RESET^EFUZYTESTU("")
 D CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR)
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_id")="OLD"
 S ^MIO("EFUZY","job",JOBID,"diag","warning",1)="OLDWARN"
 D START^EFUZYJOB(JOBID)
 D EQ(.FAIL,"[T720][status]",$G(^MIO("EFUZY","job",JOBID,"status")),"running")
 D EQ(.FAIL,"[T720][wrk cleared]",$D(^MIO("EFUZY","job",JOBID,"wrk"))>0,0)
 D EQ(.FAIL,"[T720][diag cleared]",$D(^MIO("EFUZY","job",JOBID,"diag"))>0,0)
 D EQ(.FAIL,"[T720][started]",$G(^MIO("EFUZY","job",JOBID,"startedAt"))'="",1)
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
