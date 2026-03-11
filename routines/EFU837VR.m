EFU837VR ; efuzy X12 837 rule-driven validator v1
 ;
 ; Public:
 ;   RUN(ROOT,.OPT,.RES)
 ;   STRICT(ROOT,.RES)
 ;   LENIENT(ROOT,.RES)
 ;
 Q
 ;
STRICT(ROOT,RES) ; strict mode wrapper
 N OPT
 S OPT("strict")=1
 D RUN(ROOT,.OPT,.RES)
 Q
 ;
LENIENT(ROOT,RES) ; lenient mode wrapper
 N OPT
 S OPT("lenient")=1
 D RUN(ROOT,.OPT,.RES)
 Q
 ;
RUN(ROOT,OPT,RES) ; validate one parsed 837 root using EFU837SPEC + EFUX12DIAG
 N MODE
 K RES
 K @ROOT@("vdiag")
 I '$D(@ROOT@("model_version")) D BUILD^EFU837MODEL(ROOT,.RES)
 S MODE=$$MODE(ROOT,.OPT)
 D PASSENV(ROOT,MODE)
 D PASSGUIDE(ROOT,MODE)
 D PASSCLAIM(ROOT,MODE)
 D PASSDATA(ROOT,MODE)
 D SUMMARY^EFUX12DIAG(ROOT,.RES)
 S RES("mode")=MODE
 Q
 ;
PASSENV(ROOT,MODE) ; envelope/control validation
 N CTX,TX,G,WANTENV
 S WANTENV=$$WANTENV(ROOT)
 I WANTENV,$$ENVRULE^EFU837SPEC(MODE,"require_isa"),'$D(@ROOT@("meta","isa","control")) D
 . K CTX S CTX("segment_id")="ISA",CTX("loop_id")="env"
 . D EMIT(ROOT,MODE,"X12_ENV_MISSING_ISA","ISA segment not found",.CTX)
 I WANTENV,$$ENVRULE^EFU837SPEC(MODE,"require_iea"),'$D(@ROOT@("meta","iea","control")) D
 . K CTX S CTX("segment_id")="IEA",CTX("loop_id")="env"
 . D EMIT(ROOT,MODE,"X12_ENV_MISSING_IEA","IEA segment not found",.CTX)
 I WANTENV,$$ENVRULE^EFU837SPEC(MODE,"require_gs"),+$O(@ROOT@("group",0))=0 D
 . K CTX S CTX("segment_id")="GS",CTX("loop_id")="env"
 . D EMIT(ROOT,MODE,"X12_ENV_MISSING_GS","GS segment not found",.CTX)
 I WANTENV,$$ENVRULE^EFU837SPEC(MODE,"require_ge"),+$O(@ROOT@("group",0))>0 D
 . S G=0 F  S G=$O(@ROOT@("group",G)) Q:'G  I '$D(@ROOT@("group",G,"ge","control")) D
 . . K CTX S CTX("segment_id")="GE",CTX("loop_id")="env",CTX("group")=G
 . . D EMIT(ROOT,MODE,"X12_ENV_MISSING_GE","GE segment not found for functional group",.CTX)
 I WANTENV,$D(@ROOT@("meta","isa","control")),$D(@ROOT@("meta","iea","control")),@ROOT@("meta","isa","control")'=@ROOT@("meta","iea","control") D
 . K CTX S CTX("segment_id")="IEA",CTX("loop_id")="env"
 . S CTX("isa_control")=$G(@ROOT@("meta","isa","control"))
 . S CTX("iea_control")=$G(@ROOT@("meta","iea","control"))
 . D EMIT(ROOT,MODE,"X12_CTRL_ISA_IEA_MISMATCH","ISA13 and IEA02 do not match",.CTX)
 S TX=0
 F  S TX=$O(@ROOT@("tx",TX)) Q:'TX  D
 . I $$ENVRULE^EFU837SPEC(MODE,"require_st"),'$D(@ROOT@("tx",TX,"st","control")) D
 . . K CTX S CTX("segment_id")="ST",CTX("loop_id")="tx",CTX("tx_id")=TX
 . . D EMIT(ROOT,MODE,"X12_ENV_MISSING_ST","ST segment not found for transaction",.CTX)
 . I $$ENVRULE^EFU837SPEC(MODE,"require_se"),'$D(@ROOT@("tx",TX,"se","control")) D
 . . K CTX S CTX("segment_id")="SE",CTX("loop_id")="tx",CTX("tx_id")=TX
 . . D EMIT(ROOT,MODE,"X12_ENV_MISSING_SE","SE segment not found for transaction",.CTX)
 . I $D(@ROOT@("tx",TX,"st","control")),$D(@ROOT@("tx",TX,"se","control")),@ROOT@("tx",TX,"st","control")'=@ROOT@("tx",TX,"se","control") D
 . . K CTX S CTX("segment_id")="SE",CTX("loop_id")="tx",CTX("tx_id")=TX
 . . S CTX("st_control")=$G(@ROOT@("tx",TX,"st","control"))
 . . S CTX("se_control")=$G(@ROOT@("tx",TX,"se","control"))
 . . D EMIT(ROOT,MODE,"X12_CTRL_ST_SE_MISMATCH","ST02 and SE02 do not match",.CTX)
 Q
 ;
WANTENV(ROOT) ; whether interchange-level envelope should be enforced
 I $G(@ROOT@("meta","delim","framing"))="interchange" Q 1
 I +$G(@ROOT@("meta","delim","has_isa")) Q 1
 I $D(@ROOT@("meta","isa")) Q 1
 I +$O(@ROOT@("group",0))>0 Q 1
 Q 0
 ;
PASSGUIDE(ROOT,MODE) ; guide/service-kind compatibility
 N TX,G,K,REQ,CID,LN,SV,CTX
 S TX=0
 F  S TX=$O(@ROOT@("model","tx",TX)) Q:'TX  D
 . S G=$G(@ROOT@("model","tx",TX,"guide"))
 . S K=$$KIND^EFU837SPEC(G)
 . I K="837" D
 . . K CTX S CTX("tx_id")=TX,CTX("segment_id")="ST",CTX("loop_id")="tx",CTX("guide")=G
 . . D EMIT(ROOT,MODE,"X12_UNSUPPORTED_GUIDE","Guide is not recognized by the validation core",.CTX)
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . S TX=+$G(@ROOT@("model","claim",CID,"tx_id"))
 . S G=$G(@ROOT@("model","tx",TX,"guide"))
 . S REQ=$$REQSVC^EFU837SPEC(G)
 . S LN=0
 . F  S LN=$O(@ROOT@("model","line",CID,LN)) Q:'LN  D
 . . S SV=$G(@ROOT@("model","line",CID,LN,"svc_kind"))
 . . I REQ'="",SV'="",SV'=REQ D
 . . . K CTX S CTX("tx_id")=TX,CTX("claim_id")=CID,CTX("line_no")=LN,CTX("segment_id")=SV,CTX("loop_id")="2400"
 . . . S CTX("expected")=REQ,CTX("actual")=SV,CTX("guide")=G
 . . . D ERR^EFUX12DIAG(ROOT,"X12_SVC_KIND_MISMATCH","Service segment does not match transaction guide",.CTX)
 Q
 ;
PASSCLAIM(ROOT,MODE) ; claim/service structural validation
 N CID,LN,CTX,SVTOT
 S SVTOT=+$G(@ROOT@("stats","segment","SV1"))
 S SVTOT=SVTOT+$G(@ROOT@("stats","segment","SV2"))
 S SVTOT=SVTOT+$G(@ROOT@("stats","segment","SV3"))
 I +$G(@ROOT@("stats","transactions"))>0,+$G(@ROOT@("stats","claims"))=0 D
 . K CTX S CTX("loop_id")="2300",CTX("segment_id")="CLM"
 . D ERR^EFUX12DIAG(ROOT,"X12_CLAIM_MISSING_CLM","No CLM segment was found for parsed transaction content",.CTX)
 I SVTOT>0,+$G(@ROOT@("stats","claims"))=0 D
 . K CTX S CTX("loop_id")="2400",CTX("segment_id")="SV?"
 . D ERR^EFUX12DIAG(ROOT,"X12_SVC_WITHOUT_CLAIM","Service content exists without any parsed claim",.CTX)
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . I $G(@ROOT@("model","claim",CID,"claim_id"))="" D
 . . K CTX S CTX("claim_id")=CID,CTX("loop_id")="2300",CTX("segment_id")="CLM"
 . . D ERR^EFUX12DIAG(ROOT,"X12_CLAIM_MISSING_CLM","Claim loop is missing CLM01 / patient control number",.CTX)
 . I +$O(@ROOT@("model","line",CID,0))=0 D
 . . K CTX S CTX("claim_id")=CID,CTX("loop_id")="2400",CTX("segment_id")="LX"
 . . D ERR^EFUX12DIAG(ROOT,"X12_LINE_WITHOUT_LX","Claim has no service line content",.CTX)
 . S LN=0
 . F  S LN=$O(@ROOT@("model","line",CID,LN)) Q:'LN  D
 . . I $G(@ROOT@("model","line",CID,LN,"svc_kind"))="" D
 . . . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("loop_id")="2400",CTX("segment_id")="SV?"
 . . . D ERR^EFUX12DIAG(ROOT,"X12_SEGMENT_NOT_ALLOWED","Service line is missing the primary service segment",.CTX)
 Q
 ;
PASSDATA(ROOT,MODE) ; basic date/amount sanity
 N CID,LN,QL,VAL,CTX
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . S QL=""
 . F  S QL=$O(@ROOT@("model","claim",CID,"date",QL)) Q:QL=""  D
 . . S VAL=$G(@ROOT@("model","claim",CID,"date",QL))
 . . I VAL'="",'$$OKDATE(VAL) D
 . . . K CTX S CTX("claim_id")=CID,CTX("loop_id")="2300",CTX("segment_id")="DTP",CTX("qual")=QL,CTX("raw_value")=VAL
 . . . D ERR^EFUX12DIAG(ROOT,"X12_BAD_DATE","Claim date value is not syntactically valid",.CTX)
 . I $G(@ROOT@("model","claim",CID,"claim_amount"))'="",'$$OKAMT($G(@ROOT@("model","claim",CID,"claim_amount"))) D
 . . K CTX S CTX("claim_id")=CID,CTX("loop_id")="2300",CTX("segment_id")="CLM",CTX("raw_value")=$G(@ROOT@("model","claim",CID,"claim_amount"))
 . . D ERR^EFUX12DIAG(ROOT,"X12_BAD_AMOUNT","Claim amount is not numeric",.CTX)
 . S LN=0
 . F  S LN=$O(@ROOT@("model","line",CID,LN)) Q:'LN  D
 . . S VAL=$G(@ROOT@("model","line",CID,LN,"date","472"))
 . . I VAL'="",'$$OKDATE(VAL) D
 . . . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("loop_id")="2400",CTX("segment_id")="DTP",CTX("qual")="472",CTX("raw_value")=VAL
 . . . D ERR^EFUX12DIAG(ROOT,"X12_BAD_DATE","Service line date value is not syntactically valid",.CTX)
 . . I $G(@ROOT@("model","line",CID,LN,"charge_amount"))'="",'$$OKAMT($G(@ROOT@("model","line",CID,LN,"charge_amount"))) D
 . . . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("loop_id")="2400",CTX("segment_id")=$G(@ROOT@("model","line",CID,LN,"svc_kind")),CTX("raw_value")=$G(@ROOT@("model","line",CID,LN,"charge_amount"))
 . . . D ERR^EFUX12DIAG(ROOT,"X12_BAD_AMOUNT","Service line charge amount is not numeric",.CTX)
 Q
 ;
EMIT(ROOT,MODE,CODE,MSG,CTX) ; severity by mode for envelope/control style findings
 I MODE="lenient" D WARN^EFUX12DIAG(ROOT,$G(CODE),$G(MSG),.CTX) Q
 D ERR^EFUX12DIAG(ROOT,$G(CODE),$G(MSG),.CTX)
 Q
 ;
MODE(ROOT,OPT) ; strict or lenient
 I +$G(OPT("strict")) Q "strict"
 I +$G(OPT("lenient")) Q "lenient"
 I +$G(@ROOT@("meta","lenient")) Q "lenient"
 I +$G(@ROOT@("meta","accept_bad_envelope")) Q "lenient"
 Q "strict"
 ;
OKDATE(X) ; basic X12 date validation: D8 or RD8-style stored value
 N Y
 S Y=$G(X)
 I Y?8N Q 1
 I Y?8N1"-"8N Q 1
 I Y?12N Q 1
 I Y?1.2N1":"1.2N Q 1
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
