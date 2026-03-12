EFUX12JOBT ; efuzy x12 job artifact packaging tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUX12JOBT"
 Q
 ;
ALL(FAIL) ; full suite
 D T980(.FAIL)
 D T981(.FAIL)
 D T982(.FAIL)
 D T983(.FAIL)
 Q
 ;
T980(FAIL) ; standard artifact run produces canonical, rebuilt, and reports
 N ROOT,PATH,BASE,OPT,RES
 S ROOT=$NA(^TMP($J,"EFUX12JOBT",980))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP001"))
 S BASE=$$TMPBASE("980")
 D RUN837^EFUX12JOB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T980][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T980][status]",$G(@ROOT@("meta","status")),"completed")
 D EQ(.FAIL,"[T980][claims]",+$G(@ROOT@("summary","claims")),1)
 D EQ(.FAIL,"[T980][lines]",+$G(@ROOT@("summary","lines")),1)
 D EQ(.FAIL,"[T980][input exists]",+$G(@ROOT@("artifact","input_raw","exists")),1)
 D EQ(.FAIL,"[T980][canonical claims exists]",+$G(@ROOT@("artifact","canonical_claims","exists")),1)
 D EQ(.FAIL,"[T980][canonical lines exists]",+$G(@ROOT@("artifact","canonical_lines","exists")),1)
 D EQ(.FAIL,"[T980][rebuilt exists]",+$G(@ROOT@("artifact","rebuilt_x12","exists")),1)
 D EQ(.FAIL,"[T980][parse summary exists]",+$G(@ROOT@("artifact","parse_summary","exists")),1)
 D EQ(.FAIL,"[T980][job manifest exists]",+$G(@ROOT@("artifact","job_manifest","exists")),1)
 K @ROOT Q
 ;
T981(FAIL) ; roundtrip mode creates compare report and marks roundtrip ok
 N ROOT,PATH,BASE,OPT,RES
 S ROOT=$NA(^TMP($J,"EFUX12JOBT",981))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP010"))
 S BASE=$$TMPBASE("981")
 S OPT("roundtrip")=1
 S OPT("compare_mode")="export_safe"
 D RUN837^EFUX12JOB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T981][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T981][roundtrip ok]",+$G(@ROOT@("summary","roundtrip_ok")),1)
 D EQ(.FAIL,"[T981][compare mode]",$G(@ROOT@("meta","compare_mode")),"export_safe")
 D EQ(.FAIL,"[T981][report exists]",+$G(@ROOT@("artifact","roundtrip_report","exists")),1)
 K @ROOT Q
 ;
T982(FAIL) ; preview preserves distinct patient/subscriber separation
 N ROOT,PATH,BASE,OPT,RES
 S ROOT=$NA(^TMP($J,"EFUX12JOBT",982))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP020"))
 S BASE=$$TMPBASE("982")
 D RUN837^EFUX12JOB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T982][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T982][subscriber member]",$G(@ROOT@("preview","claim",1,"subscriber_member_id")),"SUB123")
 D EQ(.FAIL,"[T982][patient member]",$G(@ROOT@("preview","claim",1,"patient_member_id")),"PAT123")
 D EQ(.FAIL,"[T982][subscriber name]",$G(@ROOT@("preview","claim",1,"subscriber_name")),"SUBSCRIBER, SAM")
 D EQ(.FAIL,"[T982][patient name]",$G(@ROOT@("preview","claim",1,"patient_name")),"PATIENT, JILL")
 K @ROOT Q
 ;
T983(FAIL) ; optional publish mirrors artifact paths into efuzy job global
 N ROOT,PATH,BASE,OPT,RES,JOBID
 S ROOT=$NA(^TMP($J,"EFUX12JOBT",983))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP001"))
 S BASE=$$TMPBASE("983")
 S JOBID=98301
 K ^MIO("EFUZY","job",JOBID)
 S OPT("jobid")=JOBID
 D RUN837^EFUX12JOB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T983][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T983][pub status]",$G(^MIO("EFUZY","job",JOBID,"status")),"completed")
 D EQ(.FAIL,"[T983][pub claims]",+$G(^MIO("EFUZY","job",JOBID,"stats","claims")),1)
 D EQ(.FAIL,"[T983][pub input path]",$G(^MIO("EFUZY","job",JOBID,"inputPath")),PATH)
 D EQ(.FAIL,"[T983][pub canonical claims]",$G(^MIO("EFUZY","job",JOBID,"artifact","canonical_claims","path"))'="",1)
 D EQ(.FAIL,"[T983][pub rebuilt]",$G(^MIO("EFUZY","job",JOBID,"artifact","rebuilt_x12","path"))'="",1)
 K ^MIO("EFUZY","job",JOBID)
 K @ROOT Q
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
 Q "/tmp/efux12jobt-"_$J_"-"_$TR($G(TAG)," /","__")_"-"_$R(999999)
 ;
