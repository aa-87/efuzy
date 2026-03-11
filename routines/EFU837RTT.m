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
DOTRT(FAIL,N,DATA,EXPCLM,EXPLIN,EXPTX,EXPSV) ; round-trip helper
 N PATH,ROOT,OPT,RES,BASE,RROOT,CID,LN
 S PATH=$$WRFILE($G(DATA))
 S ROOT=$NA(^TMP($J,"EFU837RTT",+N))
 S BASE="efu837rtt_"_+N_"_"_$J
 D RUN^EFU837RT(PATH,BASE,ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T"_N_"][rt ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T"_N_"][src claims]",+$G(RES("parse_src","claims")),+EXPCLM)
 D EQ(.FAIL,"[T"_N_"][rebuilt claims]",+$G(RES("claims")),+EXPCLM)
 S RROOT=$NA(@ROOT@("rebuilt"))
 S CID=$O(@RROOT@("norm","claim",0))
 S LN=$O(@RROOT@("norm","line",CID,0))
 D EQ(.FAIL,"[T"_N_"][tx kind]",$G(@RROOT@("norm","claim",CID,"tx_kind")),$G(EXPTX))
 D EQ(.FAIL,"[T"_N_"][svc kind]",$G(@RROOT@("norm","line",CID,LN,"service_kind")),$G(EXPSV))
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
