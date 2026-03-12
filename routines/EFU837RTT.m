EFU837RTT ; efuzy 837 round-trip tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFU837RTT"
 Q
 ;
ALL(FAIL) ; full suite
 D T700(.FAIL)
 D T710(.FAIL)
 D T711(.FAIL)
 D T712(.FAIL)
 D T720(.FAIL)
 D T730(.FAIL)
 D T731(.FAIL)
 D T732(.FAIL)
 D T733(.FAIL)
 Q
 ;
T700(FAIL) ; canonical export/load from valid 837P sample
 N PATH,ROOT,OPT,PRES,ERES,LRES,BASE
 S PATH=$$WRFILE($$SAMPLEP())
 S ROOT=$NA(^TMP($J,"EFU837RTT",700))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.PRES)
 D EQ(.FAIL,"[T700][parse ok]",+$G(PRES("ok")),1)
 S BASE="efu837rtt_700_"_$J
 D EXPORT^EFU837CAN(ROOT,BASE,.ERES)
 D EQ(.FAIL,"[T700][export ok]",+$G(ERES("ok")),1)
 D LOAD^EFU837CAN(BASE,ROOT,.LRES)
 D EQ(.FAIL,"[T700][load ok]",+$G(LRES("ok")),1)
 D EQ(.FAIL,"[T700][claims]",+$G(LRES("claims")),1)
 D EQ(.FAIL,"[T700][lines]",+$G(LRES("lines")),1)
 K @ROOT Q
 ;
T710(FAIL) ; round-trip 837P
 D DOTRT(.FAIL,710,$$SAMPLEP(),1,1,"837P","SV1") Q
 ;
T711(FAIL) ; round-trip 837I
 D DOTRT(.FAIL,711,$$SAMPLEI(),1,1,"837I","SV2") Q
 ;
T712(FAIL) ; round-trip 837D
 D DOTRT(.FAIL,712,$$SAMPLED(),1,1,"837D","SV3") Q
 ;
T720(FAIL) ; deterministic writer output for same canonical package
 N PATH,ROOT,OPT,PRES,ERES,LRES,BASE,OUT1,OUT2,A,B
 S PATH=$$WRFILE($$SAMPLEI())
 S ROOT=$NA(^TMP($J,"EFU837RTT",720))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.PRES)
 D EQ(.FAIL,"[T720][parse ok]",+$G(PRES("ok")),1)
 S BASE="efu837rtt_720_"_$J
 D EXPORT^EFU837CAN(ROOT,BASE,.ERES)
 D LOAD^EFU837CAN(BASE,ROOT,.LRES)
 S OUT1=BASE_"_a.edi",OUT2=BASE_"_b.edi"
 D WRITE^EFU837W(ROOT,OUT1,.OPT,.ERES)
 D WRITE^EFU837W(ROOT,OUT2,.OPT,.LRES)
 S A=$$READALL(OUT1),B=$$READALL(OUT2)
 D EQ(.FAIL,"[T720][same bytes]",A=B,1)
 K @ROOT Q
 ;
T730(FAIL) ; compare modes all succeed on identical structures
 N AROOT,BROOT,OPT,RES
 D PARSEFIX("GP040",$NA(^TMP($J,"EFU837RTT",730,"A")),.OPT,.RES)
 D PARSEFIX("GP040",$NA(^TMP($J,"EFU837RTT",730,"B")),.OPT,.RES)
 S AROOT=$NA(^TMP($J,"EFU837RTT",730,"A"))
 S BROOT=$NA(^TMP($J,"EFU837RTT",730,"B"))
 D COMPAREM^EFU837RT(AROOT,BROOT,"core",.OPT,.RES)
 D EQ(.FAIL,"[T730][core ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T730][core mode]",$G(RES("compare_mode")),"core")
 D EQ(.FAIL,"[T730][core mismatches]",+$G(RES("summary","mismatch_count")),0)
 D COMPAREM^EFU837RT(AROOT,BROOT,"export_safe",.OPT,.RES)
 D EQ(.FAIL,"[T730][safe ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T730][safe mode]",$G(RES("compare_mode")),"export_safe")
 D COMPAREM^EFU837RT(AROOT,BROOT,"strict",.OPT,.RES)
 D EQ(.FAIL,"[T730][strict ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T730][strict mode]",$G(RES("compare_mode")),"strict_structural")
 K @AROOT,@BROOT Q
 ;
T731(FAIL) ; strict-only fields fail only in strict_structural mode
 N AROOT,BROOT,OPT,RES
 D PARSEFIX("GP020",$NA(^TMP($J,"EFU837RTT",731,"A")),.OPT,.RES)
 D PARSEFIX("GP020",$NA(^TMP($J,"EFU837RTT",731,"B")),.OPT,.RES)
 S AROOT=$NA(^TMP($J,"EFU837RTT",731,"A"))
 S BROOT=$NA(^TMP($J,"EFU837RTT",731,"B"))
 D ENSURE^EFU837RT(AROOT,.RES)
 D ENSURE^EFU837RT(BROOT,.RES)
 S @BROOT@("norm","claim",1,"patient_name")="BROKEN, NAME"
 D COMPAREM^EFU837RT(AROOT,BROOT,"core",.OPT,.RES)
 D EQ(.FAIL,"[T731][core ok]",+$G(RES("ok")),1)
 D COMPAREM^EFU837RT(AROOT,BROOT,"export_safe",.OPT,.RES)
 D EQ(.FAIL,"[T731][safe ok]",+$G(RES("ok")),1)
 D COMPAREM^EFU837RT(AROOT,BROOT,"strict_structural",.OPT,.RES)
 D EQ(.FAIL,"[T731][strict fails]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T731][strict field]",$D(RES("mismatch","claim","GP020C1","patient_name"))>0,1)
 K @AROOT,@BROOT Q
 ;
T732(FAIL) ; export-safe fields fail in export_safe and strict, not core
 N AROOT,BROOT,OPT,RES
 D PARSEFIX("GP020",$NA(^TMP($J,"EFU837RTT",732,"A")),.OPT,.RES)
 D PARSEFIX("GP020",$NA(^TMP($J,"EFU837RTT",732,"B")),.OPT,.RES)
 S AROOT=$NA(^TMP($J,"EFU837RTT",732,"A"))
 S BROOT=$NA(^TMP($J,"EFU837RTT",732,"B"))
 D ENSURE^EFU837RT(AROOT,.RES)
 D ENSURE^EFU837RT(BROOT,.RES)
 S @BROOT@("norm","claim",1,"patient_member_id")="WRONGID"
 D COMPAREM^EFU837RT(AROOT,BROOT,"core",.OPT,.RES)
 D EQ(.FAIL,"[T732][core ok]",+$G(RES("ok")),1)
 D COMPAREM^EFU837RT(AROOT,BROOT,"export_safe",.OPT,.RES)
 D EQ(.FAIL,"[T732][safe fails]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T732][safe field]",$D(RES("mismatch","claim","GP020C1","patient_member_id"))>0,1)
 D COMPAREM^EFU837RT(AROOT,BROOT,"strict",.OPT,.RES)
 D EQ(.FAIL,"[T732][strict fails]",+$G(RES("ok")),0)
 K @AROOT,@BROOT Q
 ;
T733(FAIL) ; extra keys on right side are reported cleanly
 N AROOT,BROOT,OPT,RES
 D PARSEFIX("GP001",$NA(^TMP($J,"EFU837RTT",733,"A")),.OPT,.RES)
 D PARSEFIX("GP001",$NA(^TMP($J,"EFU837RTT",733,"B")),.OPT,.RES)
 S AROOT=$NA(^TMP($J,"EFU837RTT",733,"A"))
 S BROOT=$NA(^TMP($J,"EFU837RTT",733,"B"))
 D ENSURE^EFU837RT(AROOT,.RES)
 D ENSURE^EFU837RT(BROOT,.RES)
 S @BROOT@("norm","claim",99,"claim_id")="EXTRA-C1"
 S @BROOT@("norm","claim",99,"tx_kind")="837P"
 S @BROOT@("norm","claim",99,"guide")="005010X222A1"
 S @BROOT@("norm","claim",99,"total_charge")="1"
 S @BROOT@("norm","claim",99,"from_date")="20260311"
 S @BROOT@("norm","claim",99,"thru_date")="20260311"
 S @BROOT@("norm","claim",99,"line_count")=0
 D COMPAREM^EFU837RT(AROOT,BROOT,"export_safe",.OPT,.RES)
 D EQ(.FAIL,"[T733][fails]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T733][claim extra]",+$G(RES("missing","claim_extra","EXTRA-C1")),1)
 K @AROOT,@BROOT Q
 ;
DOTRT(FAIL,N,DATA,EXPCLM,EXPLIN,EXPTX,EXPSV) ; round-trip helper
 N PATH,ROOT,OPT,RES,BASE,RROOT,CID,LN
 S PATH=$$WRFILE($G(DATA))
 S ROOT=$NA(^TMP($J,"EFU837RTT",+N))
 S BASE="efu837rtt_"_+N_"_"_$J
 D RUN^EFU837RT(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T"_N_"][rt ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T"_N_"][src claims]",+$G(RES("parse_src","claims")),+EXPCLM)
 D EQ(.FAIL,"[T"_N_"][rebuilt claims]",+$G(RES("claims")),+EXPCLM)
 D EQ(.FAIL,"[T"_N_"][mode]",$G(RES("compare_mode")),"export_safe")
 S RROOT=$NA(@ROOT@("rebuilt"))
 S CID=$O(@RROOT@("norm","claim",0))
 S LN=$O(@RROOT@("norm","line",CID,0))
 D EQ(.FAIL,"[T"_N_"][tx kind]",$G(@RROOT@("norm","claim",CID,"tx_kind")),$G(EXPTX))
 D EQ(.FAIL,"[T"_N_"][svc kind]",$G(@RROOT@("norm","line",CID,LN,"service_kind")),$G(EXPSV))
 Q
 ;
PARSEFIX(ID,ROOT,OPT,RES) ; parse embedded golden fixture into ROOT
 N PATH
 K @ROOT
 S PATH=$$WRFILE($$DATA^EFU837GOLD($G(ID)))
 D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
WRFILE(DATA) ; write DATA to temp file and return path
 N PATH,OLDIO
 S PATH="efu837rtt_"_$J_".tmp"
 S OLDIO=$IO
 O PATH:(NEWVERSION:STREAM:WRITEONLY):0
 I '$T Q PATH
 U PATH W DATA
 C PATH U OLDIO
 Q PATH
 ;
READALL(PATH) ; test-only full file read
 N DEV,OLDIO,TXT,X,DONE
 S DEV=PATH,OLDIO=$IO,TXT="",DONE=0
 O DEV:(READONLY:STREAM):1
 I '$T Q ""
 U DEV
 F  Q:DONE  D
 . S X=""
 . R X#4096:1
 . I '$T D  Q
 . . I $ZEOF S DONE=1 Q
 . . S DONE=1
 . I X'="" S TXT=TXT_X
 . I $ZEOF S DONE=1
 C DEV U OLDIO
 Q TXT
 ;
SAMPLEP() Q $$SAMPLEP^EFU837SPECT()
SAMPLEI() Q $$SAMPLEI^EFU837SPECT()
SAMPLED() Q $$SAMPLED^EFU837SPECT()
 ;
