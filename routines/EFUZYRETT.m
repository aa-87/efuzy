EFUZYRETT ; tests for EFUZYRET
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
T001 ; stale staged/upload file is removed with its global record
 N ROOT,CONF,RES,OK,PATH,OPT
 S ROOT=$$TMPROOT^EFUZYTESTU("ret1")
 D RESET^EFUZYTESTU(ROOT)
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 D STARTUP^EFUZYBOOT(.CONF,.RES)
 S PATH=ROOT_"/uploads/1-old.x12"
 D WRITEFILE^EFUZYTESTU(PATH,"abc",.OK)
 S ^MIO("EFUZY","file",1,"id")=1
 S ^MIO("EFUZY","file",1,"path")=PATH
 S ^MIO("EFUZY","file",1,"createdAt")="2020-01-01T00:00:00Z"
 D OK^MIOTASSERT($$RUN^EFUZYRET(.CONF,.OPT,.RES),"[T001][retention ok]")
 D OK^MIOTASSERT('$D(^MIO("EFUZY","file",1)),"[T001][file record removed]")
 D EQ^MIOTASSERT($$EXISTS^EFUZYTESTU(PATH),0,"[T001][file deleted]")
 D RESET^EFUZYTESTU(ROOT)
 Q
 ;
T002 ; running jobs are preserved
 N ROOT,CONF,RES,OK,PATH,OPT
 S ROOT=$$TMPROOT^EFUZYTESTU("ret2")
 D RESET^EFUZYTESTU(ROOT)
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 D STARTUP^EFUZYBOOT(.CONF,.RES)
 S PATH=ROOT_"/jobs/7/runtime.txt"
 D MKDIR^EFUZYTESTU(ROOT_"/jobs/7")
 D WRITEFILE^EFUZYTESTU(PATH,"live",.OK)
 S ^MIO("EFUZY","job",7,"id")=7
 S ^MIO("EFUZY","job",7,"status")="running"
 S ^MIO("EFUZY","job",7,"createdAt")="2020-01-01T00:00:00Z"
 D OK^MIOTASSERT($$RUN^EFUZYRET(.CONF,.OPT,.RES),"[T002][retention ok]")
 D OK^MIOTASSERT($D(^MIO("EFUZY","job",7))>0,"[T002][job kept]")
 D EQ^MIOTASSERT($$EXISTS^EFUZYTESTU(PATH),1,"[T002][file kept]")
 D RESET^EFUZYTESTU(ROOT)
 Q
 ;
T003 ; stale completed job removes artifacts and job directory
 N ROOT,CONF,RES,OK,PATH,OPT
 S ROOT=$$TMPROOT^EFUZYTESTU("ret3")
 D RESET^EFUZYTESTU(ROOT)
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 D STARTUP^EFUZYBOOT(.CONF,.RES)
 D MKDIR^EFUZYTESTU(ROOT_"/jobs/9")
 S PATH=ROOT_"/exports/job9.csv"
 D WRITEFILE^EFUZYTESTU(PATH,"csv",.OK)
 S ^MIO("EFUZY","job",9,"id")=9
 S ^MIO("EFUZY","job",9,"status")="completed"
 S ^MIO("EFUZY","job",9,"endedAt")="2020-01-01T00:00:00Z"
 S ^MIO("EFUZY","job",9,"artifact","profile_csv","path")=PATH
 S ^MIO("EFUZY","idx","job","status","completed",9)=""
 D OK^MIOTASSERT($$RUN^EFUZYRET(.CONF,.OPT,.RES),"[T003][retention ok]")
 D OK^MIOTASSERT('$D(^MIO("EFUZY","job",9)),"[T003][job removed]")
 D EQ^MIOTASSERT($$EXISTS^EFUZYTESTU(PATH),0,"[T003][artifact deleted]")
 D EQ^MIOTASSERT($$DIREX^EFUZYHEALTH(ROOT_"/jobs/9"),0,"[T003][job dir deleted]")
 D RESET^EFUZYTESTU(ROOT)
 Q
 ;
T004 ; published job is preserved by default
 N ROOT,CONF,RES,OK,PATH,OPT
 S ROOT=$$TMPROOT^EFUZYTESTU("ret4")
 D RESET^EFUZYTESTU(ROOT)
 D SETCONF^EFUZYTESTU(.CONF,ROOT)
 D STARTUP^EFUZYBOOT(.CONF,.RES)
 S PATH=ROOT_"/exports/job11.csv"
 D WRITEFILE^EFUZYTESTU(PATH,"csv",.OK)
 S ^MIO("EFUZY","job",11,"id")=11
 S ^MIO("EFUZY","job",11,"status")="published"
 S ^MIO("EFUZY","job",11,"endedAt")="2020-01-01T00:00:00Z"
 S ^MIO("EFUZY","job",11,"artifact","profile_csv","path")=PATH
 D OK^MIOTASSERT($$RUN^EFUZYRET(.CONF,.OPT,.RES),"[T004][retention ok]")
 D OK^MIOTASSERT($D(^MIO("EFUZY","job",11))>0,"[T004][published kept]")
 D EQ^MIOTASSERT($$EXISTS^EFUZYTESTU(PATH),1,"[T004][artifact kept]")
 D RESET^EFUZYTESTU(ROOT)
 Q
 ;
