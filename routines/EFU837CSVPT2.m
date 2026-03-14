EFU837CSVPT2 ; extra profile export tests
	; Quiet on success.;
	;
	D START Q
	;
START ; default entry
	N FAIL
	S FAIL=0
	D ALL(.FAIL)
	I 'FAIL W !,"OK - EFU837CSVPT2"
	Q
	;
ALL(FAIL)
	D T940(.FAIL)
	D T950(.FAIL)
	Q
	;
T940(FAIL) ; delimiter and quote-all profile settings are honored
	N ROOT,CONF,POST,ID,ERR,JOBID,OUTPATH,OK,TXT
	D RESET^EFUZYTESTU("")
	S ROOT=$$TMPROOT^EFUZYTESTU("csvpt2-940")
	D SETCONF^EFUZYTESTU(.CONF,ROOT)
	D MKDIR^EFUZYTESTU(ROOT)
	S ^MIO("EFUZY","file",1,"id")=1
	S ^MIO("EFUZY","file",1,"name")="demo.837"
	S ^MIO("EFUZY","job",1,"id")=1
	S ^MIO("EFUZY","job",1,"fileId")=1
	S ^MIO("EFUZY","job",1,"wrk","claim",1,"claim_id")="CLM0001"
	S ^MIO("EFUZY","job",1,"wrk","claim",1,"patient_last")="DOE"
	K POST,ERR
	S POST("name")="Quoted Claims"
	S POST("exportMode")="claim_summary"
	S POST("selectedFields")="claim_id,patient_last"
	S POST("fieldOrder")="claim_id,patient_last"
	S POST("delimiter")="|"
	S POST("quoteMode")="all"
	S POST("rowSource")="claim"
	D SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR)
	D EQ(.FAIL,"[T940][profile saved]",+$G(ID)>0,1)
	D EQ(.FAIL,"[T940][make]",$$MAKE^EFU837CSV(.CONF,1,ID,.OUTPATH,.ERR),1)
	D EQ(.FAIL,"[T940][outfile]",$$READFILE^EFUZYTESTU(OUTPATH,.TXT),1)
	D EQ(.FAIL,"[T940][header delim]",TXT["""claim_id""|""patient_last""",1)
	D EQ(.FAIL,"[T940][row quoted]",TXT["""CLM0001""|""DOE""",1)
	D RMDIR^EFUZYTESTU(ROOT)
	Q
	;
T950(FAIL) ; line export falls back to owning claim values when needed
	N ROOT,CONF,POST,ID,ERR,OUTPATH,TXT,JOBID
	D RESET^EFUZYTESTU("")
	S ROOT=$$TMPROOT^EFUZYTESTU("csvpt2-950")
	D SETCONF^EFUZYTESTU(.CONF,ROOT)
	D MKDIR^EFUZYTESTU(ROOT)
	S JOBID=2
	S ^MIO("EFUZY","file",1,"id")=1
	S ^MIO("EFUZY","file",1,"name")="demo.837"
	S ^MIO("EFUZY","job",JOBID,"id")=JOBID
	S ^MIO("EFUZY","job",JOBID,"fileId")=1
	S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_id")="CLM0001"
	S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"subscriber_id")="SUB123"
	S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"claim_index")=1
	S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"claim_id")="CLM0001"
	S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"procedure_code")="99213"
	K POST,ERR
	S POST("name")="Line With Fallback"
	S POST("exportMode")="service_line"
	S POST("selectedFields")="claim_id,procedure_code,subscriber_id"
	S POST("fieldOrder")="claim_id,procedure_code,subscriber_id"
	S POST("rowSource")="line"
	D SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR)
	D EQ(.FAIL,"[T950][profile saved]",+$G(ID)>0,1)
	D EQ(.FAIL,"[T950][make]",$$MAKE^EFU837CSV(.CONF,JOBID,ID,.OUTPATH,.ERR),1)
	D EQ(.FAIL,"[T950][outfile]",$$READFILE^EFUZYTESTU(OUTPATH,.TXT),1)
	D EQ(.FAIL,"[T950][fallback value]",TXT["SUB123",1)
	D RMDIR^EFUZYTESTU(ROOT)
	Q
	;
EQ(FAIL,LABEL,GOT,EXP)
	I $G(GOT)=$G(EXP) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
	Q
	;
	;