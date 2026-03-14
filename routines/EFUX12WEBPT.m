EFUX12WEBPT ; x12 web payload hardening tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUX12WEBPT"
 Q
 ;
ALL(FAIL)
 D T400(.FAIL)
 D T410(.FAIL)
 D T420(.FAIL)
 D T430(.FAIL)
 Q
 ;
T400(FAIL) ; history supports workflow, status, limit, and start_after
 N ROOT1,ROOT2,PATH1,PATH2,BASE1,BASE2,OPT,RES,HROOT,HRES,ID1,ID2
 S ROOT1=$NA(^TMP($J,"EFUX12WEBPT","job",400,1))
 S ROOT2=$NA(^TMP($J,"EFUX12WEBPT","job",400,2))
 S HROOT=$NA(^TMP($J,"EFUX12WEBPT",400,"hist"))
 S ID1=40001,ID2=40002
 K ^MIO("EFUZY","job",ID1),^MIO("EFUZY","job",ID2)
 S PATH1=$$WRFILE($$DATA^EFU837GOLD("GP001"))
 S PATH2=$$WRFILE($$DATA^EFU837GOLD("GP010"))
 S BASE1=$$TMPBASE("400a"),BASE2=$$TMPBASE("400b")
 K OPT S OPT("jobid")=ID1 D RUN837^EFUX12JOB(PATH1,BASE1,ROOT1,.OPT,.RES)
 K OPT S OPT("jobid")=ID2 D RUN837^EFUX12JOB(PATH2,BASE2,ROOT2,.OPT,.RES)
 S ^MIO("EFUZY","job",ID1,"status")="failed"
 K OPT S OPT("workflow")="837_artifact_job",OPT("status")="completed",OPT("limit")=1
 D HISTORY^EFUX12WEB(HROOT,.OPT,.HRES)
 D EQ(.FAIL,"[T400][history ok]",+$G(HRES("ok")),1)
 D EQ(.FAIL,"[T400][one row]",+$G(HRES("jobs")),1)
 D EQ(.FAIL,"[T400][latest id]",+$G(@HROOT@("response","job",1,"jobid")),ID2)
 K OPT S OPT("workflow")="837_artifact_job",OPT("start_after")=ID2,OPT("limit")=5
 D HISTORY^EFUX12WEB(HROOT,.OPT,.HRES)
 D EQ(.FAIL,"[T400][start after returns older]",+$G(@HROOT@("response","job",1,"jobid")),ID1)
 K ^MIO("EFUZY","job",ID1),^MIO("EFUZY","job",ID2)
 K @ROOT1,@ROOT2,@HROOT Q
 ;
T410(FAIL) ; detail from published job id includes artifacts and trace summary
 N ROOT,PATH,BASE,OPT,RES,DROOT,DRES,JOBID
 S ROOT=$NA(^TMP($J,"EFUX12WEBPT","job",410))
 S DROOT=$NA(^TMP($J,"EFUX12WEBPT",410,"detail"))
 S JOBID=41001
 K ^MIO("EFUZY","job",JOBID)
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP020"))
 S BASE=$$TMPBASE("410")
 S OPT("jobid")=JOBID
 S OPT("trace")=1
 D RUN837^EFUX12JOB(PATH,BASE,ROOT,.OPT,.RES)
 K OPT S OPT("include_trace")=1
 D DETAIL^EFUX12WEB(JOBID,DROOT,.OPT,.DRES)
 D EQ(.FAIL,"[T410][detail ok]",+$G(DRES("ok")),1)
 D EQ(.FAIL,"[T410][job id]",+$G(@DROOT@("response","job","jobid")),JOBID)
 D EQ(.FAIL,"[T410][downloads]",+$G(@DROOT@("response","downloads"))>0,1)
 D EQ(.FAIL,"[T410][trace fields]",+$G(@DROOT@("response","summary","trace_fields"))>0,1)
 K ^MIO("EFUZY","job",JOBID)
 K @ROOT,@DROOT Q
 ;
T420(FAIL) ; preview omits rebuilt while export includes it
 N PATH,BASE1,BASE2,PROOT,EROOT,OPT,PRES,ERES
 S PROOT=$NA(^TMP($J,"EFUX12WEBPT",420,"preview"))
 S EROOT=$NA(^TMP($J,"EFUX12WEBPT",420,"export"))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP001"))
 S BASE1=$$TMPBASE("420p")
 S BASE2=$$TMPBASE("420e")
 D PREVIEW837^EFUX12WEB(PATH,BASE1,PROOT,.OPT,.PRES)
 D EQ(.FAIL,"[T420][preview ok]",+$G(PRES("ok")),1)
 D EQ(.FAIL,"[T420][preview no rebuilt]",$D(@PROOT@("response","artifact","rebuilt_x12"))>0,0)
 K OPT S OPT("build_rebuilt")=1
 D EXPORT837^EFUX12WEB(PATH,BASE2,EROOT,.OPT,.ERES)
 D EQ(.FAIL,"[T420][export ok]",+$G(ERES("ok")),1)
 D EQ(.FAIL,"[T420][export rebuilt]",+$G(@EROOT@("response","artifact","rebuilt_x12","exists")),1)
 K @PROOT,@EROOT Q
 ;
T430(FAIL) ; route definitions remain stable
 N DEF
 D ROUTEDEF^EFUX12WEB(.DEF)
 D EQ(.FAIL,"[T430][route1]",$G(DEF(1,"path")),"/x12/837/preview")
 D EQ(.FAIL,"[T430][route2]",$G(DEF(2,"path")),"/x12/837/export")
 D EQ(.FAIL,"[T430][route3]",$G(DEF(3,"path")),"/x12/jobs")
 D EQ(.FAIL,"[T430][route4]",$G(DEF(4,"path")),"/x12/jobs/:id")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
WRFILE(DATA)
 N PATH,DEV,OLDIO
 S PATH=$$TMPBASE("in")_".edi"
 S DEV=PATH,OLDIO=$IO
 O DEV:(NEWVERSION:STREAM:WRITEONLY):1
 I '$T Q ""
 U DEV W DATA
 C DEV U OLDIO
 Q PATH
 ;
TMPBASE(TAG)
 Q "/tmp/efux12webpt-"_$J_"-"_$TR($G(TAG)," /","__")_"-"_$R(999999)
 ;
