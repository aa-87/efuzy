EFU837CSVPT ; profile-aware CSV export production tests
 D START Q
 ;
START
 N FAIL S FAIL=0
 D T200(.FAIL)
 D T210(.FAIL)
 D T220(.FAIL)
 I 'FAIL W !,"OK - EFU837CSVPT"
 Q
 ;
SEEDJOB(JOBID)
 S ^MIO("EFUZY","job",JOBID,"fileId")=1
 S ^MIO("EFUZY","file",1,"name")="demo837.x12"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"total_charge")="100"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"patient_last")="DOE"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"payer_name")="Payer ""A"", Inc"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"claim_index")=1
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_number")="1"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"procedure_code")="99213"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",2,"claim_index")=1
 S ^MIO("EFUZY","job",JOBID,"wrk","line",2,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",2,"line_number")="2"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",2,"procedure_code")="87070"
 Q
 ;
T200(FAIL)
 N CONF,ROOT,POST,PID,ERR,OUTPATH,TXT
 D RESET^EFUZYTESTU("")
 D SEEDJOB(200)
 S ROOT=$$TMPROOT^EFUZYTESTU("csvpt-200")
 D MKDIR^EFUZYTESTU(ROOT),MKDIR^EFUZYTESTU(ROOT_"/exports")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 S POST("name")="Claims Pipe"
 S POST("exportMode")="custom"
 S POST("selectedFields")="total_charge,claim_id,patient_last"
 S POST("fieldOrder")="patient_last,claim_id,total_charge"
 S POST("delimiter")="|"
 S POST("header")=1
 S POST("rowSource")="claim"
 S POST("outputNamingRule")="{{source_base}}-claims-{{job_id}}.csv"
 D EQ(.FAIL,"[T200][save ok]",$$SAVE^EFUZYCFG(.CONF,.POST,.PID,.ERR),1)
 D EQ(.FAIL,"[T200][make ok]",$$MAKE^EFU837CSV(.CONF,200,PID,.OUTPATH,.ERR),1)
 D EQ(.FAIL,"[T200][read ok]",$$READFILE^EFUZYTESTU(OUTPATH,.TXT),1)
 D EQ(.FAIL,"[T200][name applied]",OUTPATH["demo837-claims-200.csv",1)
 D EQ(.FAIL,"[T200][header]",TXT["patient_last|claim_id|total_charge",1)
 D EQ(.FAIL,"[T200][row]",TXT["DOE|CLM0001|100",1)
 D EQ(.FAIL,"[T200][planned name]",$G(^MIO("EFUZY","job",200,"plannedOutputName")),"demo837-claims-200.csv")
 D EQ(.FAIL,"[T200][artifact node]",$G(^MIO("EFUZY","job",200,"artifact","profile_export","name")),"demo837-claims-200.csv")
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;
T210(FAIL)
 N CONF,ROOT,POST,PID,ERR,OUTPATH,TXT
 D RESET^EFUZYTESTU("")
 D SEEDJOB(210)
 S ROOT=$$TMPROOT^EFUZYTESTU("csvpt-210")
 D MKDIR^EFUZYTESTU(ROOT),MKDIR^EFUZYTESTU(ROOT_"/exports")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 S POST("name")="Lines Only"
 S POST("exportMode")="custom"
 S POST("selectedFields")="claim_id,line_number,procedure_code"
 S POST("fieldOrder")="claim_id,line_number,procedure_code"
 S POST("rowSource")="line"
 S POST("header")=0
 D EQ(.FAIL,"[T210][save ok]",$$SAVE^EFUZYCFG(.CONF,.POST,.PID,.ERR),1)
 D EQ(.FAIL,"[T210][make ok]",$$MAKE^EFU837CSV(.CONF,210,PID,.OUTPATH,.ERR),1)
 D EQ(.FAIL,"[T210][read ok]",$$READFILE^EFUZYTESTU(OUTPATH,.TXT),1)
 D EQ(.FAIL,"[T210][no header]",TXT["claim_id,line_number,procedure_code",0)
 D EQ(.FAIL,"[T210][line1]",TXT["CLM0001,1,99213",1)
 D EQ(.FAIL,"[T210][line2]",TXT["CLM0001,2,87070",1)
 D EQ(.FAIL,"[T210][has lf]",$$HASLF(TXT),1)
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;
T220(FAIL)
 N CONF,ROOT,POST,PID,ERR,OUTPATH,TXT
 D RESET^EFUZYTESTU("")
 D SEEDJOB(220)
 S ROOT=$$TMPROOT^EFUZYTESTU("csvpt-220")
 D MKDIR^EFUZYTESTU(ROOT),MKDIR^EFUZYTESTU(ROOT_"/exports")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 S POST("name")="Quote All"
 S POST("exportMode")="custom"
 S POST("selectedFields")="claim_id,payer_name"
 S POST("fieldOrder")="claim_id,payer_name"
 S POST("quoteMode")="all"
 D EQ(.FAIL,"[T220][save ok]",$$SAVE^EFUZYCFG(.CONF,.POST,.PID,.ERR),1)
 D EQ(.FAIL,"[T220][make ok]",$$MAKE^EFU837CSV(.CONF,220,PID,.OUTPATH,.ERR),1)
 D EQ(.FAIL,"[T220][read ok]",$$READFILE^EFUZYTESTU(OUTPATH,.TXT),1)
 D EQ(.FAIL,"[T220][row quoted]",TXT["""CLM0001"",""Payer """"A"""", Inc""",1)
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;
HASLF(TXT)
 Q $S($G(TXT)[$C(10):1,$G(TXT)[$C(13):1,1:0)
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
