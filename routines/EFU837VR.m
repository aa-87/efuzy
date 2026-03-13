EFU837VR ; efuzy X12 837 rule-driven validator v2
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
 N MODE,PROF,PSTAT,CGRES
 K RES
 K @ROOT@("vdiag")
 I '$D(@ROOT@("model_version")) D BUILD^EFU837MODEL(ROOT,.RES)
 S MODE=$$MODE(ROOT,.OPT)
 S PROF=$S($G(OPT("profile"))'="":$G(OPT("profile")),$G(OPT("companion_profile"))'="":$G(OPT("companion_profile")),1:"")
 I PROF'="" S PSTAT=$$STATUS^EFU837CG(PROF)
 D PASSENV(ROOT,MODE)
 D PASSGUIDE(ROOT,MODE)
 D PASSCLAIM(ROOT,MODE)
 D PASSDATA(ROOT,MODE)
 D PASSPARTY(ROOT,MODE)
 D PASSBAL(ROOT,MODE)
 D PASSCG(ROOT,.OPT,MODE,.CGRES)
 D SUMMARY^EFUX12DIAG(ROOT,.RES)
 S RES("mode")=MODE
 I PROF'="" D
 . S RES("profile")=PROF
 . I $G(CGRES("profile_status"))'="" S RES("profile_status")=$G(CGRES("profile_status")) Q
 . I $G(CGRES("status"))'="" S RES("profile_status")=$G(CGRES("status")) Q
 . S RES("profile_status")=$G(PSTAT)
 Q
 ;
PASSCG(ROOT,OPT,MODE,CGRES) ; optional companion-guide overlay
 K CGRES
 D APPLY^EFU837CG(ROOT,.OPT,MODE,.CGRES)
 Q
 ;
CGPROF(OPT) ; companion profile helper
 I $G(OPT("profile"))'="" Q $$UP^EFU837CG($G(OPT("profile")))
 I $G(OPT("companion_profile"))'="" Q $$UP^EFU837CG($G(OPT("companion_profile")))
 Q ""
 ;
MODE(ROOT,OPT) ; validation mode string helper
 I +$G(OPT("lenient")) Q "lenient"
 I +$G(@ROOT@("meta","lenient")) Q "lenient"
 Q "strict"
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
 . . D ERR^EFUX12DIAG(ROOT,"X12_BAD_AMOUNT","Claim amount is not syntactically valid",.CTX)
 . S LN=0
 . F  S LN=$O(@ROOT@("model","line",CID,LN)) Q:'LN  D
 . . S VAL=$G(@ROOT@("model","line",CID,LN,"charge_amount"))
 . . I VAL'="",'$$OKAMT(VAL) D
 . . . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("loop_id")="2400",CTX("segment_id")=$G(@ROOT@("model","line",CID,LN,"svc_kind")),CTX("raw_value")=VAL
 . . . D ERR^EFUX12DIAG(ROOT,"X12_BAD_AMOUNT","Service line charge amount is not syntactically valid",.CTX)
 . . S QL=""
 . . F  S QL=$O(@ROOT@("model","line",CID,LN,"date",QL)) Q:QL=""  D
 . . . S VAL=$G(@ROOT@("model","line",CID,LN,"date",QL))
 . . . I VAL'="",'$$OKDATE(VAL) D
 . . . . K CTX S CTX("claim_id")=CID,CTX("line_no")=LN,CTX("loop_id")="2400",CTX("segment_id")="DTP",CTX("qual")=QL,CTX("raw_value")=VAL
 . . . . D ERR^EFUX12DIAG(ROOT,"X12_BAD_DATE","Service line date value is not syntactically valid",.CTX)
 Q
 ;
PASSPARTY(ROOT,MODE) ; party/provider sanity
 N TX,CID,SID,PID,BID,CTX,SKEY,PK
 S TX=0
 F  S TX=$O(@ROOT@("model","tx",TX)) Q:'TX  D
 . S BID=$G(@ROOT@("model","tx",TX,"billing_provider_id"))
 . I BID="" D
 . . K CTX S CTX("tx_id")=TX,CTX("loop_id")="2010AA",CTX("segment_id")="NM1"
 . . D EMIT(ROOT,MODE,"X12_BILLING_PROVIDER_MISSING","Billing provider could not be resolved for transaction",.CTX)
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . S SKEY=$G(@ROOT@("model","claim",CID,"subscriber_id"))
 . I SKEY="" D
 . . K CTX S CTX("claim_id")=CID,CTX("loop_id")="2010BA",CTX("segment_id")="NM1"
 . . D EMIT(ROOT,MODE,"X12_SUBSCRIBER_MISSING_PARTY","Subscriber party could not be resolved for claim",.CTX)
 . I SKEY'="" D
 . . I $G(@ROOT@("model","party",SKEY,"id_code"))="" D
 . . . K CTX S CTX("claim_id")=CID,CTX("party_id")=SKEY,CTX("loop_id")="2010BA",CTX("segment_id")="NM1",CTX("element")="NM109"
 . . . D EMIT(ROOT,MODE,"X12_SUBSCRIBER_MISSING_ID","Subscriber id is missing for claim",.CTX)
 . . I $$PNAME(ROOT,SKEY)="" D
 . . . K CTX S CTX("claim_id")=CID,CTX("party_id")=SKEY,CTX("loop_id")="2010BA",CTX("segment_id")="NM1",CTX("element")="NM103"
 . . . D EMIT(ROOT,MODE,"X12_SUBSCRIBER_MISSING_NAME","Subscriber name is missing for claim",.CTX)
 . S PK=$G(@ROOT@("model","claim",CID,"patient_id"))
 . I PK'="",$E(PK,1,8)="patient:" D
 . . I '$D(@ROOT@("model","party",PK)) D
 . . . K CTX S CTX("claim_id")=CID,CTX("party_id")=PK,CTX("loop_id")="2010CA",CTX("segment_id")="NM1"
 . . . D EMIT(ROOT,MODE,"X12_PATIENT_MISSING_PARTY","Distinct patient party could not be resolved for claim",.CTX)
 . . E  D
 . . . I $G(@ROOT@("model","party",PK,"id_code"))="" D
 . . . . K CTX S CTX("claim_id")=CID,CTX("party_id")=PK,CTX("loop_id")="2010CA",CTX("segment_id")="NM1",CTX("element")="NM109"
 . . . . D EMIT(ROOT,MODE,"X12_PATIENT_MISSING_ID","Distinct patient id is missing for claim",.CTX)
 Q
 ;
PASSBAL(ROOT,MODE) ; claim total versus summed service lines
 N CID,LN,CLMAMT,SUM,CTX,TOL
 S TOL=+$$BALTOL^EFU837SPEC("")
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . S CLMAMT=$G(@ROOT@("model","claim",CID,"claim_amount"))
 . I CLMAMT="" Q
 . I '$$OKAMT(CLMAMT) Q
 . S SUM=0,LN=0
 . F  S LN=$O(@ROOT@("model","line",CID,LN)) Q:'LN  D
 . . I $$OKAMT($G(@ROOT@("model","line",CID,LN,"charge_amount"))) S SUM=SUM+$G(@ROOT@("model","line",CID,LN,"charge_amount"))
 . I $$ABS(CLMAMT-SUM)>TOL D
 . . K CTX S CTX("claim_id")=CID,CTX("claim_amount")=CLMAMT,CTX("line_sum")=SUM,CTX("loop_id")="2300",CTX("segment_id")="CLM"
 . . D EMIT(ROOT,MODE,"X12_CLAIM_TOTAL_MISMATCH","Claim total does not match summed service line charges",.CTX)
 Q
 ;
EMIT(ROOT,MODE,CODE,MSG,CTX) ; strict->error, lenient->warning helper
 I $G(MODE)="lenient" D WARN^EFUX12DIAG(ROOT,$G(CODE),$G(MSG),.CTX) Q
 D ERR^EFUX12DIAG(ROOT,$G(CODE),$G(MSG),.CTX)
 Q
 ;
OKDATE(X) ; simple YYYYMMDD syntax check
 N Y,M,D
 S X=+$G(X)
 I $L(X)'=8 Q 0
 S Y=$E(X,1,4),M=$E(X,5,6),D=$E(X,7,8)
 I M<1!(M>12) Q 0
 I D<1!(D>31) Q 0
 Q 1
 ;
OKAMT(X) ; numeric amount check
 I $G(X)?1.N Q 1
 I $G(X)?1"-".N Q 1
 I $G(X)?1.N1"."1.N Q 1
 I $G(X)?1"-"1.N1"."1.N Q 1
 Q 0
 ;
ABS(X) Q $S($G(X)<0:-X,1:+$G(X))
 ;
PNAME(ROOT,SKEY) ; best-effort party display name
 N LN,FN
 S LN=$G(@ROOT@("model","party",SKEY,"last_name"))
 S FN=$G(@ROOT@("model","party",SKEY,"first_name"))
 I LN'="",FN'="" Q LN_", "_FN
 Q LN_FN
 ;
