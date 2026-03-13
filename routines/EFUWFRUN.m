EFUWFRUN ; workflow execution
 ;
 Q
 ;
RUN(CONF,JOBID,ERR)
 N FILEID,PATH,PROFID,OUTPATH
 K ERR
 I '$D(^MIO("EFUZY","job",+JOBID)) S ERR("error")="job_not_found" Q 0
 S FILEID=$G(^MIO("EFUZY","job",JOBID,"fileId"))
 S PATH=$$GETPATH^EFUZYFS(FILEID)
 I PATH="" S ERR("error")="file_path_missing" Q 0
 S PROFID=$G(^MIO("EFUZY","job",JOBID,"profileId"))
 D START^EFUZYJOB(JOBID)
 I '$$PARSE^EFU837(PATH,JOBID,.ERR) D  Q 0
 . D FINERR^EFUZYJOB(JOBID,$G(ERR("error"),"parse_failed"))
 ; Use the builder routine that the CSV tests exercise directly.
 ; This avoids the EFU837CSV / EFU837CSV2 routine-name split.
 I '$$MAKE^EFU837CSV2(.CONF,JOBID,PROFID,.OUTPATH,.ERR) D  Q 0
 . D FINERR^EFUZYJOB(JOBID,$G(ERR("error"),"export_failed"))
 S ^MIO("EFUZY","job",JOBID,"outputPath")=OUTPATH
 S ^MIO("EFUZY","job",JOBID,"outputName")=$P(OUTPATH,"/",$L(OUTPATH,"/"))
 D FINOK^EFUZYJOB(JOBID)
 Q 1
 ;
