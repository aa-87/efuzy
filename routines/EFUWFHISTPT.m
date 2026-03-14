EFUWFHISTPT ; efuzy history/view-model hardening tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUWFHISTPT"
 Q
 ;
ALL(FAIL)
 D T600(.FAIL)
 D T610(.FAIL)
 D T620(.FAIL)
 D T630(.FAIL)
 Q
 ;
SEEDJ(ID,FILEID,STATUS)
 S ^MIO("EFUZY","file",FILEID,"id")=FILEID
 S ^MIO("EFUZY","file",FILEID,"name")="file"_FILEID_".x12"
 S ^MIO("EFUZY","job",ID,"id")=ID
 S ^MIO("EFUZY","job",ID,"fileId")=FILEID
 S ^MIO("EFUZY","job",ID,"workflowType")="837_to_csv"
 S ^MIO("EFUZY","job",ID,"status")=$G(STATUS)
 S ^MIO("EFUZY","job",ID,"createdAt")="2026-03-14T12:00:0"_ID_"Z"
 Q
 ;
T600(FAIL) ; load recent sorts latest first with links and file names
 N CONF,TCTX
 D RESET^EFUZYTESTU("")
 D SEEDJ(1,11,"queued")
 D SEEDJ(2,12,"completed")
 D LOADRECENT^EFUWFHIST(.CONF,10,.TCTX)
 D EQ(.FAIL,"[T600][latest id]",+$G(TCTX("recentJobs",1,"id")),2)
 D EQ(.FAIL,"[T600][latest file]",$G(TCTX("recentJobs",1,"fileName")),"file12.x12")
 D EQ(.FAIL,"[T600][preview href]",$G(TCTX("recentJobs",1,"href")),"/efuzy/preview/2")
 D EQ(.FAIL,"[T600][export href]",$G(TCTX("recentJobs",1,"exportHref")),"/efuzy/api/export/2")
 Q
 ;
T610(FAIL) ; load job includes stats, warnings, details, and output path
 N CONF,TCTX
 D RESET^EFUZYTESTU("")
 D SEEDJ(10,20,"failed")
 S ^MIO("EFUZY","job",10,"profileId")=3
 S ^MIO("EFUZY","job",10,"warningCount")=2
 S ^MIO("EFUZY","job",10,"errorCount")=1
 S ^MIO("EFUZY","job",10,"diagSummary")="parse_failed"
 S ^MIO("EFUZY","job",10,"outputPath")="tmp/demo.csv"
 S ^MIO("EFUZY","job",10,"stats","claimCount")=4
 S ^MIO("EFUZY","job",10,"stats","lineCount")=7
 S ^MIO("EFUZY","job",10,"diag","warning",1)="warn one"
 S ^MIO("EFUZY","job",10,"diag","detail",1)="detail one"
 D LOADJOB^EFUWFHIST(.CONF,10,.TCTX)
 D EQ(.FAIL,"[T610][status]",$G(TCTX("job","status")),"failed")
 D EQ(.FAIL,"[T610][file name]",$G(TCTX("job","fileName")),"file20.x12")
 D EQ(.FAIL,"[T610][stat key]",$G(TCTX("job","stats",1,"key")),"claimCount")
 D EQ(.FAIL,"[T610][warning text]",$G(TCTX("job","warnings",1,"text")),"warn one")
 D EQ(.FAIL,"[T610][detail text]",$G(TCTX("job","details",1,"text")),"detail one")
 D EQ(.FAIL,"[T610][output path]",$G(TCTX("job","outputPath")),"tmp/demo.csv")
 Q
 ;
T620(FAIL) ; listjson honors status filter
 N CONF,REQ,OBJ
 D RESET^EFUZYTESTU("")
 D SEEDJ(21,31,"completed")
 D SEEDJ(22,32,"failed")
 S REQ("query","status")="completed"
 D LISTJSON^EFUWFHIST(.CONF,.REQ,.OBJ)
 D EQ(.FAIL,"[T620][ok]",+$G(OBJ("ok")),1)
 D EQ(.FAIL,"[T620][one row]",+$D(OBJ("jobs",2))>0,0)
 D EQ(.FAIL,"[T620][completed id]",+$G(OBJ("jobs",1,"id")),21)
 D EQ(.FAIL,"[T620][completed file]",$G(OBJ("jobs",1,"fileName")),"file31.x12")
 Q
 ;
T630(FAIL) ; getjson missing and existing behavior
 N CONF,OBJ
 D RESET^EFUZYTESTU("")
 D EQ(.FAIL,"[T630][missing]",$$GETJSON^EFUWFHIST(.CONF,99,.OBJ),0)
 D SEEDJ(30,40,"completed")
 S ^MIO("EFUZY","job",30,"outputPath")="tmp/out.csv"
 D EQ(.FAIL,"[T630][get ok]",$$GETJSON^EFUWFHIST(.CONF,30,.OBJ),1)
 D EQ(.FAIL,"[T630][file name]",$G(OBJ("job","fileName")),"file40.x12")
 D EQ(.FAIL,"[T630][output]",$G(OBJ("job","outputPath")),"tmp/out.csv")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
