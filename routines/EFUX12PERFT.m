EFUX12PERFT ; efuzy performance / regression harness tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUX12PERFT"
 Q
 ;
ALL(FAIL) ; full suite
 D T950(.FAIL)
 D T951(.FAIL)
 D T952(.FAIL)
 Q
 ;
T950(FAIL) ; internal smoke harness runs cleanly
 N ROOT,OPT,RES,EXP
 S ROOT=$NA(^TMP($J,"EFUX12PERFT",950))
 D SMOKE^EFUX12PERF(ROOT,.OPT,.RES)
 S EXP=$$COUNT^EFU837GOLD()-1
 D EQ(.FAIL,"[T950][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T950][cases]",+$G(RES("summary","cases")),EXP)
 D EQ(.FAIL,"[T950][ok cases]",+$G(RES("summary","ok_cases")),EXP)
 D EQ(.FAIL,"[T950][failed cases]",+$G(RES("summary","failed_cases")),0)
 D EQ(.FAIL,"[T950][parse ok]",+$G(RES("step","parse","ok")),EXP)
 D EQ(.FAIL,"[T950][roundtrip ok]",+$G(RES("step","roundtrip","ok")),EXP)
 D EQ(.FAIL,"[T950][bytes positive]",+$G(RES("summary","bytes_total"))>0,1)
 K @ROOT Q
 ;
T951(FAIL) ; regression gate can force failure deterministically
 N ROOT,OPT,RES
 S ROOT=$NA(^TMP($J,"EFUX12PERFT",951))
 S OPT("gate","parse","max_sec")=-1
 D SMOKE^EFUX12PERF(ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T951][ok false]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T951][gates failed]",+$G(RES("summary","gates_failed"))>0,1)
 D EQ(.FAIL,"[T951][failed cases]",+$G(RES("summary","failed_cases"))>0,1)
 K @ROOT Q
 ;
T952(FAIL) ; curated external set runs and produces positive successful coverage when example base is available
 N ROOT,OPT,RES,BASE
 S ROOT=$NA(^TMP($J,"EFUX12PERFT",952))
 S BASE=$$AUTBASE^EFUX12T()
 S OPT("lenient")=1,OPT("accept_bad_envelope")=1
 D EXTERNAL^EFUX12PERF(BASE,ROOT,.OPT,.RES)
 I +$G(RES("skipped")) D  Q
 . D EQ(.FAIL,"[T952][skipped]",+$G(RES("skipped")),1)
 D EQ(.FAIL,"[T952][cases positive]",+$G(RES("summary","cases"))>0,1)
 D EQ(.FAIL,"[T952][parse ran positive]",+$G(RES("step","parse","ran"))>0,1)
 D EQ(.FAIL,"[T952][parse ok positive]",+$G(RES("step","parse","ok"))>0,1)
 D EQ(.FAIL,"[T952][export ok positive]",+$G(RES("step","export","ok"))>0,1)
 D EQ(.FAIL,"[T952][load ok positive]",+$G(RES("step","load","ok"))>0,1)
 D EQ(.FAIL,"[T952][not all failed]",+$G(RES("summary","ok_cases"))>0,1)
 K @ROOT Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
