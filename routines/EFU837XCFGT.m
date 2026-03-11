EFU837XCFGT ; efuzy 837 export profile tests
	; Quiet on success.;
	;
	D ALL Q
	;
ALL ; run all tests
	N FAIL
	S FAIL=0
	D T600(.FAIL)
	D T601(.FAIL)
	D T602(.FAIL)
	D T603(.FAIL)
	D T604(.FAIL)
	D T605(.FAIL)
	D T610(.FAIL)
	I 'FAIL W !,"OK - EFU837XCFGT" 
	Q
	;
T600(FAIL) ; headers and profile metadata
	N H
	D HEADERS^EFU837XCFG("claim_summary",.H)
	D EQ(.FAIL,"[T600][field count]",+$O(H(""),-1),18)
	D EQ(.FAIL,"[T600][first header]",$G(H(1)),"claim_id")
	D EQ(.FAIL,"[T600][last header]",$G(H(18)),"diag_codes")
	D EQ(.FAIL,"[T600][combined row source]",$$ROWSRC^EFU837XCFG("combined_compact"),"COMBINED")
	Q
	;
T601(FAIL) ; build combined row from synthetic root
	N ROOT,ROW
	S ROOT=$NA(^TMP($J,"EFU837XCFGT",601))
	D SYN(ROOT)
	D BUILDROW^EFU837XP("combined_compact",ROOT,1,1,.ROW)
	D EQ(.FAIL,"[T601][claim id]",$G(ROW(4)),"ICN1")
	D EQ(.FAIL,"[T601][line no]",$G(ROW(20)),1)
	D EQ(.FAIL,"[T601][procedure code]",$G(ROW(24)),"85025")
	Q
	;
T602(FAIL) ; export claim summary file
	N ROOT,PATH,RES,ROWS
	S ROOT=$NA(^TMP($J,"EFU837XCFGT",602))
	D SYN(ROOT)
	S PATH="efu837xcfgt_claims_"_$J_".csv"
	D EXPORT^EFU837XP("claim_summary",ROOT,PATH,.RES)
	D EQ(.FAIL,"[T602][export ok]",+$G(RES("ok")),1)
	D EQ(.FAIL,"[T602][rows]",+$G(RES("rows")),1)
	S ROWS=$$CSVROWS(PATH)
	D EQ(.FAIL,"[T602][csv data rows]",ROWS,1)
	Q
	;
T603(FAIL) ; export service lines file
	N ROOT,PATH,RES,ROWS
	S ROOT=$NA(^TMP($J,"EFU837XCFGT",603))
	D SYN(ROOT)
	S PATH="efu837xcfgt_lines_"_$J_".csv"
	D EXPORT^EFU837XP("service_lines",ROOT,PATH,.RES)
	D EQ(.FAIL,"[T603][export ok]",+$G(RES("ok")),1)
	D EQ(.FAIL,"[T603][rows]",+$G(RES("rows")),2)
	S ROWS=$$CSVROWS(PATH)
	D EQ(.FAIL,"[T603][csv data rows]",ROWS,2)
	Q
	;
T604(FAIL) ; subscriber/patient profile values
	N ROOT,ROW
	S ROOT=$NA(^TMP($J,"EFU837XCFGT",604))
	D SYN(ROOT)
	D BUILDROW^EFU837XP("subscriber_patient",ROOT,1,0,.ROW)
	D EQ(.FAIL,"[T604][subscriber name]",$G(ROW(2)),"DOE, JANE")
	D EQ(.FAIL,"[T604][patient name]",$G(ROW(6)),"DOE, JOHN")
	D EQ(.FAIL,"[T604][payer]",$G(ROW(10)),"MEDICARE")
	Q
	;
T605(FAIL) ; provider profile values
	N ROOT,ROW
	S ROOT=$NA(^TMP($J,"EFU837XCFGT",605))
	D SYN(ROOT)
	D BUILDROW^EFU837XP("provider_context",ROOT,1,0,.ROW)
	D EQ(.FAIL,"[T605][billing name]",$G(ROW(2)),"BILLING CLINIC")
	D EQ(.FAIL,"[T605][attending id]",$G(ROW(6)),"1111111111")
	Q
	;
T610(FAIL) ; exportparse integration with minimal file
	N PATH,OUT,ROOT,OPT,RES,ROWS
	S PATH="efu837xcfgt_in_"_$J_".tmp"
	S OUT="efu837xcfgt_out_"_$J_".csv"
	D WRFILE(PATH,$$MIN837())
	S ROOT=$NA(^TMP($J,"EFU837XCFGT",610))
	D EXPORTPARSE^EFU837XP("claim_summary",PATH,OUT,ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T610][parse+export ok]",+$G(RES("ok")),1)
	S ROWS=$$CSVROWS(OUT)
	D EQ(.FAIL,"[T610][csv rows]",ROWS,1)
	Q
	;
SYN(ROOT) ; synthetic normalized root
	K @ROOT
	S @ROOT@("norm","claim",1,"claim_id")="ICN1"
	S @ROOT@("norm","claim",1,"tx_kind")="837I"
	S @ROOT@("norm","claim",1,"guide")="005010X223A2"
	S @ROOT@("norm","claim",1,"tx_control")=1
	S @ROOT@("norm","claim",1,"total_charge")=500
	S @ROOT@("norm","claim",1,"from_date")=20260311
	S @ROOT@("norm","claim",1,"thru_date")=20260311
	S @ROOT@("norm","claim",1,"facility_code")=11
	S @ROOT@("norm","claim",1,"claim_freq")=1
	S @ROOT@("norm","claim",1,"subscriber_name")="DOE, JANE"
	S @ROOT@("norm","claim",1,"subscriber_member_id")="SUB1"
	S @ROOT@("norm","claim",1,"patient_name")="DOE, JOHN"
	S @ROOT@("norm","claim",1,"patient_member_id")="PAT1"
	S @ROOT@("norm","claim",1,"primary_payer_name")="MEDICARE"
	S @ROOT@("norm","claim",1,"other_payer_name")=""
	S @ROOT@("norm","claim",1,"billing_provider_name")="BILLING CLINIC"
	S @ROOT@("norm","claim",1,"billing_provider_npi")="9999999999"
	S @ROOT@("norm","claim",1,"attending_provider_name")="SMITH, ADAM"
	S @ROOT@("norm","claim",1,"diag_codes")="1234|5678"
	S @ROOT@("norm","claim",1,"line_count")=2
	S @ROOT@("norm","party","subscriber",1,"name")="DOE, JANE"
	S @ROOT@("norm","party","subscriber",1,"member_id")="SUB1"
	S @ROOT@("norm","party","subscriber",1,"dob")=19700101
	S @ROOT@("norm","party","subscriber",1,"sex")="F"
	S @ROOT@("norm","party","patient",1,"name")="DOE, JOHN"
	S @ROOT@("norm","party","patient",1,"member_id")="PAT1"
	S @ROOT@("norm","party","patient",1,"dob")=20010101
	S @ROOT@("norm","party","patient",1,"sex")="M"
	S @ROOT@("norm","provider","billing",1,"name")="BILLING CLINIC"
	S @ROOT@("norm","provider","billing",1,"id")="9999999999"
	S @ROOT@("norm","provider","billing",1,"id_qual")="XX"
	S @ROOT@("norm","provider","claim",1,"71","name")="SMITH, ADAM"
	S @ROOT@("norm","provider","claim",1,"71","id")="1111111111"
	S @ROOT@("norm","line",1,1,"claim_id")="ICN1"
	S @ROOT@("norm","line",1,1,"line_no")=1
	S @ROOT@("norm","line",1,1,"tx_kind")="837I"
	S @ROOT@("norm","line",1,1,"guide")="005010X223A2"
	S @ROOT@("norm","line",1,1,"service_kind")="SV2"
	S @ROOT@("norm","line",1,1,"revenue_code")="0300"
	S @ROOT@("norm","line",1,1,"procedure_qual")="HC"
	S @ROOT@("norm","line",1,1,"procedure_code")="85025"
	S @ROOT@("norm","line",1,1,"charge")=250
	S @ROOT@("norm","line",1,1,"uom")="UN"
	S @ROOT@("norm","line",1,1,"qty")=1
	S @ROOT@("norm","line",1,1,"svc_date")=20260311
	M @ROOT@("norm","line",1,2)=@ROOT@("norm","line",1,1)
	S @ROOT@("norm","line",1,2,"line_no")=2
	S @ROOT@("norm","line",1,2,"procedure_code")="80053"
	S @ROOT@("norm","line",1,2,"charge")=250
	Q
	;
MIN837() ; minimal parseable institutional sample
	Q "ISA*00*          *00*          *ZZ*SENDERID1234567*ZZ*RECEIVER123456 *260311*1200*^*00501*000000001*0*T*:~GS*HC*SENDER*RECV*20260311*1200*1*X*005010X223A2~ST*837*1*005010X223A2~BHT*0019*00*ABC*20260311*1200*CH~HL*1**20*1~NM1*41*2*SUBMITTER*****46*123~NM1*40*2*RECEIVER*****46*999~HL*2*1*22*0~SBR*P*18*******MC~NM1*IL*1*DOE*JANE****MI*SUB1~CLM*ICN1*250***11:B:1*Y*A*Y*I~DTP*434*D8*20260311~HI*BK:1234~LX*1~SV2*0300*HC:85025*250*UN*1~DTP*472*D8*20260311~SE*15*1~GE*1*1~IEA*1*000000001~"
	;
WRFILE(PATH,DATA) ; write helper
	N DEV,OLDIO
	S DEV=PATH,OLDIO=$IO
	O DEV:(NEWVERSION:STREAM):1
	I '$T U OLDIO Q
	U DEV W DATA,!
	C DEV U OLDIO
	Q
	;
CSVROWS(PATH) ; count non-header non-blank rows
	N DEV,OLDIO,X,CNT,SEEN,EOF,OLDET
	S DEV=PATH,OLDIO=$IO,CNT=0,SEEN=0,EOF=0,OLDET=$ETRAP
	O DEV:(READONLY):1
	I '''$T U OLDIO Q -1
	U DEV
	S $ETRAP="S EOF=1,$ECODE="""""
	F  Q:EOF  D
	. R X:1
	. I '$T S EOF=1 Q
	. I X="" Q
	. I '''SEEN S SEEN=1 Q
	. S CNT=CNT+1
	S $ETRAP=OLDET
	C DEV U OLDIO
	Q CNT
	;
EQ(FAIL,NAME,GOT,EXP)
	I $G(GOT)'=$G(EXP) D
	. W !,"FAIL: ",NAME,": got=",$G(GOT)," expected=",$G(EXP)
	. S FAIL=1
	Q
	;
	;