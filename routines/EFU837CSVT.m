EFU837CSVT ; tests for EFU837CSV
 ;
 Q
 ;
START
 D T001
 D T002
 D T003
 D T004
 D T005
 Q
 ;
SEEDJOB(JOBID)
 S ^MIO("EFUZY","job",JOBID,"fileId")=1
 S ^MIO("EFUZY","file",1,"name")="demo837.x12"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"total_charge")="100"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"claim_date")="20260301"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"patient_last")="DOE"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"patient_first")="JANE"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"subscriber_id")="ABC123"
 S ^MIO("EFUZY","job",JOBID,"wrk","claim",1,"service_line_count")=1
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"claim_index")=1
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"claim_id")="CLM0001"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_number")="1"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"procedure_code")="99213"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"procedure_qualifier")="HC"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_charge")="75"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"units")="1"
 S ^MIO("EFUZY","job",JOBID,"wrk","line",1,"line_service_date")="20260301"
 Q
 ;
T001 ; csv escaping
 D EQ^MIOTASSERT($$CSV^EFU837CSV("alpha"),"alpha","[T001][plain]")
 D EQ^MIOTASSERT($$CSV^EFU837CSV("alpha,beta"),"""alpha,beta""","[T001][comma quoted]")
 D EQ^MIOTASSERT($$CSV^EFU837CSV("a""b"),"""a""""b""","[T001][quote doubled]")
 Q
 ;
T002 ; header builder
 D EQ^MIOTASSERT($$HDR^EFU837CSV("claim_id,total_charge",","),"claim_id,total_charge","[T002][header]")
 D EQ^MIOTASSERT($$HDR^EFU837CSV("claim_id,total_charge","|"),"claim_id|total_charge","[T002][header pipe]")
 Q
 ;
T003 ; row builder for claims and lines
 D RESET^EFUZYTESTU("")
 D SEEDJOB(10)
 D EQ^MIOTASSERT($$ROW^EFU837CSV("claim",10,1,"claim_id,total_charge",","),"CLM0001,100","[T003][claim row]")
 D EQ^MIOTASSERT($$ROW^EFU837CSV("line",10,1,"claim_id,line_number,procedure_code",","),"CLM0001,1,99213","[T003][line row]")
 D EQ^MIOTASSERT($$VAL^EFU837CSV("line",10,1,"patient_last"),"DOE","[T003][line fallback to claim]")
 Q
 ;
T004 ; outfile naming substitution
 N CONF,P,PATH,ROOT
 D RESET^EFUZYTESTU("")
 S ROOT=$$TMPROOT^EFUZYTESTU("csv-outfile")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 S ^MIO("EFUZY","job",10,"fileId")=1
 S ^MIO("EFUZY","file",1,"name")="demo837.x12"
 S P("exportMode")="claim_summary"
 S P("outputNamingRule")="{{source_base}}-{{mode}}-{{job_id}}.csv"
 S PATH=$$OUTFILE^EFU837CSV(.CONF,10,.P)
 D OK^MIOTASSERT(PATH["demo837-claim_summary-10.csv","[T004][outfile pattern]")
 Q
 ;
T005 ; make writes csv file
 N CONF,ROOT,OUTPATH,ERR,TXT
 D RESET^EFUZYTESTU("")
 D SEEDJOB(20)
 S ROOT=$$TMPROOT^EFUZYTESTU("csv-make")
 D MKDIR^EFUZYTESTU(ROOT)
 D MKDIR^EFUZYTESTU(ROOT_"/exports")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 D OK^MIOTASSERT($$MAKE^EFU837CSV(.CONF,20,"",.OUTPATH,.ERR),"[T005][make ok]")
 D OK^MIOTASSERT($$READFILE^EFUZYTESTU(OUTPATH,.TXT),"[T005][read ok]")
 D OK^MIOTASSERT(TXT["claim_id,total_charge","[T005][header present]")
 D OK^MIOTASSERT(TXT["CLM0001,100","[T005][row present]")
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;
