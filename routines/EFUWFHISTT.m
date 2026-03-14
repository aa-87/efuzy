EFUWFHISTT ; tests for EFUWFHIST
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
SEED
 S ^MIO("EFUZY","file",1,"name")="alpha.x12"
 S ^MIO("EFUZY","file",2,"name")="beta.x12"
 S ^MIO("EFUZY","job",1,"id")=1
 S ^MIO("EFUZY","job",1,"status")="queued"
 S ^MIO("EFUZY","job",1,"workflowType")="837_to_csv"
 S ^MIO("EFUZY","job",1,"createdAt")="2026-03-09T01:00:00Z"
 S ^MIO("EFUZY","job",1,"fileId")=1
 S ^MIO("EFUZY","job",2,"id")=2
 S ^MIO("EFUZY","job",2,"status")="completed"
 S ^MIO("EFUZY","job",2,"workflowType")="837_to_csv"
 S ^MIO("EFUZY","job",2,"createdAt")="2026-03-09T02:00:00Z"
 S ^MIO("EFUZY","job",2,"fileId")=2
 S ^MIO("EFUZY","job",2,"outputPath")="tmp/out.csv"
 S ^MIO("EFUZY","job",2,"warningCount")=1
 S ^MIO("EFUZY","job",2,"errorCount")=0
 S ^MIO("EFUZY","job",2,"stats","claimCount")=1
 S ^MIO("EFUZY","job",2,"diag","warning",1)="warning one"
 S ^MIO("EFUZY","job",2,"diag","detail",1)="detail one"
 Q
 ;
T001 ; load recent jobs descending
 N CONF,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 D LOADRECENT^EFUWFHIST(.CONF,5,.TCTX)
 D EQ^MIOTASSERT($G(TCTX("recentJobs",1,"id")),2,"[T001][latest first]")
 D EQ^MIOTASSERT($G(TCTX("recentJobs",1,"fileName")),"beta.x12","[T001][file name]")
 D EQ^MIOTASSERT($G(TCTX("recentJobs",2,"id")),1,"[T001][older second]")
 Q
 ;
T002 ; load job includes stats and diagnostics
 N CONF,TCTX
 D RESET^EFUZYTESTU("")
 D SEED
 D LOADJOB^EFUWFHIST(.CONF,2,.TCTX)
 D EQ^MIOTASSERT($G(TCTX("job","status")),"completed","[T002][status]")
 D EQ^MIOTASSERT($G(TCTX("job","fileName")),"beta.x12","[T002][file name]")
 D EQ^MIOTASSERT($G(TCTX("job","stats",1,"key")),"claimCount","[T002][stat key]")
 D EQ^MIOTASSERT($G(TCTX("job","warnings",1,"text")),"warning one","[T002][warning]")
 D EQ^MIOTASSERT($G(TCTX("job","details",1,"text")),"detail one","[T002][detail]")
 Q
 ;
T003 ; listjson filters by status
 N CONF,REQ,OBJ
 D RESET^EFUZYTESTU("")
 D SEED
 S REQ("query","status")="completed"
 D LISTJSON^EFUWFHIST(.CONF,.REQ,.OBJ)
 D EQ^MIOTASSERT($G(OBJ("ok")),1,"[T003][ok]")
 D EQ^MIOTASSERT($G(OBJ("jobs",1,"id")),2,"[T003][completed job]")
 D NOTHAS^MIOTASSERT("OBJ(""jobs"",2)","[T003][only one result]")
 Q
 ;
T004 ; getjson missing and success
 N CONF,OBJ
 D RESET^EFUZYTESTU("")
 D SEED
 D EQ^MIOTASSERT($$GETJSON^EFUWFHIST(.CONF,0,.OBJ),0,"[T004][missing zero id]")
 D OK^MIOTASSERT($$GETJSON^EFUWFHIST(.CONF,2,.OBJ),"[T004][get ok]")
 D EQ^MIOTASSERT($G(OBJ("job","outputPath")),"tmp/out.csv","[T004][output path]")
 Q
 ;
