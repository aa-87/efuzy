EFU837WVAL ; efuzy 837 writer preflight / outbound diagnostics v1
	;
	; Public:
	;   RUN(ROOT,.OPT,.RES)
	;   STRICT(ROOT,.OPT,.RES)
	;   LENIENT(ROOT,.OPT,.RES)
	;   SUMMARY(ROOT,.OUT)
	;
	; Notes:
	;   - additive outbound preflight for canonical CSV -> deterministic 837 writer
	;   - validates canonical claim package before emit
	;   - supports generic checks plus light profile checks for companion-guided output
	;   - profile checks are intentionally limited to fields the current writer can control
	;
	Q
	;
STRICT(ROOT,OPT,RES) ; strict outbound preflight
	N XOPT
	M XOPT=OPT
	S XOPT("writer_strict")=1
	D RUN(ROOT,.XOPT,.RES)
	Q
	;
LENIENT(ROOT,OPT,RES) ; lenient outbound preflight
	N XOPT
	M XOPT=OPT
	S XOPT("writer_lenient")=1
	D RUN(ROOT,.XOPT,.RES)
	Q
	;
RUN(ROOT,OPT,RES) ; run writer preflight rules
	N MODE,CID,CCNT
	K RES
	I $G(ROOT)="" D  Q
	. S RES("ok")=0,RES("fatal")=1,RES("error")=0,RES("warn")=0,RES("info")=0
	. S RES("mode")=$$MODE(.OPT)
	S MODE=$$MODE(.OPT)
	D CLEAR(ROOT)
	I '$D(@ROOT@("canon","claim")) D  G DONE
	. D ERR(ROOT,"X12W_CANONICAL_MISSING","Canonical claim package is missing")
	S CCNT=$$CLAIMS(ROOT)
	I CCNT=0 D  G DONE
	. D ERR(ROOT,"X12W_NO_CLAIMS","Canonical claim package contains no claims")
	S CID=0
	F  S CID=$O(@ROOT@("canon","claim",CID)) Q:'CID  D PASSCLAIM(ROOT,CID,MODE)
	D PASSPROFILE(ROOT,.OPT,MODE)
DONE ;
	D SUMMARY(ROOT,.RES)
	S RES("mode")=MODE
	Q
	;
PASSCLAIM(ROOT,CID,MODE) ; validate one canonical claim record
	N TXK,GUIDE,GK,REQ,SUBN,SUBID,PATN,PATID,HASPAT,FROM,THRU,CTX
	N BILLID,ATTID,LN,LCNT,CHG,CFREQ
	S TXK=$$TXK^EFU837W(ROOT,CID)
	S GUIDE=$$GUIDE^EFU837W(ROOT,CID)
	S GK=$$KIND^EFU837SPEC(GUIDE)
	S REQ=$$REQSVC^EFU837SPEC(GUIDE)
	S FROM=$$CVAL^EFU837W(ROOT,CID,"from_date")
	S THRU=$$CVAL^EFU837W(ROOT,CID,"thru_date")
	S SUBN=$$CVAL^EFU837W(ROOT,CID,"subscriber_name")
	S SUBID=$$CVAL^EFU837W(ROOT,CID,"subscriber_member_id")
	S PATN=$$CVAL^EFU837W(ROOT,CID,"patient_name")
	S PATID=$$CVAL^EFU837W(ROOT,CID,"patient_member_id")
	S HASPAT=$$HASPAT^EFU837W(ROOT,CID)
	S BILLID=$$CVAL^EFU837W(ROOT,CID,"billing_provider_npi")
	S ATTID=$$CVAL^EFU837W(ROOT,CID,"attending_provider_id")
	S CHG=$$CVAL^EFU837W(ROOT,CID,"total_charge")
	S CFREQ=$$CVAL^EFU837W(ROOT,CID,"claim_freq")
	I TXK'="837P",TXK'="837I",TXK'="837D" D
	. K CTX S CTX("claim_id")=CID,CTX("tx_kind")=TXK,CTX("guide")=GUIDE
	. D ERR(ROOT,"X12W_TX_KIND_UNSUPPORTED","Writer only supports 837P, 837I, and 837D canonical claims",.CTX)
	I GUIDE'="",GK="837" D
	. K CTX S CTX("claim_id")=CID,CTX("guide")=GUIDE
	. D ERR(ROOT,"X12W_GUIDE_UNSUPPORTED","Guide is not supported by the deterministic writer",.CTX)
	I GUIDE'="",GK'="837",TXK'="",GK'=TXK D
	. K CTX S CTX("claim_id")=CID,CTX("guide")=GUIDE,CTX("tx_kind")=TXK
	. D ERR(ROOT,"X12W_GUIDE_KIND_MISMATCH","Guide does not match canonical transaction kind",.CTX)
	I $$CVAL^EFU837W(ROOT,CID,"claim_id")="" D
	. K CTX S CTX("claim_id")=CID
	. D ERR(ROOT,"X12W_CLAIM_ID_REQUIRED","Claim id is required for outbound write",.CTX)
	I CHG'="",'$$OKAMT(CHG) D
	. K CTX S CTX("claim_id")=CID,CTX("raw_value")=CHG
	. D ERR(ROOT,"X12W_TOTAL_CHARGE_INVALID","Claim total charge is not numeric",.CTX)
	I CFREQ'="",'$$OKINT(CFREQ) D
	. K CTX S CTX("claim_id")=CID,CTX("raw_value")=CFREQ
	. D ERR(ROOT,"X12W_CLAIM_FREQ_INVALID","Claim frequency code is not numeric",.CTX)
	I FROM'="",'$$OKDATE(FROM) D
	. K CTX S CTX("claim_id")=CID,CTX("qual")="434",CTX("raw_value")=FROM
	. D ERR(ROOT,"X12W_CLAIM_DATE_INVALID","Claim from date is not syntactically valid",.CTX)
	I THRU'="",'$$OKDATE(THRU) D
	. K CTX S CTX("claim_id")=CID,CTX("qual")="434",CTX("raw_value")=THRU
	. D ERR(ROOT,"X12W_CLAIM_DATE_INVALID","Claim thru date is not syntactically valid",.CTX)
	I SUBN=""!(SUBID="") D
	. K CTX S CTX("claim_id")=CID
	. D ERR(ROOT,"X12W_SUBSCRIBER_REQUIRED","Subscriber name and member id are required for outbound write",.CTX)
	I HASPAT,(PATN=""!(PATID="")) D
	. K CTX S CTX("claim_id")=CID
	. D ERR(ROOT,"X12W_PATIENT_INCOMPLETE","Distinct patient loop requires both patient name and patient member id",.CTX)
	S LCNT=0,LN=0
	F  S LN=$O(@ROOT@("canon","claim",CID,"line",LN)) Q:'LN  S LCNT=LCNT+1 D PASSLINE(ROOT,CID,LN,MODE,REQ,FROM)
	I LCNT=0 D
	. K CTX S CTX("claim_id")=CID
	. D ERR(ROOT,"X12W_LINE_REQUIRED","At least one canonical service line is required for outbound write",.CTX)
	I BILLID'="",'$$OKNPI(BILLID) D
	. K CTX S CTX("claim_id")=CID,CTX("raw_value")=BILLID
	. D WARN(ROOT,"X12W_BILLING_NPI_SHAPE","Billing provider NPI is not a 10-digit numeric value",.CTX)
	I ATTID'="",'$$OKID(ATTID) D
	. K CTX S CTX("claim_id")=CID,CTX("raw_value")=ATTID
	. D WARN(ROOT,"X12W_ATTENDING_ID_SHAPE","Attending provider id contains unsupported characters for current writer output",.CTX)
	Q
	;
PASSLINE(ROOT,CID,LN,MODE,REQ,CFROM) ; validate one canonical service line
	N SK,CHG,QTY,DT,PROC,REV,UOM,CTX
	S SK=$G(@ROOT@("canon","claim",CID,"line",LN,"service_kind"))
	S CHG=$G(@ROOT@("canon","claim",CID,"line",LN,"charge"))
	S QTY=$G(@ROOT@("canon","claim",CID,"line",LN,"qty"))
	S DT=$G(@ROOT@("canon","claim",CID,"line",LN,"svc_date"))
	S PROC=$G(@ROOT@("canon","claim",CID,"line",LN,"procedure_code"))
	S REV=$G(@ROOT@("canon","claim",CID,"line",LN,"revenue_code"))
	S UOM=$G(@ROOT@("canon","claim",CID,"line",LN,"uom"))
	I SK="" D
	. K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("default_kind")=REQ
	. D WARN(ROOT,"X12W_SERVICE_KIND_DEFAULTED","Service kind is blank; writer will derive it from guide rules",.CTX)
	. S SK=REQ
	I REQ'="",SK'="",SK'=REQ D
	. K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("expected")=REQ,CTX("actual")=SK
	. D ERR(ROOT,"X12W_SERVICE_KIND_MISMATCH","Service kind does not match guide-specific required segment",.CTX)
	I CHG'="",'$$OKAMT(CHG) D
	. K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("raw_value")=CHG
	. D ERR(ROOT,"X12W_LINE_CHARGE_INVALID","Service line charge is not numeric",.CTX)
	I QTY'="",'$$OKAMT(QTY) D
	. K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("raw_value")=QTY
	. D ERR(ROOT,"X12W_LINE_QTY_INVALID","Service line quantity is not numeric",.CTX)
	I DT="" D  G PLNEXT
	. I $G(CFROM)="" D
	. . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN
	. . D ERR(ROOT,"X12W_LINE_DATE_REQUIRED","Service line date is required when claim-level from date is absent",.CTX)
	. E  D
	. . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("fallback_date")=CFROM
	. . D WARN(ROOT,"X12W_LINE_DATE_DEFAULTED","Service line date is blank; writer will default it from claim-level from date",.CTX)
	I DT'="",'$$OKDATE(DT) D
	. K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("raw_value")=DT
	. D ERR(ROOT,"X12W_LINE_DATE_INVALID","Service line date is not syntactically valid",.CTX)
PLNEXT ;
	I (SK="SV1")!(SK="SV3") D  Q
	. I PROC="" D
	. . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("service_kind")=SK
	. . D ERR(ROOT,"X12W_PROCEDURE_REQUIRED","Procedure code is required for this service line kind",.CTX)
	. I UOM="" D
	. . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN
	. . D WARN(ROOT,"X12W_UOM_DEFAULTED","Unit of measure is blank; writer will default it to UN",.CTX)
	I SK="SV2" D  Q
	. I REV="",PROC="" D
	. . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN
	. . D ERR(ROOT,"X12W_INST_SERVICE_CODE_REQUIRED","Institutional service line requires revenue code and/or procedure code",.CTX)
	. I UOM="" D
	. . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN
	. . D WARN(ROOT,"X12W_UOM_DEFAULTED","Unit of measure is blank; writer will default it to UN",.CTX)
	I UOM="" D
	. K CTX S CTX("claim_id")=CID,CTX("line_no")=LN
	. D WARN(ROOT,"X12W_UOM_DEFAULTED","Unit of measure is blank; writer will default it to UN",.CTX)
	Q
	;
PASSPROFILE(ROOT,OPT,MODE) ; optional companion-guided profile checks
	N PROF
	S PROF=$$UP($$PROF(.OPT))
	I PROF="" Q
	I PROF="CHCN_837P" D PCHCN(ROOT,.OPT,MODE) Q
	I PROF="FORWARDHEALTH_837P" D PFWD(ROOT,.OPT,MODE) Q
	D INFO(ROOT,"X12W_PROFILE_UNKNOWN","Unknown writer profile; only generic preflight was applied")
	Q
	;
PCHCN(ROOT,OPT,MODE) ; CHCN 837P profile checks
	N CID,TXK,GUIDE,CTX,ISA08,GS03,REP,BID
	S ISA08=$$OPT^EFU837W("isa_receiver_id",$$OPT^EFU837W("receiver_id","",.OPT),.OPT)
	S GS03=$$OPT^EFU837W("gs_receiver_id",$$OPT^EFU837W("receiver_id","",.OPT),.OPT)
	S REP=$$OPT^EFU837W("rep","^",.OPT)
	S CID=0
	F  S CID=$O(@ROOT@("canon","claim",CID)) Q:'CID  D
	. S TXK=$$TXK^EFU837W(ROOT,CID)
	. S GUIDE=$$GUIDE^EFU837W(ROOT,CID)
	. I TXK'="837P"!(GUIDE'="005010X222A1") D
	. . K CTX S CTX("claim_id")=CID,CTX("tx_kind")=TXK,CTX("guide")=GUIDE
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_CHCN_837P_ONLY","CHCN profile currently applies only to 837P / 005010X222A1 output",.CTX)
	. S BID=$$CVAL^EFU837W(ROOT,CID,"billing_provider_npi")
	. I BID=""!'$$OKNPI(BID) D
	. . K CTX S CTX("claim_id")=CID,CTX("raw_value")=BID
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_CHCN_BILLING_NPI","CHCN billing provider output expects a 10-digit NPI",.CTX)
	I +$G(OPT("envelope")) D
	. I $$UP(ISA08)'="CHCN" D
	. . K CTX S CTX("expected")="CHCN",CTX("actual")=ISA08,CTX("segment_id")="ISA"
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_CHCN_ISA08","CHCN profile expects ISA08 receiver id CHCN",.CTX)
	. I $$UP(GS03)'="CHCN" D
	. . K CTX S CTX("expected")="CHCN",CTX("actual")=GS03,CTX("segment_id")="GS"
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_CHCN_GS03","CHCN profile expects GS03 receiver code CHCN",.CTX)
	. I REP'="$" D
	. . K CTX S CTX("expected")="$",CTX("actual")=REP,CTX("segment_id")="ISA11"
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_CHCN_ISA11","CHCN guide recommends ISA11 use a non-alphanumeric repetition separator such as $",.CTX)
	Q
	;
PFWD(ROOT,OPT,MODE) ; ForwardHealth 837P profile checks
	N CID,TXK,GUIDE,CTX,ISA08,GS03,NM109,NM103,ISA06,SUBID,BHT06
	S ISA08=$$OPT^EFU837W("isa_receiver_id",$$OPT^EFU837W("receiver_id","",.OPT),.OPT)
	S GS03=$$OPT^EFU837W("gs_receiver_id",$$OPT^EFU837W("receiver_id","",.OPT),.OPT)
	S NM109=$$OPT^EFU837W("receiver_id","",.OPT)
	S NM103=$$OPT^EFU837W("receiver_name","RECEIVER",.OPT)
	S ISA06=$$OPT^EFU837W("isa_sender_id",$$OPT^EFU837W("submitter_id","",.OPT),.OPT)
	S SUBID=$$OPT^EFU837W("submitter_id","",.OPT)
	S BHT06=$$OPT^EFU837W("bht_type","CH",.OPT)
	S CID=0
	F  S CID=$O(@ROOT@("canon","claim",CID)) Q:'CID  D
	. S TXK=$$TXK^EFU837W(ROOT,CID)
	. S GUIDE=$$GUIDE^EFU837W(ROOT,CID)
	. I TXK'="837P"!(GUIDE'="005010X222A1") D
	. . K CTX S CTX("claim_id")=CID,CTX("tx_kind")=TXK,CTX("guide")=GUIDE
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_FORWARD_837P_ONLY","ForwardHealth profile currently applies only to 837P / 005010X222A1 output",.CTX)
	. D FHUP(ROOT,CID,MODE)
	I +$G(OPT("envelope")) D
	. I $$UP(ISA08)'="WISC_DHFS" D
	. . K CTX S CTX("expected")="WISC_DHFS",CTX("actual")=ISA08,CTX("segment_id")="ISA"
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_FORWARD_ISA08","ForwardHealth profile expects ISA08 receiver id WISC_DHFS",.CTX)
	. I '$$FGS($$UP(GS03)) D
	. . K CTX S CTX("expected")="WISC_TXIX|WISC_WWWP|WISC_WCDP",CTX("actual")=GS03,CTX("segment_id")="GS"
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_FORWARD_GS03","ForwardHealth profile expects GS03 receiver code WISC_TXIX, WISC_WWWP, or WISC_WCDP",.CTX)
	. I '$$FGS($$UP(NM109)) D
	. . K CTX S CTX("expected")="WISC_TXIX|WISC_WWWP|WISC_WCDP",CTX("actual")=NM109,CTX("segment_id")="NM1*40"
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_FORWARD_NM109","ForwardHealth profile expects 1000B NM109 receiver id WISC_TXIX, WISC_WWWP, or WISC_WCDP",.CTX)
	. I $$UP(NM103)'="FORWARDHEALTH" D
	. . K CTX S CTX("expected")="FORWARDHEALTH",CTX("actual")=NM103,CTX("segment_id")="NM1*40"
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_FORWARD_RECEIVER_NAME","ForwardHealth profile expects receiver name FORWARDHEALTH",.CTX)
	. I $$UP(BHT06)'="CH" D
	. . K CTX S CTX("expected")="CH",CTX("actual")=BHT06,CTX("segment_id")="BHT06"
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_FORWARD_BHT06","ForwardHealth profile expects BHT06 CH for claim submissions",.CTX)
	. I ISA06'="",SUBID'="",ISA06'=SUBID D
	. . K CTX S CTX("expected")=ISA06,CTX("actual")=SUBID,CTX("segment_id")="NM1*41"
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_FORWARD_SUBMITTER_ID","ForwardHealth profile expects submitter identifier to match ISA06",.CTX)
	Q
	;
FHUP(ROOT,CID,MODE) ; ForwardHealth uppercase checks for key outbound text fields
	N K,VAL,CTX
	F K="claim_id","subscriber_name","patient_name","primary_payer_name","billing_provider_name","attending_provider_name" D
	. S VAL=$$CVAL^EFU837W(ROOT,CID,K)
	. I VAL'="",$$HASLOW(VAL) D
	. . K CTX S CTX("claim_id")=CID,CTX("field")=K,CTX("actual")=VAL
	. . D EMIT(ROOT,MODE,"X12W_PROFILE_FORWARD_UPPERCASE","ForwardHealth profile expects alpha characters in outbound 837 text values to be uppercase",.CTX)
	Q
	;
PROF(OPT) ; profile name helper
	I $G(OPT("profile"))'="" Q OPT("profile")
	Q $G(OPT("companion_profile"))
	;
MODE(OPT) ; writer strict/lenient mode
	I +$G(OPT("writer_lenient")) Q "lenient"
	I +$G(OPT("lenient")) Q "lenient"
	I +$G(OPT("writer_strict")) Q "strict"
	I +$G(OPT("strict")) Q "strict"
	Q "strict"
	;
CLAIMS(ROOT) ; canonical claim count
	N N,C
	S N=+$G(@ROOT@("canon","claims"))
	I N>0 Q N
	S C=0,N=0
	F  S C=$O(@ROOT@("canon","claim",C)) Q:'C  S N=N+1
	Q N
	;
EMIT(ROOT,MODE,CODE,MSG,CTX) ; error in strict, warning in lenient
	I $G(MODE)="lenient" D WARN(ROOT,$G(CODE),$G(MSG),.CTX) Q
	D ERR(ROOT,$G(CODE),$G(MSG),.CTX)
	Q
	;
CLEAR(ROOT) ; clear writer diagnostics
	K @ROOT@("wdiag")
	Q
	;
ADD(ROOT,SEV,CODE,MSG,CTX,ID) ; append one writer diagnostic
	N IDX,S
	S S=$$LOW($G(SEV)) I S="" S S="error"
	S IDX=+$G(@ROOT@("wdiag","last"))+1
	S @ROOT@("wdiag","last")=IDX
	S @ROOT@("wdiag","count")=+$G(@ROOT@("wdiag","count"))+1
	S @ROOT@("wdiag","by_sev",S)=+$G(@ROOT@("wdiag","by_sev",S))+1
	S @ROOT@("wdiag","item",IDX,"severity")=S
	S @ROOT@("wdiag","item",IDX,"code")=$G(CODE)
	S @ROOT@("wdiag","item",IDX,"message")=$G(MSG)
	I $D(CTX) M @ROOT@("wdiag","item",IDX,"ctx")=CTX
	S ID=IDX
	Q
	;
ERR(ROOT,CODE,MSG,CTX,ID) D ADD(ROOT,"error",$G(CODE),$G(MSG),.CTX,.ID) Q
WARN(ROOT,CODE,MSG,CTX,ID) D ADD(ROOT,"warn",$G(CODE),$G(MSG),.CTX,.ID) Q
INFO(ROOT,CODE,MSG,CTX,ID) D ADD(ROOT,"info",$G(CODE),$G(MSG),.CTX,.ID) Q
FATAL(ROOT,CODE,MSG,CTX,ID) D ADD(ROOT,"fatal",$G(CODE),$G(MSG),.CTX,.ID) Q
	;
SUMMARY(ROOT,OUT) ; summarize writer diagnostics into OUT
	K OUT
	S OUT("total")=+$G(@ROOT@("wdiag","count"))
	S OUT("fatal")=+$G(@ROOT@("wdiag","by_sev","fatal"))
	S OUT("error")=+$G(@ROOT@("wdiag","by_sev","error"))
	S OUT("warn")=+$G(@ROOT@("wdiag","by_sev","warn"))
	S OUT("info")=+$G(@ROOT@("wdiag","by_sev","info"))
	S OUT("ok")=$S((OUT("fatal")+OUT("error"))>0:0,1:1)
	Q
	;
FGS(X) ; allowed ForwardHealth receiver/app ids for claims
	I $G(X)="WISC_TXIX" Q 1
	I $G(X)="WISC_WWWP" Q 1
	I $G(X)="WISC_WCDP" Q 1
	Q 0
	;
OKDATE(X) ; basic X12 date validation
	N Y
	S Y=$G(X)
	I Y?8N Q 1
	I Y?8N1"-"8N Q 1
	Q 0
	;
OKAMT(X) ; numeric-ish amount
	N Y
	S Y=$G(X)
	I Y?1"-".N Q 1
	I Y?.N Q 1
	I Y?1"-".N1".".N Q 1
	I Y?.N1".".N Q 1
	Q 0
	;
OKINT(X) ; integer-ish value
	Q $S($G(X)?1.N:1,1:0)
	;
OKNPI(X) ; simple 10-digit NPI shape check
	Q $S($G(X)?10N:1,1:0)
	;
OKID(X) ; conservative id shape for current writer
	N Y
	S Y=$G(X)
	I Y="" Q 0
	I Y?1.AN Q 1
	Q 0
	;
HASLOW(X) ; whether string contains lowercase alpha
	N I,C,A,Q S Q=0
	F I=1:1:$L($G(X)) S C=$E(X,I),A=$A(C) I A>96,A<123 S Q=1 Q 
	Q Q
	;
UP(X) ; uppercase alpha only
	N Y,I,C,A
	S Y=""
	F I=1:1:$L($G(X)) S C=$E(X,I) D
	. S A=$A(C)
	. I A>96,A<123 S C=$C(A-32)
	. S Y=Y_C
	Q Y
	;
LOW(X) ; lowercase alpha only
	N Y,I,C,A
	S Y=""
	F I=1:1:$L($G(X)) S C=$E(X,I) D
	. S A=$A(C)
	. I A>64,A<91 S C=$C(A+32)
	. S Y=Y_C
	Q Y
	;
	;