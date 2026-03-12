EFUX12WEBT ; efuzy x12 web/workflow integration tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUX12WEBT"
 Q
 ;
ALL(FAIL) ; full suite
 D T990(.FAIL)
 D T991(.FAIL)
 D T992(.FAIL)
 D T993(.FAIL)
 Q
 ;
T990(FAIL) ; preview payload contains summary, preview rows, diagnostics, and no rebuilt artifact by default
 N ROOT,PATH,BASE,OPT,RES
 S ROOT=$NA(^TMP($J,"EFUX12WEBT",990))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP020"))
 S BASE=$$TMPBASE("990")
 D PREVIEW837^EFUX12WEB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T990][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T990][mode]",$G(RES("mode")),"preview")
 D EQ(.FAIL,"[T990][http]",+$G(RES("http_status")),200)
 D EQ(.FAIL,"[T990][claims]",+$G(@ROOT@("response","summary","claims")),1)
 D EQ(.FAIL,"[T990][patient member]",$G(@ROOT@("response","preview","claim",1,"patient_member_id")),"PAT123")
 D EQ(.FAIL,"[T990][subscriber member]",$G(@ROOT@("response","preview","claim",1,"subscriber_member_id")),"SUB123")
 D EQ(.FAIL,"[T990][downloads]",+$G(@ROOT@("response","downloads"))>0,1)
 D EQ(.FAIL,"[T990][rebuilt missing]",$D(@ROOT@("response","artifact","rebuilt_x12"))>0,0)
 K @ROOT Q
 ;
T991(FAIL) ; export payload includes rebuilt and roundtrip artifacts when requested
 N ROOT,PATH,BASE,OPT,RES
 S ROOT=$NA(^TMP($J,"EFUX12WEBT",991))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP010"))
 S BASE=$$TMPBASE("991")
 S OPT("roundtrip")=1
 S OPT("compare_mode")="export_safe"
 D EXPORT837^EFUX12WEB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T991][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T991][http]",+$G(RES("http_status")),200)
 D EQ(.FAIL,"[T991][rebuilt exists]",+$G(@ROOT@("response","artifact","rebuilt_x12","exists")),1)
 D EQ(.FAIL,"[T991][roundtrip exists]",+$G(@ROOT@("response","artifact","roundtrip_report","exists")),1)
 D EQ(.FAIL,"[T991][roundtrip ok]",+$G(@ROOT@("response","summary","roundtrip_ok")),1)
 K @ROOT Q
 ;
T992(FAIL) ; detail from live job root includes preview and diagnostics
 N JROOT,WROOT,PATH,BASE,OPT,RES,JRES
 S JROOT=$NA(^TMP($J,"EFUX12WEBT","job",992))
 S WROOT=$NA(^TMP($J,"EFUX12WEBT",992))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP040"))
 S BASE=$$TMPBASE("992")
 D RUN837^EFUX12JOB(PATH,BASE,JROOT,.OPT,.JRES)
 D DETAIL^EFUX12WEB(JROOT,WROOT,.OPT,.RES)
 D EQ(.FAIL,"[T992][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T992][mode]",$G(RES("mode")),"detail")
 D EQ(.FAIL,"[T992][patient preview exists]",$G(@WROOT@("response","preview","claim",1,"claim_id"))'="",1)
 D EQ(.FAIL,"[T992][diagnostic warnings]",+$G(@WROOT@("response","diagnostic","warnings"))>=0,1)
 D EQ(.FAIL,"[T992][job status]",$G(@WROOT@("response","job","status")),"completed")
 K @WROOT K @JROOT Q
 ;
T993(FAIL) ; published history and detail list jobs and artifacts
 N ROOT1,ROOT2,HROOT,DROOT,PATH1,PATH2,BASE1,BASE2,OPT1,OPT2,RES,HRES,DRES,ID1,ID2
 S ROOT1=$NA(^TMP($J,"EFUX12WEBT","job",993,1))
 S ROOT2=$NA(^TMP($J,"EFUX12WEBT","job",993,2))
 S HROOT=$NA(^TMP($J,"EFUX12WEBT",993,"history"))
 S DROOT=$NA(^TMP($J,"EFUX12WEBT",993,"detail"))
 S PATH1=$$WRFILE($$DATA^EFU837GOLD("GP001"))
 S PATH2=$$WRFILE($$DATA^EFU837GOLD("GP010"))
 S BASE1=$$TMPBASE("993a"),BASE2=$$TMPBASE("993b")
 S ID1=99301,ID2=99302
 K ^MIO("EFUZY","job",ID1),^MIO("EFUZY","job",ID2)
 S OPT1("jobid")=ID1
 S OPT2("jobid")=ID2
 D RUN837^EFUX12JOB(PATH1,BASE1,ROOT1,.OPT1,.RES)
 D RUN837^EFUX12JOB(PATH2,BASE2,ROOT2,.OPT2,.RES)
 K OPT1 S OPT1("limit")=10 S OPT1("workflow")="837_artifact_job"
 D HISTORY^EFUX12WEB(HROOT,.OPT1,.HRES)
 D EQ(.FAIL,"[T993][history ok]",+$G(HRES("ok")),1)
 D EQ(.FAIL,"[T993][history jobs]",+$G(HRES("jobs"))>0,1)
 D EQ(.FAIL,"[T993][history contains 99302]",$$HASJOB(HROOT,ID2),1)
 D DETAIL^EFUX12WEB(ID2,DROOT,.OPT1,.DRES)
 D EQ(.FAIL,"[T993][detail ok]",+$G(DRES("ok")),1)
 D EQ(.FAIL,"[T993][detail jobid]",+$G(@DROOT@("response","job","jobid")),ID2)
 D EQ(.FAIL,"[T993][detail downloads]",+$G(@DROOT@("response","downloads"))>0,1)
 K ^MIO("EFUZY","job",ID1),^MIO("EFUZY","job",ID2)
 K @ROOT1 K @ROOT2 K @HROOT K @DROOT Q
 ;
HASJOB(ROOT,JOBID) ; return 1 if history payload contains JOBID
 N N
 S N=0
 F  S N=$O(@ROOT@("response","job",N)) Q:'N  I +$G(@ROOT@("response","job",N,"jobid"))=+JOBID Q
 Q $S(+N>0:1,1:0)
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
WRFILE(DATA) ; write DATA to temporary file path and return it
 N PATH,DEV,OLDIO
 S PATH=$$TMPBASE("in")_".edi"
 S DEV=PATH,OLDIO=$IO
 O DEV:(NEWVERSION:STREAM:WRITEONLY):1
 I '$T Q ""
 U DEV W DATA
 C DEV
 U OLDIO
 Q PATH
 ;
TMPBASE(TAG) ; temporary work stem
 Q "/tmp/efux12webt-"_$J_"-"_$TR($G(TAG)," /","__")_"-"_$R(999999)
 ;
