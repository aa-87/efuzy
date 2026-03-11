EFU837SPECT ; efuzy 837 validation-core tests
	;
	; Public:
	;   START
	;   ALL(.FAIL)
	;
	; Notes:
	;   - quiet on success
	;   - additive suite for EFUX12DIAG / EFU837MODEL / EFU837SPEC / EFU837VR
	;
	D START
	Q
	;
START ; default entry
	N FAIL
	S FAIL=0
	D ALL(.FAIL)
	I 'FAIL W !,"OK - EFU837SPECT"
	Q
	;
ALL(FAIL) ; full validation-core suite
	D T500(.FAIL)
	D T501(.FAIL)
	D T510(.FAIL)
	D T511(.FAIL)
	D T512(.FAIL)
	D T520(.FAIL)
	D T521(.FAIL)
	D T530(.FAIL)
	D T540(.FAIL)
	D T550(.FAIL)
	Q
	;
T500(FAIL) ; guide -> kind mapping
	D EQ(.FAIL,"[T500][x222 kind]",$$KIND^EFU837SPEC("005010X222A1"),"837P")
	D EQ(.FAIL,"[T500][x223 kind]",$$KIND^EFU837SPEC("005010X223A2"),"837I")
	D EQ(.FAIL,"[T500][x224 kind]",$$KIND^EFU837SPEC("005010X224A2"),"837D")
	Q
	;
T501(FAIL) ; guide -> required service segment
	D EQ(.FAIL,"[T501][x222 svc]",$$REQSVC^EFU837SPEC("005010X222A1"),"SV1")
	D EQ(.FAIL,"[T501][x223 svc]",$$REQSVC^EFU837SPEC("005010X223A2"),"SV2")
	D EQ(.FAIL,"[T501][x224 svc]",$$REQSVC^EFU837SPEC("005010X224A2"),"SV3")
	Q
	;
T510(FAIL) ; valid 837P passes validator and builds model
	N ROOT,RES,OPT,PATH
	S ROOT=$NA(^TMP($J,"EFU837SPECT",510))
	S PATH=$$WRFILE($$SAMPLEP())
	D PARSEONLY^EFU837P(PATH,ROOT,.OPT,.RES)
	D RUN^EFU837VR(ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T510][validator ok]",+$G(RES("ok")),1)
	D EQ(.FAIL,"[T510][model version]",+$G(@ROOT@("model_version")),1)
	D EQ(.FAIL,"[T510][claim kind]",$G(@ROOT@("model","claim",1,"claim_type")),"837P")
	D EQ(.FAIL,"[T510][svc kind]",$G(@ROOT@("model","line",1,1,"svc_kind")),"SV1")
	K @ROOT Q
	;
T511(FAIL) ; valid 837I passes validator
	N ROOT,RES,OPT,PATH
	S ROOT=$NA(^TMP($J,"EFU837SPECT",511))
	S PATH=$$WRFILE($$SAMPLEI())
	D PARSEONLY^EFU837P(PATH,ROOT,.OPT,.RES)
	D RUN^EFU837VR(ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T511][validator ok]",+$G(RES("ok")),1)
	D EQ(.FAIL,"[T511][claim kind]",$G(@ROOT@("model","claim",1,"claim_type")),"837I")
	D EQ(.FAIL,"[T511][svc kind]",$G(@ROOT@("model","line",1,1,"svc_kind")),"SV2")
	K @ROOT Q
	;
T512(FAIL) ; valid 837D passes validator
	N ROOT,RES,OPT,PATH
	S ROOT=$NA(^TMP($J,"EFU837SPECT",512))
	S PATH=$$WRFILE($$SAMPLED())
	D PARSEONLY^EFU837P(PATH,ROOT,.OPT,.RES)
	D RUN^EFU837VR(ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T512][validator ok]",+$G(RES("ok")),1)
	D EQ(.FAIL,"[T512][claim kind]",$G(@ROOT@("model","claim",1,"claim_type")),"837D")
	D EQ(.FAIL,"[T512][svc kind]",$G(@ROOT@("model","line",1,1,"svc_kind")),"SV3")
	K @ROOT Q
	;
T520(FAIL) ; strict mode flags missing IEA as error
	N ROOT,RES,OPT,PATH,DATA
	S ROOT=$NA(^TMP($J,"EFU837SPECT",520))
	S DATA=$$WRAPISA($$SAMPLEI(),0)
	S PATH=$$WRFILE(DATA)
	D PARSEONLY^EFU837P(PATH,ROOT,.OPT,.RES)
	D STRICT^EFU837VR(ROOT,.RES)
	D EQ(.FAIL,"[T520][ok false]",+$G(RES("ok")),0)
	D EQ(.FAIL,"[T520][missing iea err]",$$HASV(ROOT,"error","X12_ENV_MISSING_IEA"),1)
	K @ROOT Q
	;
T521(FAIL) ; lenient mode downgrades missing IEA to warning
	N ROOT,RES,OPT,PATH,DATA
	S ROOT=$NA(^TMP($J,"EFU837SPECT",521))
	S DATA=$$WRAPISA($$SAMPLEI(),0)
	S PATH=$$WRFILE(DATA)
	S OPT("lenient")=1
	D PARSEONLY^EFU837P(PATH,ROOT,.OPT,.RES)
	D LENIENT^EFU837VR(ROOT,.RES)
	D EQ(.FAIL,"[T521][ok true]",+$G(RES("ok")),1)
	D EQ(.FAIL,"[T521][missing iea warn]",$$HASV(ROOT,"warn","X12_ENV_MISSING_IEA"),1)
	K @ROOT Q
	;
T530(FAIL) ; service kind mismatch is error
	N ROOT,RES,OPT,PATH
	S ROOT=$NA(^TMP($J,"EFU837SPECT",530))
	S PATH=$$WRFILE($$SAMPLEBAD())
	D PARSEONLY^EFU837P(PATH,ROOT,.OPT,.RES)
	D RUN^EFU837VR(ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T530][ok false]",+$G(RES("ok")),0)
	D EQ(.FAIL,"[T530][svc mismatch]",$$HASV(ROOT,"error","X12_SVC_KIND_MISMATCH"),1)
	K @ROOT Q
	;
T540(FAIL) ; missing CLM is fatal structural error
	N ROOT,RES,OPT,PATH
	S ROOT=$NA(^TMP($J,"EFU837SPECT",540))
	S PATH=$$WRFILE($$SAMPLENOCLM())
	D PARSEONLY^EFU837P(PATH,ROOT,.OPT,.RES)
	D RUN^EFU837VR(ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T540][ok false]",+$G(RES("ok")),0)
	D EQ(.FAIL,"[T540][missing clm]",$$HASV(ROOT,"error","X12_CLAIM_MISSING_CLM"),1)
	D EQ(.FAIL,"[T540][svc without claim]",$$HASV(ROOT,"error","X12_SVC_WITHOUT_CLAIM"),1)
	K @ROOT Q
	;
T550(FAIL) ; validator diagnostics carry shape/context
	N ROOT,RES,OPT,PATH
	S ROOT=$NA(^TMP($J,"EFU837SPECT",550))
	S PATH=$$WRFILE($$SAMPLEBAD())
	D PARSEONLY^EFU837P(PATH,ROOT,.OPT,.RES)
	D RUN^EFU837VR(ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T550][vdiag count > 0]",+$G(@ROOT@("vdiag","count"))>0,1)
	D EQ(.FAIL,"[T550][first code]",$G(@ROOT@("vdiag","item",1,"code"))'="",1)
	D EQ(.FAIL,"[T550][first severity]",$G(@ROOT@("vdiag","item",1,"severity"))'="",1)
	K @ROOT Q
	;
EQ(FAIL,LABEL,GOT,EXP) ; equality assert
	I $G(GOT)=$G(EXP) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
	Q
	;
HASV(ROOT,SEV,CODE) ; whether validator diag exists
	N I,HIT
	S HIT=0,I=0
	F  S I=$O(@ROOT@("vdiag","item",I)) Q:'I  D  Q:HIT
	. I $G(@ROOT@("vdiag","item",I,"severity"))=$G(SEV),$G(@ROOT@("vdiag","item",I,"code"))=$G(CODE) S HIT=1
	Q +$G(HIT)
	;
WRFILE(DATA) ; write DATA to a temporary file path and return it
	N PATH,DEV,OLDIO
	S PATH="efu837spect_"_$J_".tmp"
	S OLDIO=$IO
	O PATH:(NEWVERSION:STREAM:WRITEONLY):0
	I '$T Q PATH
	U PATH W DATA
	C PATH
	U OLDIO
	Q PATH
	;
SAMPLEP() ; minimal valid professional transaction-only sample
	Q "ST*837*1*005010X222A1~BHT*0019*00*ABC*20260311*1200*CH~HL*1**20*1~NM1*41*2*SUBMITTER*****46*123~PER*IC*JANE*TE*5551112222~NM1*40*2*RECEIVER*****46*999~HL*2*1*22*0~SBR*P*18*******MC~NM1*IL*1*DOE*JOHN****MI*12345~CLM*PCN1*100***11:B:1*Y*A*Y*Y~DTP*434*D8*20260311~LX*1~SV1*HC:99213*100*UN*1***1~DTP*472*D8*20260311~SE*15*1~"
	;
SAMPLEI() ; minimal valid institutional transaction-only sample
	Q "ST*837*1*005010X223A2~BHT*0019*00*ABC*20260311*1200*CH~HL*1**20*1~NM1*41*2*SUBMITTER*****46*123~NM1*40*2*RECEIVER*****46*999~HL*2*1*22*0~SBR*P*18*******MC~NM1*IL*1*DOE*JANE****MI*SUB1~CLM*ICN1*250***11:B:1*Y*A*Y*I~DTP*434*D8*20260311~HI*BK:1234~LX*1~SV2*0300*HC:85025*250*UN*1~DTP*472*D8*20260311~SE*15*1~"
	;
SAMPLED() ; minimal valid dental transaction-only sample
	Q "ST*837*1*005010X224A2~BHT*0019*00*ABC*20260311*1200*CH~HL*1**20*1~NM1*41*2*SUBMITTER*****46*123~NM1*40*2*RECEIVER*****46*999~HL*2*1*22*0~SBR*P*18*******MC~NM1*IL*1*DOE*DENTAL****MI*SUB1~CLM*DCN1*150***11:B:1*Y*A*Y*D~DTP*434*D8*20260311~LX*1~SV3*AD:D1110*150*UN*1~DTP*472*D8*20260311~SE*14*1~"
	;
SAMPLEBAD() ; 837I guide carrying professional service segment
	Q "ST*837*1*005010X223A2~BHT*0019*00*ABC*20260311*1200*CH~HL*1**20*1~NM1*41*2*SUBMITTER*****46*123~NM1*40*2*RECEIVER*****46*999~HL*2*1*22*0~SBR*P*18*******MC~NM1*IL*1*DOE*JANE****MI*SUB1~CLM*BAD1*250***11:B:1*Y*A*Y*I~DTP*434*D8*20260311~LX*1~SV1*HC:99213*250*UN*1***1~DTP*472*D8*20260311~SE*14*1~"
	;
SAMPLENOCLM() ; transaction with service content but no claim
	Q "ST*837*1*005010X222A1~BHT*0019*00*ABC*20260311*1200*CH~HL*1**20*1~NM1*41*2*SUBMITTER*****46*123~NM1*40*2*RECEIVER*****46*999~HL*2*1*22*0~SBR*P*18*******MC~NM1*IL*1*DOE*JOHN****MI*12345~LX*1~SV1*HC:99213*100*UN*1***1~DTP*472*D8*20260311~SE*13*1~"
	;
WRAPISA(TX,HASIEA) ; wrap transaction in ISA/GS envelope, optionally omit IEA
	N X
	S X="ISA*00*          *00*          *ZZ*SENDERID1234567*ZZ*RECEIVER123456 *260311*1200*^*00501*000000001*0*T*:~"
	S X=X_"GS*HC*SENDER*RECV*20260311*1200*1*X*005010X223A2~"
	S X=X_TX_"GE*1*1~"
	I +$G(HASIEA) S X=X_"IEA*1*000000001~"
	Q X
	;
	;