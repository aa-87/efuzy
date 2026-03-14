EFUX12JOBPT ; x12 job packaging hardening tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUX12JOBPT"
 Q
 ;
ALL(FAIL)
 D T300(.FAIL)
 D T310(.FAIL)
 D T320(.FAIL)
 D T330(.FAIL)
 Q
 ;
T300(FAIL) ; canonical and report artifacts contain line feeds
 N ROOT,PATH,BASE,OPT,RES,TXT
 S ROOT=$NA(^TMP($J,"EFUX12JOBPT",300))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP001"))
 S BASE=$$TMPBASE("300")
 D RUN837^EFUX12JOB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T300][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T300][claims read]",$$READFILE^EFUZYTESTU($G(@ROOT@("artifact","canonical_claims","path")),.TXT),1)
 D EQ(.FAIL,"[T300][claims lf]",$$HASLF($G(@ROOT@("artifact","canonical_claims","path"))),1)
 D EQ(.FAIL,"[T300][lines read]",$$READFILE^EFUZYTESTU($G(@ROOT@("artifact","canonical_lines","path")),.TXT),1)
 D EQ(.FAIL,"[T300][lines lf]",$$HASLF($G(@ROOT@("artifact","canonical_lines","path"))),1)
 D EQ(.FAIL,"[T300][summary read]",$$READFILE^EFUZYTESTU($G(@ROOT@("artifact","parse_summary","path")),.TXT),1)
 D EQ(.FAIL,"[T300][summary lf]",$$HASLF($G(@ROOT@("artifact","parse_summary","path"))),1)
 D EQ(.FAIL,"[T300][job read]",$$READFILE^EFUZYTESTU($G(@ROOT@("artifact","job_manifest","path")),.TXT),1)
 D EQ(.FAIL,"[T300][job lf]",$$HASLF($G(@ROOT@("artifact","job_manifest","path"))),1)
 K @ROOT Q
 ;
T310(FAIL) ; build_rebuilt off suppresses rebuilt artifact
 N ROOT,PATH,BASE,OPT,RES
 S ROOT=$NA(^TMP($J,"EFUX12JOBPT",310))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP010"))
 S BASE=$$TMPBASE("310")
 S OPT("build_rebuilt")=0
 D RUN837^EFUX12JOB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T310][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T310][rebuilt missing]",$D(@ROOT@("artifact","rebuilt_x12"))>0,0)
 D EQ(.FAIL,"[T310][meta build]",+$G(@ROOT@("meta","build_rebuilt")),0)
 K @ROOT Q
 ;
T320(FAIL) ; trace option controls trace artifact creation
 N ROOT,PATH,BASE,OPT,RES,TXT
 S ROOT=$NA(^TMP($J,"EFUX12JOBPT",320))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP020"))
 S BASE=$$TMPBASE("320")
 S OPT("trace")=1
 D RUN837^EFUX12JOB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T320][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T320][trace exists]",+$G(@ROOT@("artifact","trace_report","exists")),1)
 D EQ(.FAIL,"[T320][trace read]",$$READFILE^EFUZYTESTU($G(@ROOT@("artifact","trace_report","path")),.TXT),1)
 D EQ(.FAIL,"[T320][trace claim marker]",TXT["claim.1.",1)
 K @ROOT
 S ROOT=$NA(^TMP($J,"EFUX12JOBPT",321))
 K OPT S OPT("trace")=0
 S BASE=$$TMPBASE("321")
 D RUN837^EFUX12JOB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T320][trace off ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T320][trace off missing]",$D(@ROOT@("artifact","trace_report"))>0,0)
 K @ROOT Q
 ;
T330(FAIL) ; published job mirrors artifact metadata and compare mode
 N ROOT,PATH,BASE,OPT,RES,JOBID
 S ROOT=$NA(^TMP($J,"EFUX12JOBPT",330))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP040"))
 S BASE=$$TMPBASE("330")
 S JOBID=33001
 K ^MIO("EFUZY","job",JOBID)
 S OPT("jobid")=JOBID
 S OPT("roundtrip")=1
 S OPT("compare_mode")="export_safe"
 D RUN837^EFUX12JOB(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T330][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T330][pub status]",$G(^MIO("EFUZY","job",JOBID,"status")),"completed")
 D EQ(.FAIL,"[T330][pub claims]",+$G(^MIO("EFUZY","job",JOBID,"stats","claims"))>0,1)
 D EQ(.FAIL,"[T330][pub roundtrip]",+$G(^MIO("EFUZY","job",JOBID,"stats","roundtripOk")),1)
 D EQ(.FAIL,"[T330][pub canonical name]",$G(^MIO("EFUZY","job",JOBID,"artifact","canonical_claims","name"))'="",1)
 K ^MIO("EFUZY","job",JOBID)
 K @ROOT Q
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
 Q "/tmp/efux12jobpt-"_$J_"-"_$TR($G(TAG)," /","__")_"-"_$R(999999)
 ;

HASLF(PATH)
 N C,DEV,HAS,OLDIO
 S HAS=0,DEV=$G(PATH),OLDIO=$IO
 I DEV="" Q 0
 O DEV:(READONLY:STREAM:NOWRAP):1 E  Q 0
 U DEV
 F  R *C:1 Q:$ZEOF  I +$G(C)=10 S HAS=1 Q
 C DEV U OLDIO
 Q HAS
 ;
