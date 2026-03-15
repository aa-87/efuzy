EFUWFHIST ; efuzy job history helpers
 ;
 Q
 ;
LOADRECENT(CONF,LIMIT,TCTX,USERID)
 N ID,N,MAX
 S N=0,MAX=+$G(LIMIT) I MAX<1 S MAX=10
 I +$G(USERID)>0 D  Q
 . S ID=$O(^MIO("EFUZY","idx","owner","job",+USERID,""),-1)
 . F  Q:ID=""!(N>=MAX)  D  S ID=$O(^MIO("EFUZY","idx","owner","job",+USERID,ID),-1)
 . . I '$D(^MIO("EFUZY","job",ID)) Q
 . . D JOBCTX(ID,.TCTX,.N,+$G(USERID))
 . I 'N S TCTX("recentEmpty")=1
 S ID=""
 F  S ID=$O(^MIO("EFUZY","job",ID),-1) Q:ID=""!(N>=MAX)  D JOBCTX(ID,.TCTX,.N)
 I 'N S TCTX("recentEmpty")=1
 Q
 ;
LOADJOB(CONF,JOBID,TCTX,USERID)
 N ID
 S ID=+JOBID
 I 'ID S TCTX("jobMissing")=1 Q
 I '$D(^MIO("EFUZY","job",ID)) S TCTX("jobMissing")=1 Q
 I +$G(USERID)>0,'$$OWNSJOB^EFUZYAUTH(+USERID,ID) S TCTX("jobMissing")=1 Q
 S TCTX("job","id")=ID
 S TCTX("job","status")=$G(^MIO("EFUZY","job",ID,"status"))
 S TCTX("job","workflowType")=$G(^MIO("EFUZY","job",ID,"workflowType"))
 S TCTX("job","profileId")=$G(^MIO("EFUZY","job",ID,"profileId"))
 S TCTX("job","createdAt")=$G(^MIO("EFUZY","job",ID,"createdAt"))
 S TCTX("job","startedAt")=$G(^MIO("EFUZY","job",ID,"startedAt"))
 S TCTX("job","endedAt")=$G(^MIO("EFUZY","job",ID,"endedAt"))
 S TCTX("job","warningCount")=$G(^MIO("EFUZY","job",ID,"warningCount"))
 S TCTX("job","errorCount")=$G(^MIO("EFUZY","job",ID,"errorCount"))
 S TCTX("job","diagSummary")=$G(^MIO("EFUZY","job",ID,"diagSummary"))
 S TCTX("job","outputPath")=$G(^MIO("EFUZY","job",ID,"outputPath"))
 S TCTX("job","exportHref")="/efuzy/api/export/"_ID
 S TCTX("job","fileId")=$G(^MIO("EFUZY","job",ID,"fileId"))
 S TCTX("job","fileName")=$$GETNAME^EFUZYFS($G(^MIO("EFUZY","job",ID,"fileId")),+$G(USERID))
 D STATSCTX(ID,.TCTX)
 D DIAGCTX(ID,.TCTX)
 Q
 ;
STATSCTX(JOBID,TCTX)
 N K,N
 S N=0,K=""
 F  S K=$O(^MIO("EFUZY","job",JOBID,"stats",K)) Q:K=""  D
 . S N=N+1
 . S TCTX("job","stats",N,"key")=K
 . S TCTX("job","stats",N,"value")=$G(^MIO("EFUZY","job",JOBID,"stats",K))
 Q
 ;
DIAGCTX(JOBID,TCTX)
 N I
 S I=0
 F  S I=$O(^MIO("EFUZY","job",JOBID,"diag","warning",I)) Q:'I  D
 . S TCTX("job","warnings",I,"text")=$G(^MIO("EFUZY","job",JOBID,"diag","warning",I))
 S I=0
 F  S I=$O(^MIO("EFUZY","job",JOBID,"diag","detail",I)) Q:'I  D
 . S TCTX("job","details",I,"text")=$G(^MIO("EFUZY","job",JOBID,"diag","detail",I))
 Q
 ;
JOBCTX(ID,TCTX,N,USERID)
 I +$G(USERID)>0,'$$OWNSJOB^EFUZYAUTH(+USERID,ID) Q
 S N=N+1
 S TCTX("recentJobs",N,"id")=ID
 S TCTX("recentJobs",N,"status")=$G(^MIO("EFUZY","job",ID,"status"))
 S TCTX("recentJobs",N,"workflowType")=$G(^MIO("EFUZY","job",ID,"workflowType"))
 S TCTX("recentJobs",N,"createdAt")=$G(^MIO("EFUZY","job",ID,"createdAt"))
 S TCTX("recentJobs",N,"fileName")=$$GETNAME^EFUZYFS($G(^MIO("EFUZY","job",ID,"fileId")),+$G(USERID))
 S TCTX("recentJobs",N,"href")="/efuzy/preview/"_ID
 S TCTX("recentJobs",N,"exportHref")="/efuzy/api/export/"_ID
 Q
 ;
LISTJSON(CONF,REQ,OBJ,USERID)
 N ID,N,STATUS
 S OBJ("ok")=1,N=0
 S STATUS=$G(REQ("query","status"))
 I +$G(USERID)>0 D  Q
 . S ID=0
 . F  S ID=$O(^MIO("EFUZY","idx","owner","job",+USERID,ID)) Q:'ID  D
 . . I '$D(^MIO("EFUZY","job",ID)) Q
 . . I STATUS'="",$G(^MIO("EFUZY","job",ID,"status"))'=STATUS Q
 . . S N=N+1
 . . D JOBJSON(ID,.OBJ,N,+$G(USERID))
 S ID=0
 F  S ID=$O(^MIO("EFUZY","job",ID)) Q:'ID  D
 . I STATUS'="",$G(^MIO("EFUZY","job",ID,"status"))'=STATUS Q
 . S N=N+1
 . D JOBJSON(ID,.OBJ,N)
 Q
 ;
JOBJSON(ID,OBJ,N,USERID)
 S OBJ("jobs",N,"id")=ID
 S OBJ("jobs",N,"status")=$G(^MIO("EFUZY","job",ID,"status"))
 S OBJ("jobs",N,"workflowType")=$G(^MIO("EFUZY","job",ID,"workflowType"))
 S OBJ("jobs",N,"createdAt")=$G(^MIO("EFUZY","job",ID,"createdAt"))
 S OBJ("jobs",N,"fileId")=$G(^MIO("EFUZY","job",ID,"fileId"))
 S OBJ("jobs",N,"fileName")=$$GETNAME^EFUZYFS($G(^MIO("EFUZY","job",ID,"fileId")),+$G(USERID))
 S OBJ("jobs",N,"outputPath")=$G(^MIO("EFUZY","job",ID,"outputPath"))
 Q
 ;
GETJSON(CONF,ID,OBJ,USERID)
 I +$G(ID)<1 Q 0
 I '$D(^MIO("EFUZY","job",ID)) Q 0
 I +$G(USERID)>0,'$$OWNSJOB^EFUZYAUTH(+USERID,+ID) Q 0
 S OBJ("ok")=1
 S OBJ("job","id")=ID
 S OBJ("job","status")=$G(^MIO("EFUZY","job",ID,"status"))
 S OBJ("job","workflowType")=$G(^MIO("EFUZY","job",ID,"workflowType"))
 S OBJ("job","fileId")=$G(^MIO("EFUZY","job",ID,"fileId"))
 S OBJ("job","fileName")=$$GETNAME^EFUZYFS($G(^MIO("EFUZY","job",ID,"fileId")),+$G(USERID))
 S OBJ("job","outputPath")=$G(^MIO("EFUZY","job",ID,"outputPath"))
 S OBJ("job","warningCount")=$G(^MIO("EFUZY","job",ID,"warningCount"))
 S OBJ("job","errorCount")=$G(^MIO("EFUZY","job",ID,"errorCount"))
 Q 1
 ;
