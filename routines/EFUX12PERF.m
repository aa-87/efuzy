EFUX12PERF ; efuzy 837 performance / regression harness
 ;
 ; Public:
 ;   START
 ;   RUN(BASE,ROOT,.OPT,.RES)
 ;   SMOKE(ROOT,.OPT,.RES)
 ;   EXTERNAL(BASE,ROOT,.OPT,.RES)
 ;   REPORT(ROOT)
 ;
 ; Notes:
 ;   - additive harness for parser / validator / canonical export / writer / round-trip timing
 ;   - deterministic and quiet unless START/REPORT are used explicitly
 ;   - defaults to internal golden fixtures; external curated examples are optional
 ;   - stores detailed run data under ROOT
 ;
 Q
 ;
START ; default benchmark run with auto-detected example base
 N BASE,ROOT,OPT,RES
 S BASE=$$AUTBASE^EFUX12T()
 S ROOT=$NA(^MIO("EFU","PERF","last"))
 S OPT("include_external")=1
 D RUN(BASE,ROOT,.OPT,.RES)
 D REPORT(ROOT)
 Q
 ;
RUN(BASE,ROOT,OPT,RES) ; run internal smoke plus optional curated external set
 N CASES,RBASE
 I $G(ROOT)="" S ROOT=$NA(^MIO("EFU","PERF","last"))
 D BUILDSM(.CASES)
 S RBASE=$$RESBASE^EFUX12T($G(BASE))
 I RBASE="" S RBASE=$$AUTBASE^EFUX12T()
 I +$G(OPT("include_external")),RBASE'="" D BUILDEXT(RBASE,.CASES,.OPT)
 I '$D(OPT("lenient")) S OPT("lenient")=1
 I '$D(OPT("accept_bad_envelope")) S OPT("accept_bad_envelope")=1
 D EXEC(.CASES,ROOT,.OPT,.RES)
 Q
 ;
SMOKE(ROOT,OPT,RES) ; internal-only smoke benchmark
 N CASES
 I $G(ROOT)="" S ROOT=$NA(^TMP($J,"EFUX12PERF","SMOKE"))
 D BUILDSM(.CASES)
 I '$D(OPT("lenient")) S OPT("lenient")=1
 I '$D(OPT("accept_bad_envelope")) S OPT("accept_bad_envelope")=1
 D EXEC(.CASES,ROOT,.OPT,.RES)
 Q
 ;
EXTERNAL(BASE,ROOT,OPT,RES) ; curated external-file benchmark only
 N CASES,RBASE
 K RES
 I $G(ROOT)="" S ROOT=$NA(^TMP($J,"EFUX12PERF","EXT"))
 S RBASE=$$RESBASE^EFUX12T($G(BASE))
 I RBASE="" S RBASE=$$AUTBASE^EFUX12T()
 I RBASE="" S RES("ok")=1,RES("skipped")=1,RES("reason")="example_base_not_found" Q
 D BUILDEXT(RBASE,.CASES,.OPT)
 I '$D(CASES) S RES("ok")=1,RES("skipped")=1,RES("reason")="no_external_cases" Q
 I '$D(OPT("lenient")) S OPT("lenient")=1
 I '$D(OPT("accept_bad_envelope")) S OPT("accept_bad_envelope")=1
 D EXEC(.CASES,ROOT,.OPT,.RES)
 Q
 ;
BUILDSM(CASES) ; internal valid golden-fixture workload
 N IDS,ID,META,N,DATA,PATH
 K CASES
 D IDS^EFU837GOLD(.IDS)
 S ID="",N=0
 F  S ID=$O(IDS(ID)) Q:ID=""  D
 . D META^EFU837GOLD(ID,.META)
 . I '+$G(META("valid")) Q
 . S DATA=$$DATA^EFU837GOLD(ID)
 . I DATA="" Q
 . S PATH=$$WRDATA(DATA,"gold-"_ID)
 . I PATH="" Q
 . S N=N+1
 . S CASES(N,"label")="[gold]["_ID_"]"
 . S CASES(N,"id")=ID
 . S CASES(N,"path")=PATH
 . S CASES(N,"kind")=$G(META("kind"))
 . S CASES(N,"guide")=$G(META("guide"))
 . S CASES(N,"exp_claims")=+$G(META("claims"))
 . S CASES(N,"exp_lines")=+$G(META("lines"))
 . S CASES(N,"parse")=1
 . S CASES(N,"validate")=1
 . S CASES(N,"export")=1
 . S CASES(N,"load")=1
 . S CASES(N,"write")=1
 . S CASES(N,"roundtrip")=+$G(META("roundtrip"))
 Q
 ;
BUILDEXT(BASE,CASES,OPT) ; curated external-file workload
 N N,PATH
 S N=+$O(CASES(""),-1)
 ; Example 1 curated 837 set
 D ADDEXT(.CASES,.N,"[ex1][837P-all-fields]",$$EX1SRCF^EFUX12T(BASE,"837P-all-fields.dat"),"837P",1,0,1,0)
 D ADDEXT(.CASES,.N,"[ex1][837I-all-fields]",$$EX1SRCF^EFUX12T(BASE,"837I-all-fields.dat"),"837I",1,0,1,0)
 D ADDEXT(.CASES,.N,"[ex1][837D-all-fields]",$$EX1SRCF^EFUX12T(BASE,"837D-all-fields.dat"),"837D",1,0,1,0)
 D ADDEXT(.CASES,.N,"[ex1][multi-tran]",$$EX1SRCF^EFUX12T(BASE,"multi-tran.dat"),"837P",1,0,1,0)
 D ADDEXT(.CASES,.N,"[ex1][ambulance]",$$EX1SRCF^EFUX12T(BASE,"ambulance.dat"),"837P",1,0,1,0)
 D ADDEXT(.CASES,.N,"[ex1][anesthesia]",$$EX1SRCF^EFUX12T(BASE,"anesthesia.dat"),"837P",1,0,1,0)
 ; Example 2 one per family when present
 D ADDEXT(.CASES,.N,"[ex2][X222 ambulance]",$$EX2SRCF^EFUX12T(BASE,"005010X222 Health Care Claim Professional","X222-ambulance.edi"),"837P",1,0,1,0)
 D ADDEXT(.CASES,.N,"[ex2][X223 claim]",$$EX2SRCF^EFUX12T(BASE,"005010X223 Health Care Claim Institutional","X223-837-institutional-claim.edi"),"837I",1,0,1,0)
 D ADDEXT(.CASES,.N,"[ex2][X224 sales tax]",$$EX2SRCF^EFUX12T(BASE,"005010X224 Health Care Claim Dental","X224-sales-tax.edi"),"837D",1,0,1,0)
 Q
 ;
ADDEXT(CASES,N,LABEL,PATH,KIND,PARSE,VALIDATE,EXPORT,ROUNDTRIP) ; append one external case when present
 I $G(PATH)="" Q
 S N=N+1
 S CASES(N,"label")=$G(LABEL)
 S CASES(N,"path")=$G(PATH)
 S CASES(N,"kind")=$G(KIND)
 S CASES(N,"parse")=+$G(PARSE)
 S CASES(N,"validate")=+$G(VALIDATE)
 S CASES(N,"export")=+$G(EXPORT)
 S CASES(N,"load")=+$G(EXPORT)
 S CASES(N,"write")=0
 S CASES(N,"roundtrip")=+$G(ROUNDTRIP)
 Q
 ;
EXEC(CASES,ROOT,OPT,RES) ; execute built case list
 N I,R0,R1
 K @ROOT,RES
 S R0=$H
 S @ROOT@("meta","engine")="EFUX12PERF"
 S @ROOT@("meta","version")="1"
 S @ROOT@("meta","startedH")=R0
 S I=0
 F  S I=$O(CASES(I)) Q:'I  D RUNONE(.CASES,I,ROOT,.OPT)
 S R1=$H
 S @ROOT@("meta","endedH")=R1
 S @ROOT@("summary","elapsed_sec")=$$HDIFF(R0,R1)
 D SUMRES(ROOT,.RES)
 Q
 ;
RUNONE(CASES,IDX,ROOT,OPT) ; execute one case
 N CROOT,PATH,LABEL,SROOT,LROOT,RROOT,BASE
 N POK,VOK,EOK,LOK,WOK,ROK,CASEOK,GFAIL
 S CROOT=$NA(@ROOT@("case",IDX))
 K @CROOT
 S PATH=$G(CASES(IDX,"path"))
 S LABEL=$G(CASES(IDX,"label"))
 S @CROOT@("label")=LABEL
 S @CROOT@("path")=PATH
 S @CROOT@("kind")=$G(CASES(IDX,"kind"))
 S @CROOT@("bytes")=$$FILEBYTES(PATH)
 S @CROOT@("expect","claims")=+$G(CASES(IDX,"exp_claims"))
 S @CROOT@("expect","lines")=+$G(CASES(IDX,"exp_lines"))
 S @CROOT@("startedH")=$H
 S SROOT=$NA(@CROOT@("wrk","src"))
 S LROOT=$NA(@CROOT@("wrk","canon"))
 S RROOT=$NA(@CROOT@("wrk","roundtrip"))
 S BASE=$$TMPBASE("perf-"_IDX)
 S (POK,VOK,EOK,LOK,WOK,ROK)=0,GFAIL=0
 ; parse
 I +$G(CASES(IDX,"parse")) D DOPARSE(PATH,SROOT,CROOT,.OPT,.POK,.GFAIL)
 ; validate
 I +$G(CASES(IDX,"validate")),POK D DOVAL(SROOT,CROOT,.OPT,.VOK,.GFAIL)
 ; export
 I +$G(CASES(IDX,"export")),POK D DOEXP(SROOT,BASE,CROOT,.OPT,.EOK,.GFAIL)
 ; load
 I +$G(CASES(IDX,"load")),+$G(@CROOT@("step","export","ok")) D DOLOAD(BASE,LROOT,CROOT,.OPT,.LOK,.GFAIL)
 ; write
 I +$G(CASES(IDX,"write")),+$G(@CROOT@("step","load","ok")) D DOWRITE(LROOT,BASE_"-writer.edi",CROOT,.OPT,.WOK,.GFAIL)
 ; round trip
 I +$G(CASES(IDX,"roundtrip")) D DORT(PATH,BASE_"-rt",RROOT,CROOT,.OPT,.ROK,.GFAIL)
 S CASEOK=1
 I +$G(CASES(IDX,"parse")),'POK S CASEOK=0
 I +$G(CASES(IDX,"validate")),'VOK S CASEOK=0
 I +$G(CASES(IDX,"export")),'EOK S CASEOK=0
 I +$G(CASES(IDX,"load")),'LOK S CASEOK=0
 I +$G(CASES(IDX,"write")),'WOK S CASEOK=0
 I +$G(CASES(IDX,"roundtrip")),'ROK S CASEOK=0
 I GFAIL S CASEOK=0
 S @CROOT@("ok")=CASEOK
 S @CROOT@("endedH")=$H
 S @CROOT@("elapsed_sec")=$$HDIFF($G(@CROOT@("startedH")),$G(@CROOT@("endedH")))
 D CASESUM(ROOT,IDX)
 Q
 ;
DOPARSE(PATH,SROOT,CROOT,OPT,OK,GFAIL) ; parse one case
 N T0,T1,RES
 S T0=$H
 D PARSE^EFU837P(PATH,SROOT,.OPT,.RES)
 S T1=$H
 M @CROOT@("step","parse","res")=RES
 S @CROOT@("step","parse","elapsed_sec")=$$HDIFF(T0,T1)
 S @CROOT@("step","parse","ok")=+$G(RES("ok"))
 S @CROOT@("stats","transactions")=+$G(@SROOT@("stats","transactions"))
 S @CROOT@("stats","claims")=+$G(@SROOT@("stats","claims"))
 S @CROOT@("stats","lines")=+$G(@SROOT@("stats","lines"))
 S @CROOT@("stats","errors")=+$G(@SROOT@("stats","error"))
 S @CROOT@("stats","warnings")=+$G(@SROOT@("stats","warning"))
 S OK=+$G(RES("ok"))
 D GATE(CROOT,"parse",$G(@CROOT@("step","parse","elapsed_sec")),.OPT,.GFAIL)
 Q
 ;
DOVAL(SROOT,CROOT,OPT,OK,GFAIL) ; validate one parsed case
 N T0,T1,RES
 S T0=$H
 D RUN^EFU837VR(SROOT,.OPT,.RES)
 S T1=$H
 M @CROOT@("step","validate","res")=RES
 S @CROOT@("step","validate","elapsed_sec")=$$HDIFF(T0,T1)
 S @CROOT@("step","validate","ok")=+$G(RES("ok"))
 S OK=+$G(RES("ok"))
 D GATE(CROOT,"validate",$G(@CROOT@("step","validate","elapsed_sec")),.OPT,.GFAIL)
 Q
 ;
DOEXP(SROOT,BASE,CROOT,OPT,OK,GFAIL) ; export canonical package
 N T0,T1,RES
 S T0=$H
 D EXPORT^EFU837CAN(SROOT,BASE,.RES)
 S T1=$H
 M @CROOT@("step","export","res")=RES
 S @CROOT@("step","export","elapsed_sec")=$$HDIFF(T0,T1)
 S @CROOT@("step","export","ok")=+$G(RES("ok"))
 S @CROOT@("artifact","canon_base")=BASE
 S OK=+$G(RES("ok"))
 D GATE(CROOT,"export",$G(@CROOT@("step","export","elapsed_sec")),.OPT,.GFAIL)
 Q
 ;
DOLOAD(BASE,LROOT,CROOT,OPT,OK,GFAIL) ; load canonical package
 N T0,T1,RES
 S T0=$H
 D LOAD^EFU837CAN(BASE,LROOT,.RES)
 S T1=$H
 M @CROOT@("step","load","res")=RES
 S @CROOT@("step","load","elapsed_sec")=$$HDIFF(T0,T1)
 S @CROOT@("step","load","ok")=+$G(RES("ok"))
 S OK=+$G(RES("ok"))
 D GATE(CROOT,"load",$G(@CROOT@("step","load","elapsed_sec")),.OPT,.GFAIL)
 Q
 ;
DOWRITE(LROOT,PATH,CROOT,OPT,OK,GFAIL) ; write deterministic outbound file
 N T0,T1,RES,WOPT
 M WOPT=OPT
 I '$D(WOPT("writer_strict")),'$D(WOPT("writer_lenient")) S WOPT("writer_strict")=1
 S T0=$H
 D WRITE^EFU837W(LROOT,PATH,.WOPT,.RES)
 S T1=$H
 M @CROOT@("step","write","res")=RES
 S @CROOT@("step","write","elapsed_sec")=$$HDIFF(T0,T1)
 S @CROOT@("step","write","ok")=+$G(RES("ok"))
 S @CROOT@("artifact","writer_path")=PATH
 S OK=+$G(RES("ok"))
 D GATE(CROOT,"write",$G(@CROOT@("step","write","elapsed_sec")),.OPT,.GFAIL)
 Q
 ;
DORT(PATH,BASE,RROOT,CROOT,OPT,OK,GFAIL) ; execute full round trip
 N T0,T1,RES
 S T0=$H
 D RUN^EFU837RT(PATH,BASE,RROOT,.OPT,.RES)
 S T1=$H
 M @CROOT@("step","roundtrip","res")=RES
 S @CROOT@("step","roundtrip","elapsed_sec")=$$HDIFF(T0,T1)
 S @CROOT@("step","roundtrip","ok")=+$G(RES("ok"))
 S OK=+$G(RES("ok"))
 D GATE(CROOT,"roundtrip",$G(@CROOT@("step","roundtrip","elapsed_sec")),.OPT,.GFAIL)
 Q
 ;
GATE(CROOT,STEP,ELAPSED,OPT,GFAIL) ; optional elapsed-time regression gate
 N MAX
 S MAX=$G(OPT("gate",STEP,"max_sec"))
 I MAX="" Q
 S @CROOT@("gate",STEP,"max_sec")=MAX
 S @CROOT@("gate",STEP,"elapsed_sec")=+$G(ELAPSED)
 I +$G(ELAPSED)'>+MAX S @CROOT@("gate",STEP,"ok")=1 Q
 S @CROOT@("gate",STEP,"ok")=0
 S GFAIL=1
 Q
 ;
CASESUM(ROOT,IDX) ; roll one case into summary
 N CROOT,OK,STEP
 S CROOT=$NA(@ROOT@("case",IDX))
 S @ROOT@("summary","cases")=+$G(@ROOT@("summary","cases"))+1
 S @ROOT@("summary","bytes_total")=+$G(@ROOT@("summary","bytes_total"))+$G(@CROOT@("bytes"))
 S OK=+$G(@CROOT@("ok"))
 I OK S @ROOT@("summary","ok_cases")=+$G(@ROOT@("summary","ok_cases"))+1
 E  S @ROOT@("summary","failed_cases")=+$G(@ROOT@("summary","failed_cases"))+1
 S STEP=""
 F  S STEP=$O(@CROOT@("step",STEP)) Q:STEP=""  D
 . S @ROOT@("summary","step",STEP,"ran")=+$G(@ROOT@("summary","step",STEP,"ran"))+1
 . S @ROOT@("summary","step",STEP,"elapsed_sec")=+$G(@ROOT@("summary","step",STEP,"elapsed_sec"))+$G(@CROOT@("step",STEP,"elapsed_sec"))
 . I +$G(@CROOT@("step",STEP,"ok")) S @ROOT@("summary","step",STEP,"ok")=+$G(@ROOT@("summary","step",STEP,"ok"))+1
 . E  S @ROOT@("summary","step",STEP,"fail")=+$G(@ROOT@("summary","step",STEP,"fail"))+1
 . I $D(@CROOT@("gate",STEP)),'+$G(@CROOT@("gate",STEP,"ok")) S @ROOT@("summary","gates_failed")=+$G(@ROOT@("summary","gates_failed"))+1
 Q
 ;
SUMRES(ROOT,RES) ; summarize run into RES
 N STEP
 K RES
 S RES("ok")=$S((+$G(@ROOT@("summary","failed_cases"))>0)!(+$G(@ROOT@("summary","gates_failed"))>0):0,1:1)
 S RES("root")=ROOT
 S RES("summary","cases")=+$G(@ROOT@("summary","cases"))
 S RES("summary","ok_cases")=+$G(@ROOT@("summary","ok_cases"))
 S RES("summary","failed_cases")=+$G(@ROOT@("summary","failed_cases"))
 S RES("summary","gates_failed")=+$G(@ROOT@("summary","gates_failed"))
 S RES("summary","bytes_total")=+$G(@ROOT@("summary","bytes_total"))
 S RES("summary","elapsed_sec")=+$G(@ROOT@("summary","elapsed_sec"))
 S STEP=""
 F  S STEP=$O(@ROOT@("summary","step",STEP)) Q:STEP=""  D
 . S RES("step",STEP,"ran")=+$G(@ROOT@("summary","step",STEP,"ran"))
 . S RES("step",STEP,"ok")=+$G(@ROOT@("summary","step",STEP,"ok"))
 . S RES("step",STEP,"fail")=+$G(@ROOT@("summary","step",STEP,"fail"))
 . S RES("step",STEP,"elapsed_sec")=+$G(@ROOT@("summary","step",STEP,"elapsed_sec"))
 Q
 ;
REPORT(ROOT) ; print concise run summary
 N STEP
 I $G(ROOT)="" Q
 W !,"EFUX12PERF: cases=",+$G(@ROOT@("summary","cases"))
 W " ok=",+$G(@ROOT@("summary","ok_cases"))
 W " failed=",+$G(@ROOT@("summary","failed_cases"))
 W " gates=",+$G(@ROOT@("summary","gates_failed"))
 W " elapsed_sec=",+$G(@ROOT@("summary","elapsed_sec"))
 S STEP=""
 F  S STEP=$O(@ROOT@("summary","step",STEP)) Q:STEP=""  D
 . W !,"  ",STEP,": ran=",+$G(@ROOT@("summary","step",STEP,"ran"))
 . W " ok=",+$G(@ROOT@("summary","step",STEP,"ok"))
 . W " fail=",+$G(@ROOT@("summary","step",STEP,"fail"))
 . W " elapsed_sec=",+$G(@ROOT@("summary","step",STEP,"elapsed_sec"))
 Q
 ;
FILEBYTES(PATH) ; streaming file size helper
 N DEV,OLDIO,CH,DONE,SZ
 S DEV=$G(PATH),OLDIO=$IO,SZ=0,DONE=0
 I DEV="" Q 0
 O DEV:(READONLY:STREAM):0 E  Q 0
 U DEV
 F  Q:DONE  D
 . S CH=""
 . R CH#4096:1
 . I '$T D  Q
 . . I $ZEOF S DONE=1 Q
 . . S DONE=1
 . S SZ=SZ+$L(CH)
 . I $ZEOF S DONE=1
 C DEV U OLDIO
 Q SZ
 ;
WRDATA(DATA,TAG) ; write temporary input data and return path
 N PATH,DEV,OLDIO
 S PATH=$$TMPBASE($G(TAG))_".edi"
 S DEV=PATH,OLDIO=$IO
 O DEV:(NEWVERSION:STREAM:WRITEONLY):1
 I '$T Q ""
 U DEV W $G(DATA)
 C DEV U OLDIO
 Q PATH
 ;
TMPBASE(TAG) ; temporary work stem
 Q "tmp/efux12perf-"_$J_"-"_$TR($G(TAG)," /","__")_"-"_$R(999999)
 ;
HDIFF(A,B) ; elapsed seconds from two $H values
 N AD,AT,BD,BT
 S AD=+$P($G(A),",",1),AT=+$P($G(A),",",2)
 S BD=+$P($G(B),",",1),BT=+$P($G(B),",",2)
 Q ((BD-AD)*86400)+(BT-AT)
