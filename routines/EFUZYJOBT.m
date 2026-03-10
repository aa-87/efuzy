EFUZYJOBT ; tests for EFUZYJOB
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
T001 ; create queued job
 N CONF,JOBID,ERR
 D RESET^EFUZYTESTU("")
 D OK^MIOTASSERT($$CREATEQ^EFUZYJOB(.CONF,9,"837_to_csv","manual",.JOBID,.ERR),"[T001][create ok]")
 D OK^MIOTASSERT(JOBID>0,"[T001][job id]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"status")),"queued","[T001][status]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"fileId")),9,"[T001][file id]")
 D OK^MIOTASSERT($D(^MIO("EFUZY","idx","job","status","queued",JOBID)),"[T001][queued index]")
 Q
 ;
T002 ; start warn diag setstat and finish ok
 N CONF,JOBID,ERR
 D RESET^EFUZYTESTU("")
 D OK^MIOTASSERT($$CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR),"[T002][create ok]")
 D START^EFUZYJOB(JOBID)
 D WARN^EFUZYJOB(JOBID,"warn a")
 D DIAG^EFUZYJOB(JOBID,"detail a")
 D SETSTAT^EFUZYJOB(JOBID,"claimCount",3)
 D FINOK^EFUZYJOB(JOBID)
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"status")),"completed","[T002][status]")
 D NE^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"startedAt")),"","[T002][started]")
 D NE^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"endedAt")),"","[T002][ended]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"warningCount")),1,"[T002][warning count]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"diag","detail",1)),"detail a","[T002][detail]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"stats","claimCount")),3,"[T002][stat]")
 Q
 ;
T003 ; finish error increments count
 N CONF,JOBID,ERR
 D RESET^EFUZYTESTU("")
 D OK^MIOTASSERT($$CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR),"[T003][create ok]")
 D FINERR^EFUZYJOB(JOBID,"parse_failed")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"status")),"failed","[T003][status]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"diagSummary")),"parse_failed","[T003][diag summary]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"errorCount")),1,"[T003][error count]")
 Q
 ;
T004 ; retry carries file and profile
 N CONF,JOBID,NEWID,ERR
 D RESET^EFUZYTESTU("")
 D OK^MIOTASSERT($$CREATEQ^EFUZYJOB(.CONF,77,"837_to_csv","manual",.JOBID,.ERR),"[T004][create ok]")
 S ^MIO("EFUZY","job",JOBID,"profileId")=5
 D OK^MIOTASSERT($$RETRY^EFUZYJOB(.CONF,JOBID,.NEWID,.ERR),"[T004][retry ok]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",NEWID,"fileId")),77,"[T004][file carried]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",NEWID,"profileId")),5,"[T004][profile carried]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",NEWID,"status")),"queued","[T004][new queued]")
 Q
 ;
