EFUWFRUNT ; tests for EFUWFRUN
 ;
 Q
 ;
START
 D T001
 D T002
 D T003
 Q
 ;
T001 ; full run parses and exports
 N CONF,ROOT,PATH,OK,JOBID,ERR,TXT
 D RESET^EFUZYTESTU("")
 S ROOT=$$TMPROOT^EFUZYTESTU("wf-run")
 D MKDIR^EFUZYTESTU(ROOT)
 D MKDIR^EFUZYTESTU(ROOT_"/exports")
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 S PATH=ROOT_"/sample.837"
 D SAMPLE837^EFUZYTESTU(PATH,.OK)
 D OK^MIOTASSERT(OK,"[T001][sample written]")
 S ^MIO("EFUZY","file",1,"id")=1
 S ^MIO("EFUZY","file",1,"name")="sample.837"
 S ^MIO("EFUZY","file",1,"path")=PATH
 D OK^MIOTASSERT($$CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR),"[T001][job created]")
 D OK^MIOTASSERT($$RUN^EFUWFRUN(.CONF,JOBID,.ERR),"[T001][run ok]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"status")),"completed","[T001][status]")
 D OK^MIOTASSERT($$READFILE^EFUZYTESTU($G(^MIO("EFUZY","job",JOBID,"outputPath")),.TXT),"[T001][read export]")
 D OK^MIOTASSERT(TXT["CLM0001,100","[T001][claim row]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"stats","claimCount")),1,"[T001][claim count]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","job",JOBID,"outputName")),$P($G(^MIO("EFUZY","job",JOBID,"outputPath")),"/",$L($G(^MIO("EFUZY","job",JOBID,"outputPath")),"/")),"[T001][output name]")
 D RMDIR^EFUZYTESTU(ROOT)
 Q
 ;
T002 ; missing job returns not found
 N CONF,ERR
 D RESET^EFUZYTESTU("")
 D EQ^MIOTASSERT($$RUN^EFUWFRUN(.CONF,999,.ERR),0,"[T002][run fail]")
 D EQ^MIOTASSERT($G(ERR("error")),"job_not_found","[T002][error]")
 Q
 ;
T003 ; missing file path returns error
 N CONF,JOBID,ERR
 D RESET^EFUZYTESTU("")
 S ^MIO("EFUZY","file",1,"id")=1
 S ^MIO("EFUZY","file",1,"name")="missing.837"
 D OK^MIOTASSERT($$CREATEQ^EFUZYJOB(.CONF,1,"837_to_csv","manual",.JOBID,.ERR),"[T003][job created]")
 D EQ^MIOTASSERT($$RUN^EFUWFRUN(.CONF,JOBID,.ERR),0,"[T003][run fail]")
 D EQ^MIOTASSERT($G(ERR("error")),"file_path_missing","[T003][error]")
 Q
 ;
