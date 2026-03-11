EFU837GOLDT ; efuzy 837 golden fixture tests
	;
	; Public:
	;   START
	;   ALL(.FAIL)
	;
	; Notes:
	;   - quiet on success
	;   - additive internal golden-fixture coverage for parser, validator,
	;     canonical export/load, and round-trip behavior
	;   - complements EFU837T / EFUX12T instead of replacing them
	;
	D START
	Q
	;
START ; default entry
	N FAIL
	S FAIL=0
	D ALL(.FAIL)
	I 'FAIL W !,"OK - EFU837GOLDT"
	Q
	;
ALL(FAIL) ; full suite
	D T800(.FAIL)
	D T810(.FAIL)
	D T820(.FAIL)
	D T830(.FAIL)
	D T840(.FAIL)
	D T850(.FAIL)
	D T860(.FAIL)
	Q
	;
T800(FAIL) ; fixture catalog sanity
	N IDS
	D IDS^EFU837GOLD(.IDS)
	D EQ(.FAIL,"[T800][fixture count]",$$COUNT^EFU837GOLD(),8)
	D EQ(.FAIL,"[T800][has GP001]",$D(IDS("GP001"))>0,1)
	D EQ(.FAIL,"[T800][has GP020]",$D(IDS("GP020"))>0,1)
	D EQ(.FAIL,"[T800][has GP030]",$D(IDS("GP030"))>0,1)
	D EQ(.FAIL,"[T800][has GP040]",$D(IDS("GP040"))>0,1)
	D EQ(.FAIL,"[T800][has GI001]",$D(IDS("GI001"))>0,1)
	D EQ(.FAIL,"[T800][has GD001]",$D(IDS("GD001"))>0,1)
	D EQ(.FAIL,"[T800][has GB900]",$D(IDS("GB900"))>0,1)
	Q
	;
T810(FAIL) ; valid fixtures parse + validate + canonical export/load
	N IDS,ID,META
	D IDS^EFU837GOLD(.IDS)
	S ID=""
	F  S ID=$O(IDS(ID)) Q:ID=""  D
	. D META^EFU837GOLD(ID,.META)
	. I '+$G(META("valid")) Q
	. D DOVALID(.FAIL,ID,.META)
	Q
	;
T820(FAIL) ; valid fixtures round-trip cleanly
	N IDS,ID,META
	D IDS^EFU837GOLD(.IDS)
	S ID=""
	F  S ID=$O(IDS(ID)) Q:ID=""  D
	. D META^EFU837GOLD(ID,.META)
	. I '+$G(META("valid")) Q
	. I '+$G(META("roundtrip")) Q
	. D DORT(.FAIL,ID,.META)
	Q
	;
T830(FAIL) ; distinct patient fixture preserves subscriber/patient separation
	N ROOT,PATH,OPT,RES,CID
	S ROOT=$NA(^TMP($J,"EFU837GOLDT",830))
	S PATH=$$WRFILE($$DATA^EFU837GOLD("GP020"))
	D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T830][parse ok]",+$G(RES("ok")),1)
	S CID=$O(@ROOT@("norm","claim",0))
	D EQ(.FAIL,"[T830][subscriber member]",$G(@ROOT@("norm","claim",CID,"subscriber_member_id")),"SUB123")
	D EQ(.FAIL,"[T830][patient member]",$G(@ROOT@("norm","claim",CID,"patient_member_id")),"PAT123")
	D EQ(.FAIL,"[T830][subscriber name]",$G(@ROOT@("norm","claim",CID,"subscriber_name")),"SUBSCRIBER, SAM")
	D EQ(.FAIL,"[T830][patient name]",$G(@ROOT@("norm","claim",CID,"patient_name")),"PATIENT, JILL")
	K @ROOT Q
	;
T840(FAIL) ; multi-line and multi-claim fixture specifics
	N ROOT,PATH,OPT,RES,CID,LN
	S ROOT=$NA(^TMP($J,"EFU837GOLDT",840,10))
	S PATH=$$WRFILE($$DATA^EFU837GOLD("GP010"))
	D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T840][gp010 parse ok]",+$G(RES("ok")),1)
	S CID=$O(@ROOT@("norm","claim",0))
	D EQ(.FAIL,"[T840][gp010 line count]",+$G(@ROOT@("norm","claim",CID,"line_count")),2)
	D EQ(.FAIL,"[T840][gp010 line1 proc]",$G(@ROOT@("norm","line",CID,1,"procedure_code")),"99213")
	D EQ(.FAIL,"[T840][gp010 line2 proc]",$G(@ROOT@("norm","line",CID,2,"procedure_code")),"87070")
	K @ROOT
	S ROOT=$NA(^TMP($J,"EFU837GOLDT",840,30))
	S PATH=$$WRFILE($$DATA^EFU837GOLD("GP030"))
	D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T840][gp030 parse ok]",+$G(RES("ok")),1)
	D EQ(.FAIL,"[T840][gp030 claims]",+$G(@ROOT@("stats","claims")),2)
	D EQ(.FAIL,"[T840][gp030 lines]",+$G(@ROOT@("stats","lines")),2)
	D EQ(.FAIL,"[T840][gp030 claim1 id]",$G(@ROOT@("norm","claim",1,"claim_id")),"GP030C1")
	D EQ(.FAIL,"[T840][gp030 claim2 id]",$G(@ROOT@("norm","claim",2,"claim_id")),"GP030C2")
	K @ROOT Q
	;
T850(FAIL) ; ranged dates, diagnosis list, attending provider
	N ROOT,PATH,OPT,RES,CID
	S ROOT=$NA(^TMP($J,"EFU837GOLDT",850))
	S PATH=$$WRFILE($$DATA^EFU837GOLD("GP040"))
	D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T850][parse ok]",+$G(RES("ok")),1)
	S CID=$O(@ROOT@("norm","claim",0))
	D EQ(.FAIL,"[T850][from date]",$G(@ROOT@("norm","claim",CID,"from_date")),"20260310")
	D EQ(.FAIL,"[T850][thru date]",$G(@ROOT@("norm","claim",CID,"thru_date")),"20260312")
	D EQ(.FAIL,"[T850][diag codes]",$G(@ROOT@("norm","claim",CID,"diag_codes")),"A123|B456")
	D EQ(.FAIL,"[T850][attending id]",$G(@ROOT@("norm","claim",CID,"attending_provider_id")),"9999999993")
	K @ROOT Q
	;
T860(FAIL) ; malformed fixture fails validator with expected diagnostics
	N ROOT,PATH,OPT,RES
	S ROOT=$NA(^TMP($J,"EFU837GOLDT",860))
	S PATH=$$WRFILE($$DATA^EFU837GOLD("GB900"))
	D PARSEONLY^EFU837P(PATH,ROOT,.OPT,.RES)
	D RUN^EFU837VR(ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T860][ok false]",+$G(RES("ok")),0)
	D EQ(.FAIL,"[T860][missing clm]",$$HASV(ROOT,"error","X12_CLAIM_MISSING_CLM"),1)
	D EQ(.FAIL,"[T860][svc without claim]",$$HASV(ROOT,"error","X12_SVC_WITHOUT_CLAIM"),1)
	K @ROOT Q
	;
DOVALID(FAIL,ID,META) ; parse/validate/canonical checks for one valid fixture
	N PATH,ROOT,OPT,RES,BASE,ERES,LRES,CID,LN,LAB
	S LAB="[T810]["_ID_"]"
	S ROOT=$NA(^TMP($J,"EFU837GOLDT","VAL",ID))
	S PATH=$$WRFILE($$DATA^EFU837GOLD(ID))
	D PARSE^EFU837P(PATH,ROOT,.OPT,.RES)
	D EQ(.FAIL,LAB_"[parse ok]",+$G(RES("ok")),1)
	D EQ(.FAIL,LAB_"[claims]",+$G(@ROOT@("stats","claims")),+$G(META("claims")))
	D EQ(.FAIL,LAB_"[lines]",+$G(@ROOT@("stats","lines")),+$G(META("lines")))
	S CID=$O(@ROOT@("norm","claim",0))
	S LN=$O(@ROOT@("norm","line",CID,0))
	D EQ(.FAIL,LAB_"[kind]",$G(@ROOT@("norm","claim",CID,"tx_kind")),$G(META("kind")))
	D EQ(.FAIL,LAB_"[guide]",$G(@ROOT@("norm","claim",CID,"guide")),$G(META("guide")))
	D EQ(.FAIL,LAB_"[svc]",$G(@ROOT@("norm","line",CID,LN,"service_kind")),$G(META("svc")))
	S BASE=$$TMPBASE("val-"_ID)
	D EXPORT^EFU837CAN(ROOT,BASE,.ERES)
	D EQ(.FAIL,LAB_"[export ok]",+$G(ERES("ok")),1)
	D LOAD^EFU837CAN(BASE,ROOT,.LRES)
	D EQ(.FAIL,LAB_"[load ok]",+$G(LRES("ok")),1)
	D EQ(.FAIL,LAB_"[load claims]",+$G(LRES("claims")),+$G(META("claims")))
	D EQ(.FAIL,LAB_"[load lines]",+$G(LRES("lines")),+$G(META("lines")))
	K @ROOT Q
	;
DORT(FAIL,ID,META) ; round-trip checks for one valid fixture
	N PATH,ROOT,OPT,RES,BASE,RROOT,CID,LN,LAB
	S LAB="[T820]["_ID_"]"
	S ROOT=$NA(^TMP($J,"EFU837GOLDT","RT",ID))
	S PATH=$$WRFILE($$DATA^EFU837GOLD(ID))
	S BASE=$$TMPBASE("rt-"_ID)
	D RUN^EFU837RT(PATH,BASE,ROOT,.OPT,.RES)
	D EQ(.FAIL,LAB_"[rt ok]",+$G(RES("ok")),1)
	D EQ(.FAIL,LAB_"[src claims]",+$G(RES("parse_src","claims")),+$G(META("claims")))
	D EQ(.FAIL,LAB_"[rebuilt claims]",+$G(RES("claims")),+$G(META("claims")))
	D EQ(.FAIL,LAB_"[rebuilt lines]",+$G(RES("lines")),+$G(META("lines")))
	S RROOT=$NA(@ROOT@("rebuilt"))
	S CID=$O(@RROOT@("norm","claim",0))
	S LN=$O(@RROOT@("norm","line",CID,0))
	D EQ(.FAIL,LAB_"[kind]",$G(@RROOT@("norm","claim",CID,"tx_kind")),$G(META("kind")))
	D EQ(.FAIL,LAB_"[svc]",$G(@RROOT@("norm","line",CID,LN,"service_kind")),$G(META("svc")))
	K @ROOT Q
	;
HASV(ROOT,SEV,CODE) ; whether validator diag exists
	N I,HIT
	S HIT=0,I=0
	F  S I=$O(@ROOT@("vdiag","item",I)) Q:'I  D  Q:HIT
	. I $G(@ROOT@("vdiag","item",I,"severity"))=$G(SEV),$G(@ROOT@("vdiag","item",I,"code"))=$G(CODE) S HIT=1
	Q +$G(HIT)
	;
EQ(FAIL,LABEL,GOT,EXP) ; equality assert
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
	Q "/tmp/efu837goldt-"_$J_"-"_$TR($G(TAG)," /","__")_"-"_$R(999999)
	;
	;