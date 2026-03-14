EFU837TRT ; efuzy 837 traceability and audit tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFU837TRT"
 Q
 ;
ALL(FAIL) ; full suite
 D T1000(.FAIL)
 D T1001(.FAIL)
 D T1002(.FAIL)
 D T1003(.FAIL)
 D T1004(.FAIL)
 Q
 ;
T1000(FAIL) ; distinct subscriber/patient trace rows are separated
 N ROOT,PATH,OPT,PRES,TRES
 S ROOT=$NA(^TMP($J,"EFU837TRT",1000))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP020"))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.PRES)
 D BUILD^EFU837TRACE(ROOT,.OPT,.TRES)
 D EQ(.FAIL,"[T1000][ok]",+$G(TRES("ok")),1)
 D EQ(.FAIL,"[T1000][patient member]",$G(@ROOT@("trace","claim",1,"field","patient_member_id","value")),"PAT123")
 D EQ(.FAIL,"[T1000][patient member segid]",$G(@ROOT@("trace","claim",1,"field","patient_member_id","segid")),"NM1")
 D EQ(.FAIL,"[T1000][patient member node]",$$HAS($G(@ROOT@("trace","claim",1,"field","patient_member_id","node")),"patient.1.name.id"),1)
 D EQ(.FAIL,"[T1000][subscriber member]",$G(@ROOT@("trace","claim",1,"field","subscriber_member_id","value")),"SUB123")
 D EQ(.FAIL,"[T1000][subscriber member node]",$$HAS($G(@ROOT@("trace","claim",1,"field","subscriber_member_id","node")),"sub.1.name.id"),1)
 K @ROOT Q
 ;
T1001(FAIL) ; line and diagnosis trace rows point to expected segment classes
 N ROOT,PATH,OPT,PRES,TRES
 S ROOT=$NA(^TMP($J,"EFU837TRT",1001))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP040"))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.PRES)
 D BUILD^EFU837TRACE(ROOT,.OPT,.TRES)
 D EQ(.FAIL,"[T1001][ok]",+$G(TRES("ok")),1)
 D EQ(.FAIL,"[T1001][diag codes]",$G(@ROOT@("trace","claim",1,"field","diag_codes","value")),"A123|B456")
 D EQ(.FAIL,"[T1001][diag segid]",$G(@ROOT@("trace","claim",1,"field","diag_codes","segid")),"HI")
 D EQ(.FAIL,"[T1001][proc code]",$G(@ROOT@("trace","line",1,1,"field","procedure_code","value")),"99214")
 D EQ(.FAIL,"[T1001][proc segid]",$G(@ROOT@("trace","line",1,1,"field","procedure_code","segid")),"SV1")
 D EQ(.FAIL,"[T1001][svc date segid]",$G(@ROOT@("trace","line",1,1,"field","svc_date","segid")),"DTP")
 D EQ(.FAIL,"[T1001][svc date node]",$$HAS($G(@ROOT@("trace","line",1,1,"field","svc_date","node")),"dtp.472"),1)
 K @ROOT Q
 ;
T1002(FAIL) ; reverse segment index and summary counters are populated
 N ROOT,PATH,OPT,PRES,TRES,SEG
 S ROOT=$NA(^TMP($J,"EFU837TRT",1002))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP010"))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.PRES)
 D BUILD^EFU837TRACE(ROOT,.OPT,.TRES)
 S SEG=+$G(@ROOT@("trace","claim",1,"field","claim_id","segno"))
 D EQ(.FAIL,"[T1002][ok]",+$G(TRES("ok")),1)
 D EQ(.FAIL,"[T1002][fields]",+$G(TRES("fields"))>0,1)
 D EQ(.FAIL,"[T1002][segments]",+$G(TRES("segments"))>0,1)
 D EQ(.FAIL,"[T1002][claim seg]",SEG>0,1)
 D EQ(.FAIL,"[T1002][rev idx]",$D(@ROOT@("trace","seg",SEG,"claim",1,"field","claim_id"))>0,1)
 K @ROOT Q
 ;
T1003(FAIL) ; job packaging includes trace report and detail exposes live traces
 N JROOT,WROOT,PATH,BASE,OPT,RES,DRES
 S JROOT=$NA(^TMP($J,"EFU837TRT","job",1003))
 S WROOT=$NA(^TMP($J,"EFU837TRT",1003))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP020"))
 S BASE=$$TMPBASE("1003")
 D RUN837^EFUX12JOB(PATH,BASE,JROOT,.OPT,.RES)
 D EQ(.FAIL,"[T1003][job ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T1003][trace fields]",+$G(@JROOT@("summary","trace_fields"))>0,1)
 D EQ(.FAIL,"[T1003][trace artifact]",+$G(@JROOT@("artifact","trace_report","exists")),1)
 D DETAIL^EFUX12WEB(JROOT,WROOT,.OPT,.DRES)
 D EQ(.FAIL,"[T1003][detail ok]",+$G(DRES("ok")),1)
 D EQ(.FAIL,"[T1003][trace summary]",+$G(@WROOT@("response","trace","summary","fields"))>0,1)
 D EQ(.FAIL,"[T1003][trace patient]",$G(@WROOT@("response","trace","claim",1,"field","patient_member_id","value")),"PAT123")
 K @JROOT K @WROOT Q
 ;
T1004(FAIL) ; published job detail carries trace summary stats and trace artifact metadata
 N JROOT,WROOT,PATH,BASE,OPT,RES,DRES,JOBID
 S JROOT=$NA(^TMP($J,"EFU837TRT","job",1004))
 S WROOT=$NA(^TMP($J,"EFU837TRT",1004))
 S PATH=$$WRFILE($$DATA^EFU837GOLD("GP001"))
 S BASE=$$TMPBASE("1004")
 S JOBID=100401
 K ^MIO("EFUZY","job",JOBID)
 S OPT("jobid")=JOBID
 D RUN837^EFUX12JOB(PATH,BASE,JROOT,.OPT,.RES)
 D DETAIL^EFUX12WEB(JOBID,WROOT,.OPT,.DRES)
 D EQ(.FAIL,"[T1004][detail ok]",+$G(DRES("ok")),1)
 D EQ(.FAIL,"[T1004][trace fields]",+$G(@WROOT@("response","trace","summary","fields"))>0,1)
 D EQ(.FAIL,"[T1004][trace artifact path]",$G(@WROOT@("response","artifact","trace_report","path"))'="",1)
 K ^MIO("EFUZY","job",JOBID)
 K @JROOT K @WROOT Q
 ;
HAS(X,SUB) ; contains helper
 Q $S($F($G(X),$G(SUB))>0:1,1:0)
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
 Q "tmp/efu837trt-"_$J_"-"_$TR($G(TAG)," /","__")_"-"_$R(999999)
 ;
