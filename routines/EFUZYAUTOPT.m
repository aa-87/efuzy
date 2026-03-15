EFUZYAUTOPT ; automation bind and output folder tests
 ; Quiet on success.
 ;
 Q
 ;
START
 D T001
 D T002
 Q
 ;
T001 ; bind automation applies profile and output folder to job run
 N CONF,ROOT,PATH,OK,JOBID,ERR,AID,OUTPATH,TXT
 D RESET^EFUZYTESTU("")
 S ROOT=$$TMPROOT^EFUZYTESTU("auto-run")
 D MKDIR^EFUZYTESTU(ROOT)
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 S PATH=ROOT_"/sample.837"
 D SAMPLE837^EFUZYTESTU(PATH,.OK)
 D OK^MIOTASSERT(OK,"[T001][sample written]")
 D ENSDEFAUT^EFUZYCFG(.CONF,7)
 S AID=$$FINDAUTO^EFUZYCFG(7,"Claim-level export")
 D OK^MIOTASSERT(AID>0,"[T001][auto found]")
 S ^MIO("EFUZY","file",1,"id")=1
 S ^MIO("EFUZY","file",1,"name")="sample.837"
 S ^MIO("EFUZY","file",1,"path")=PATH
 D OK^MIOTASSERT($$CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR,7),"[T001][job created]")
 D OK^MIOTASSERT($$BINDJOBAUTO^EFUZY(.CONF,JOBID,AID,7,.ERR),"[T001][bind ok]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"profileId"))>0,1,"[T001][profile bound]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"outputFolder")),"output/claim-level","[T001][output folder]")
 D OK^MIOTASSERT($$RUN^EFUWFRUN(.CONF,JOBID,.ERR),"[T001][run ok]")
 S OUTPATH=$G(^MIO("EFUZY","job",JOBID,"outputPath"))
 D EQ^MIOTASSERT(OUTPATH[(ROOT_"/output/claim-level/"),1,"[T001][output path routed]")
 D OK^MIOTASSERT($$READFILE^EFUZYTESTU(OUTPATH,.TXT),"[T001][read export]")
 D OK^MIOTASSERT(TXT["CLM0001,100","[T001][claim row]")
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;
T002 ; delete automation removes owner scoped rule
 N CONF,ERR,AID
 D RESET^EFUZYTESTU("")
 D ENSDEFAUT^EFUZYCFG(.CONF,8)
 S AID=$$FINDAUTO^EFUZYCFG(8,"Line-level export")
 D OK^MIOTASSERT(AID>0,"[T002][auto found]")
 D OK^MIOTASSERT($$DELAUTO^EFUZYCFG(.CONF,AID,.ERR,8),"[T002][delete ok]")
 D EQ^MIOTASSERT($D(^MIO("EFUZY","cfg","auto",AID)),0,"[T002][removed]")
 Q
 