EFUZYJOB ; efuzy job lifecycle helpers
	;
	Q
	;
NEXTID()
	N ID
	L +^MIO("EFUZY","SEQ","JOB"):2 E  Q 0
	S ID=$I(^MIO("EFUZY","SEQ","JOB"))
	L -^MIO("EFUZY","SEQ","JOB")
	Q ID
	;
CREATEQ(CONF,FILEID,WF,RUNMODE,JOBID,ERR,USERID)
	K ERR
	S JOBID=$$NEXTID()
	I 'JOBID D  Q:$QUIT 0 Q
	. S ERR("error")="job_seq_busy"
	S ^MIO("EFUZY","job",JOBID,"id")=JOBID
	S ^MIO("EFUZY","job",JOBID,"fileId")=$G(FILEID)
	S ^MIO("EFUZY","job",JOBID,"workflowType")=$G(WF)
	S ^MIO("EFUZY","job",JOBID,"runMode")=$G(RUNMODE)
	S ^MIO("EFUZY","job",JOBID,"status")="queued"
	S ^MIO("EFUZY","job",JOBID,"warningCount")=0
	S ^MIO("EFUZY","job",JOBID,"errorCount")=0
	S ^MIO("EFUZY","job",JOBID,"createdAt")=$$NOWISO^MIOUTIL()
	S ^MIO("EFUZY","idx","job","status","queued",JOBID)=""
	;
	; Optional explicit USERID keeps the new demo-auth staging path compatible,
	; while still allowing older callers to omit it.;
	S USERID=+$G(USERID)
	I USERID<1 S USERID=+$G(CONF("efuzy","userId"))
	I USERID>0 D STAMPJOB^EFUZYAUTH(JOBID,USERID)
	Q:$QUIT 1 Q
	;
SETST(JOBID,STATUS)
	N OLD,UID
	S OLD=$G(^MIO("EFUZY","job",JOBID,"status"))
	S UID=+$G(^MIO("EFUZY","job",JOBID,"ownerId"))
	I OLD'="" K ^MIO("EFUZY","idx","job","status",OLD,JOBID)
	I UID>0,OLD'="" K ^MIO("EFUZY","idx","user",UID,"job","status",OLD,JOBID)
	I UID>0,OLD'="" K ^MIO("EFUZY","idx","job","ownerStatus",UID,OLD,JOBID)
	S ^MIO("EFUZY","job",JOBID,"status")=$G(STATUS)
	I STATUS'="" S ^MIO("EFUZY","idx","job","status",STATUS,JOBID)=""
	I UID>0,STATUS'="" S ^MIO("EFUZY","idx","user",UID,"job","status",STATUS,JOBID)=""
	I UID>0,STATUS'="" S ^MIO("EFUZY","idx","job","ownerStatus",UID,STATUS,JOBID)=""
	Q
	;
START(JOBID)
	D SETST(JOBID,"running")
	S ^MIO("EFUZY","job",JOBID,"startedAt")=$$NOWISO^MIOUTIL()
	K ^MIO("EFUZY","job",JOBID,"diag")
	K ^MIO("EFUZY","job",JOBID,"wrk")
	Q
	;
FINOK(JOBID)
	D SETST(JOBID,"completed")
	S ^MIO("EFUZY","job",JOBID,"endedAt")=$$NOWISO^MIOUTIL()
	Q
	;
FINERR(JOBID,ERRTXT)
	D SETST(JOBID,"failed")
	S ^MIO("EFUZY","job",JOBID,"endedAt")=$$NOWISO^MIOUTIL()
	S ^MIO("EFUZY","job",JOBID,"diagSummary")=$G(ERRTXT)
	S ^MIO("EFUZY","job",JOBID,"errorCount")=+$G(^MIO("EFUZY","job",JOBID,"errorCount"))+1
	Q
	;
WARN(JOBID,TXT)
	N N
	S N=$O(^MIO("EFUZY","job",JOBID,"diag","warning",""),-1)+1
	S ^MIO("EFUZY","job",JOBID,"diag","warning",N)=TXT
	S ^MIO("EFUZY","job",JOBID,"warningCount")=+$G(^MIO("EFUZY","job",JOBID,"warningCount"))+1
	Q
	;
DIAG(JOBID,TXT)
	N N
	S N=$O(^MIO("EFUZY","job",JOBID,"diag","detail",""),-1)+1
	S ^MIO("EFUZY","job",JOBID,"diag","detail",N)=TXT
	Q
	;
SETSTAT(JOBID,KEY,VAL)
	S ^MIO("EFUZY","job",JOBID,"stats",KEY)=VAL
	Q
	;
RETRY(CONF,JOBID,NEWID,ERR,USERID)
	N FILEID,WF,PROF,OWNERID
	S JOBID=+JOBID
	S FILEID=$G(^MIO("EFUZY","job",JOBID,"fileId"))
	S WF=$G(^MIO("EFUZY","job",JOBID,"workflowType"))
	S OWNERID=+$G(^MIO("EFUZY","job",JOBID,"ownerId"))
	I +$G(USERID)>0,OWNERID'=+USERID S ERR("error")="job_not_found" Q:$QUIT 0 Q
	I 'OWNERID S OWNERID=+$G(CONF("efuzy","userId"))
	I FILEID="" D  Q:$QUIT 0 Q
	. S ERR("error")="job_missing_file"
	I '$$CREATEQ(.CONF,FILEID,WF,"manual",.NEWID,.ERR,OWNERID) Q:$QUIT 0 Q
	S PROF=$G(^MIO("EFUZY","job",JOBID,"profileId"))
	I PROF'="" S ^MIO("EFUZY","job",NEWID,"profileId")=PROF
	Q:$QUIT 1 Q
	;
	;