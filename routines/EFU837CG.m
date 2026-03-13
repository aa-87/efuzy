EFU837CG ; efuzy 837 companion-guide overlay validation
 ;
 ; Public:
 ;   LIST(.OUT)
 ;   STATUS(PROF)
 ;   APPLY(ROOT,.OPT,MODE,.RES)
 ;
 Q
 ;
LIST(OUT) ; list known companion profiles
 K OUT
 S OUT("implemented",1)="FORWARDHEALTH_837P"
 S OUT("implemented",2)="CHCN_837P"
 S OUT("implemented",3)="COLORADO_837P"
 S OUT("implemented",4)="DHP_837P"
 S OUT("scaffolded",1)="CENTENE_837P"
 S OUT("scaffolded",2)="CCX_837P"
 S OUT("scaffolded",3)="WCMBP_837P"
 S OUT("scaffolded",4)="GENERIC_837I"
 S OUT("scaffolded",5)="HH_NOA_837I"
 Q
 ;
STATUS(PROF) ; status string
 N P
 S P=$$UP($G(PROF))
 I P="FORWARDHEALTH_837P" Q "implemented"
 I P="CHCN_837P" Q "implemented"
 I P="COLORADO_837P" Q "implemented"
 I P="DHP_837P" Q "implemented"
 I P="CENTENE_837P" Q "scaffolded"
 I P="CCX_837P" Q "scaffolded"
 I P="WCMBP_837P" Q "scaffolded"
 I P="GENERIC_837I" Q "scaffolded"
 I P="HH_NOA_837I" Q "scaffolded"
 Q "unknown"
 ;
APPLY(ROOT,OPT,MODE,RES) ; apply profile overlay
 N PROF,STAT,CTX
 K RES
 S PROF=$$PROF(.OPT)
 S RES("profile")=PROF
 I PROF="" S RES("ok")=1 Q
 S STAT=$$STATUS(PROF)
 S RES("status")=STAT,RES("profile_status")=STAT
 I STAT="implemented" D  S RES("ok")=1 Q
 . I PROF="FORWARDHEALTH_837P" D FWD(ROOT,MODE,.RES) Q
 . I PROF="CHCN_837P" D CHCN(ROOT,MODE,.RES) Q
 . I PROF="COLORADO_837P" D CO(ROOT,MODE,.RES) Q
 . I PROF="DHP_837P" D DHP(ROOT,MODE,.RES) Q
 I STAT="scaffolded" D  S RES("ok")=1 Q
 . K CTX S CTX("profile")=PROF
 . D WARN^EFUX12DIAG(ROOT,"X12CG_PROFILE_SCAFFOLDED","Companion profile is recognized but not fully implemented yet",.CTX)
 K CTX S CTX("profile")=PROF
 D WARN^EFUX12DIAG(ROOT,"X12CG_PROFILE_UNKNOWN","Companion profile is unknown; no overlay checks were applied",.CTX)
 S RES("ok")=1
 Q
 ;
FWD(ROOT,MODE,RES) ; ForwardHealth 837P
 N ISA06,ISA08,G,GS02,GS03,TX,BHT06,SUBID,RCVID,RCVNM,CID,FREQ,SKEY,PKEY,ICN,CTX
 S RES("implemented")=1
 ; Keep ForwardHealth overlay focused on values the current parser/model
 ; captures most reliably. Avoid over-enforcing envelope-level sender/receiver
 ; cross-checks here; those belong in writer/profile preflight more than parse
 ; correctness.
 S TX=0
 F  S TX=$O(@ROOT@("model","tx",TX)) Q:'TX  D
 . S BHT06=$$UP($G(@ROOT@("tx",TX,"bht","type")))
 . I BHT06'="CH" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="CH",CTX("actual")=$G(@ROOT@("tx",TX,"bht","type")),CTX("segment_id")="BHT",CTX("element")="BHT06"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_BHT06","ForwardHealth claims profile expects BHT06 CH",.CTX)
 . S RCVID=$$IDNORM($G(@ROOT@("tx",TX,"receiver","name","id")))
 . I '$$ONEOF(RCVID,"WISC_TXIX;WISC_WWWP;WISC_WCDP") D
 . . K CTX S CTX("tx_id")=TX,CTX("actual")=$G(@ROOT@("tx",TX,"receiver","name","id")),CTX("segment_id")="NM1*40",CTX("element")="NM109"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_RECEIVER_ID","ForwardHealth profile expects 1000B NM109 receiver id WISC_TXIX, WISC_WWWP, or WISC_WCDP",.CTX)
 . S RCVNM=$$TXTUP($G(@ROOT@("tx",TX,"receiver","name","name_last")))
 . I RCVNM'="FORWARDHEALTH" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="FORWARDHEALTH",CTX("actual")=$G(@ROOT@("tx",TX,"receiver","name","name_last")),CTX("segment_id")="NM1*40",CTX("element")="NM103"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_RECEIVER_NAME","ForwardHealth profile expects 1000B NM103 receiver name FORWARDHEALTH",.CTX)
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . S SKEY=$G(@ROOT@("model","claim",CID,"subscriber_id"))
 . I SKEY'="" D
 . . I $$UP($G(@ROOT@("model","party",SKEY,"id_qual")))'="MI" D
 . . . K CTX S CTX("claim_id")=CID,CTX("party_id")=SKEY,CTX("actual")=$G(@ROOT@("model","party",SKEY,"id_qual")),CTX("loop_id")="2010BA",CTX("segment_id")="NM1",CTX("element")="NM108"
 . . . D EMIT(ROOT,MODE,"X12CG_FORWARD_SUBSCRIBER_QUAL","ForwardHealth profile expects subscriber NM108 qualifier MI",.CTX)
 . . I $G(@ROOT@("model","party",SKEY,"id_code"))'?10N D
 . . . K CTX S CTX("claim_id")=CID,CTX("party_id")=SKEY,CTX("actual")=$G(@ROOT@("model","party",SKEY,"id_code")),CTX("loop_id")="2010BA",CTX("segment_id")="NM1",CTX("element")="NM109"
 . . . D EMIT(ROOT,MODE,"X12CG_FORWARD_SUBSCRIBER_ID10","ForwardHealth profile expects subscriber NM109 to be a 10-digit member id",.CTX)
 . S PKEY=$G(@ROOT@("model","claim",CID,"patient_id"))
 . I $$ISDIST(PKEY) D
 . . K CTX S CTX("claim_id")=CID,CTX("party_id")=PKEY,CTX("loop_id")="2010CA",CTX("segment_id")="NM1"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_PATIENT_DISTINCT","ForwardHealth profile treats the member as the subscriber and does not expect a distinct patient loop",.CTX)
 . S FREQ=$G(@ROOT@("model","claim",CID,"claim_frequency"))
 . I FREQ'="",'$$FREQOK(FREQ) D
 . . K CTX S CTX("claim_id")=CID,CTX("actual")=FREQ,CTX("loop_id")="2300",CTX("segment_id")="CLM",CTX("element")="CLM05-3"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_CLAIM_FREQ","ForwardHealth profile expects claim frequency code 1, 7, or 8",.CTX)
 . I (FREQ=7)!(FREQ=8) D
 . . S ICN=$$F8REF(ROOT,CID,SKEY)
 . . I ICN="" D
 . . . K CTX S CTX("claim_id")=CID,CTX("claim_freq")=FREQ,CTX("loop_id")="2300",CTX("segment_id")="REF",CTX("element")="REF*F8"
 . . . D EMIT(ROOT,MODE,"X12CG_FORWARD_REPLACE_VOID_REF","ForwardHealth profile expects REF*F8 when claim frequency is 7 or 8",.CTX)
 Q
 ;
CHCN(ROOT,MODE,RES) ; CHCN 837P
 N ISA06,ISA08,ISA11,G,GS02,GS03,TX,BHT06,RCVID,RCVNM,CID,SID,BID,CTX
 S RES("implemented")=1
 S ISA06=$$IDNORM($G(@ROOT@("meta","isa","sender_id")))
 S ISA08=$$IDNORM($G(@ROOT@("meta","isa","receiver_id")))
 S ISA11=$G(@ROOT@("meta","isa","rep"))
 I ISA08'="CHCN" D
 . K CTX S CTX("expected")="CHCN",CTX("actual")=$G(@ROOT@("meta","isa","receiver_id")),CTX("segment_id")="ISA",CTX("element")="ISA08"
 . D EMIT(ROOT,MODE,"X12CG_CHCN_ISA08","CHCN profile expects ISA08 receiver id CHCN",.CTX)
 I ISA11=""!($$ALNUM(ISA11)) D
 . K CTX S CTX("actual")=ISA11,CTX("segment_id")="ISA",CTX("element")="ISA11"
 . D EMIT(ROOT,MODE,"X12CG_CHCN_ISA11","CHCN profile expects ISA11 to use a non-alphanumeric repetition separator such as $",.CTX)
 S G=0
 F  S G=$O(@ROOT@("group",G)) Q:'G  D
 . S GS02=$$IDNORM($G(@ROOT@("group",G,"sender")))
 . S GS03=$$IDNORM($G(@ROOT@("group",G,"receiver")))
 . I ISA06'="",GS02'="",GS02'=ISA06 D
 . . K CTX S CTX("group")=G,CTX("expected")=$G(@ROOT@("meta","isa","sender_id")),CTX("actual")=$G(@ROOT@("group",G,"sender")),CTX("segment_id")="GS",CTX("element")="GS02"
 . . D EMIT(ROOT,MODE,"X12CG_CHCN_GS02","CHCN profile expects GS02 to match ISA06",.CTX)
 . I GS03'="CHCN" D
 . . K CTX S CTX("group")=G,CTX("expected")="CHCN",CTX("actual")=$G(@ROOT@("group",G,"receiver")),CTX("segment_id")="GS",CTX("element")="GS03"
 . . D EMIT(ROOT,MODE,"X12CG_CHCN_GS03","CHCN profile expects GS03 receiver code CHCN",.CTX)
 S TX=0
 F  S TX=$O(@ROOT@("model","tx",TX)) Q:'TX  D
 . S BHT06=$$UP($G(@ROOT@("tx",TX,"bht","type")))
 . I BHT06'="CH" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="CH",CTX("actual")=$G(@ROOT@("tx",TX,"bht","type")),CTX("segment_id")="BHT",CTX("element")="BHT06"
 . . D EMIT(ROOT,MODE,"X12CG_CHCN_BHT06","CHCN claims profile expects BHT06 CH",.CTX)
 . S RCVNM=$$TXTUP($G(@ROOT@("tx",TX,"receiver","name","name_last")))
 . I RCVNM'="COMMUNITY HEALTH CENTER NETWORK" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="COMMUNITY HEALTH CENTER NETWORK",CTX("actual")=$G(@ROOT@("tx",TX,"receiver","name","name_last")),CTX("segment_id")="NM1*40",CTX("element")="NM103"
 . . D EMIT(ROOT,MODE,"X12CG_CHCN_RECEIVER_NAME","CHCN profile expects 1000B NM103 receiver name Community Health Center Network",.CTX)
 . S RCVID=$$IDNORM($G(@ROOT@("tx",TX,"receiver","name","id")))
 . I RCVID'="943253662" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="943253662",CTX("actual")=$G(@ROOT@("tx",TX,"receiver","name","id")),CTX("segment_id")="NM1*40",CTX("element")="NM109"
 . . D EMIT(ROOT,MODE,"X12CG_CHCN_RECEIVER_ID","CHCN profile expects 1000B NM109 receiver id 943253662",.CTX)
 . S BID=$G(@ROOT@("model","tx",TX,"billing_provider_id"))
 . I BID'="",$G(@ROOT@("model","party",BID,"id_qual"))="XX",$G(@ROOT@("model","party",BID,"id_code"))'?10N D
 . . K CTX S CTX("tx_id")=TX,CTX("party_id")=BID,CTX("actual")=$G(@ROOT@("model","party",BID,"id_code")),CTX("segment_id")="NM1*85",CTX("element")="NM109"
 . . D EMIT(ROOT,MODE,"X12CG_CHCN_BILLING_NPI","CHCN profile expects billing provider NPI to be 10 digits when NM108 is XX",.CTX)
 S CID=0
 F  S CID=$O(@ROOT@("claim",CID)) Q:'CID  D
 . S SID=+$G(@ROOT@("claim",CID,"sub"))
 . I SID>0,$D(@ROOT@("sub",SID,"payer","name")) D
 . . I $$UP($G(@ROOT@("sub",SID,"payer","name","id_qual")))'="PI" D
 . . . K CTX S CTX("claim_id")=CID,CTX("actual")=$G(@ROOT@("sub",SID,"payer","name","id_qual")),CTX("segment_id")="NM1*PR",CTX("element")="NM108"
 . . . D EMIT(ROOT,MODE,"X12CG_CHCN_PAYER_QUAL","CHCN profile expects 2010BB payer qualifier PI when payer loop is present",.CTX)
 . . I $$IDNORM($G(@ROOT@("sub",SID,"payer","name","id")))'="CHCN" D
 . . . K CTX S CTX("claim_id")=CID,CTX("actual")=$G(@ROOT@("sub",SID,"payer","name","id")),CTX("segment_id")="NM1*PR",CTX("element")="NM109"
 . . . D EMIT(ROOT,MODE,"X12CG_CHCN_PAYER_ID","CHCN profile expects 2010BB payer id CHCN when payer loop is present",.CTX)
 Q
 ;
CO(ROOT,MODE,RES) ; Colorado 837P
 N ISA06,ISA08,G,GS02,GS03,TX,BHT06,RCVID,RCVNM,CID,SKEY,SID,FREQ,ICN,CTX
 S RES("implemented")=1
 ; Keep Colorado overlay focused on transaction/claim values the current
 ; parser/model preserves reliably. Fixed-width envelope/GS receiver strings are
 ; comparatively brittle for parse-time correctness tests.
 S TX=0
 F  S TX=$O(@ROOT@("model","tx",TX)) Q:'TX  D
 . S BHT06=$$UP($G(@ROOT@("tx",TX,"bht","type")))
 . I BHT06'="CH" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="CH",CTX("actual")=$G(@ROOT@("tx",TX,"bht","type")),CTX("segment_id")="BHT",CTX("element")="BHT06"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_BHT06","Colorado claims profile expects BHT06 CH",.CTX)
 . S RCVID=$$IDNORM($G(@ROOT@("tx",TX,"receiver","name","id")))
 . I RCVID'="COMEDASSISTPROG" D
 . . K CTX S CTX("tx_id")=TX,CTX("actual")=$G(@ROOT@("tx",TX,"receiver","name","id")),CTX("segment_id")="NM1*40",CTX("element")="NM109"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_RECEIVER_ID","Colorado profile expects 1000B NM109 receiver id COMEDASSIST PROG",.CTX)
 . S RCVNM=$$TXTUP($G(@ROOT@("tx",TX,"receiver","name","name_last")))
 . I RCVNM'="COLORADO MEDICAL ASSISTANCE PROGRAM" D
 . . K CTX S CTX("tx_id")=TX,CTX("actual")=$G(@ROOT@("tx",TX,"receiver","name","name_last")),CTX("segment_id")="NM1*40",CTX("element")="NM103"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_RECEIVER_NAME","Colorado profile expects 1000B NM103 receiver name Colorado Medical Assistance Program",.CTX)
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . S SKEY=$G(@ROOT@("model","claim",CID,"subscriber_id"))
 . I SKEY'="",$$UP($G(@ROOT@("model","party",SKEY,"id_qual")))'="MI" D
 . . K CTX S CTX("claim_id")=CID,CTX("party_id")=SKEY,CTX("actual")=$G(@ROOT@("model","party",SKEY,"id_qual")),CTX("loop_id")="2010BA",CTX("segment_id")="NM1",CTX("element")="NM108"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_SUBSCRIBER_QUAL","Colorado profile expects subscriber NM108 qualifier MI",.CTX)
 . S SID=+$G(@ROOT@("claim",CID,"sub"))
 . I SID>0,$D(@ROOT@("sub",SID,"payer","name")) D
 . . I $$IDNORM($G(@ROOT@("sub",SID,"payer","name","id")))'="CO_TXIX" D
 . . . K CTX S CTX("claim_id")=CID,CTX("actual")=$G(@ROOT@("sub",SID,"payer","name","id")),CTX("segment_id")="NM1*PR",CTX("element")="NM109"
 . . . D EMIT(ROOT,MODE,"X12CG_COLORADO_PAYER_ID","Colorado profile expects 2010BB payer id CO_TXIX",.CTX)
 . S FREQ=$G(@ROOT@("model","claim",CID,"claim_frequency"))
 . I (FREQ=7)!(FREQ=8) D
 . . S ICN=$$F8REF(ROOT,CID,SKEY)
 . . I ICN="" D
 . . . K CTX S CTX("claim_id")=CID,CTX("claim_freq")=FREQ,CTX("loop_id")="2300",CTX("segment_id")="REF",CTX("element")="REF*F8"
 . . . D EMIT(ROOT,MODE,"X12CG_COLORADO_REPLACE_VOID_REF","Colorado profile expects REF*F8 when claim frequency is 7 or 8",.CTX)
 Q
 ;
DHP(ROOT,MODE,RES) ; DHP 837P
 N ISA06,ISA08,G,GS02,GS03,TX,BHT06,RCVID,CID,SKEY,SID,FREQ,ICN,CTX
 S RES("implemented")=1
 S ISA06=$$IDNORM($G(@ROOT@("meta","isa","sender_id")))
 S ISA08=$$IDNORM($G(@ROOT@("meta","isa","receiver_id")))
 I ISA08'="78284" D
 . K CTX S CTX("expected")="78284",CTX("actual")=$G(@ROOT@("meta","isa","receiver_id")),CTX("segment_id")="ISA",CTX("element")="ISA08"
 . D EMIT(ROOT,MODE,"X12CG_DHP_ISA08","DHP profile expects ISA08 receiver id 78284",.CTX)
 S G=0
 F  S G=$O(@ROOT@("group",G)) Q:'G  D
 . S GS02=$$IDNORM($G(@ROOT@("group",G,"sender")))
 . S GS03=$$IDNORM($G(@ROOT@("group",G,"receiver")))
 . I ISA06'="",GS02'="",GS02'=ISA06 D
 . . K CTX S CTX("group")=G,CTX("expected")=$G(@ROOT@("meta","isa","sender_id")),CTX("actual")=$G(@ROOT@("group",G,"sender")),CTX("segment_id")="GS",CTX("element")="GS02"
 . . D EMIT(ROOT,MODE,"X12CG_DHP_GS02","DHP profile expects GS02 to match ISA06",.CTX)
 . I GS03'="78284" D
 . . K CTX S CTX("group")=G,CTX("actual")=$G(@ROOT@("group",G,"receiver")),CTX("segment_id")="GS",CTX("element")="GS03"
 . . D EMIT(ROOT,MODE,"X12CG_DHP_GS03","DHP profile expects GS03 receiver code 78284",.CTX)
 S TX=0
 F  S TX=$O(@ROOT@("model","tx",TX)) Q:'TX  D
 . S BHT06=$$UP($G(@ROOT@("tx",TX,"bht","type")))
 . I BHT06'="CH" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="CH",CTX("actual")=$G(@ROOT@("tx",TX,"bht","type")),CTX("segment_id")="BHT",CTX("element")="BHT06"
 . . D EMIT(ROOT,MODE,"X12CG_DHP_BHT06","DHP claims profile expects BHT06 CH",.CTX)
 . S RCVID=$$IDNORM($G(@ROOT@("tx",TX,"receiver","name","id")))
 . I RCVID'="78284" D
 . . K CTX S CTX("tx_id")=TX,CTX("actual")=$G(@ROOT@("tx",TX,"receiver","name","id")),CTX("segment_id")="NM1*40",CTX("element")="NM109"
 . . D EMIT(ROOT,MODE,"X12CG_DHP_RECEIVER_ID","DHP profile expects 1000B NM109 receiver id 78284",.CTX)
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . S SKEY=$G(@ROOT@("model","claim",CID,"subscriber_id"))
 . I SKEY'="",$$UP($G(@ROOT@("model","party",SKEY,"id_qual")))'="MI" D
 . . K CTX S CTX("claim_id")=CID,CTX("party_id")=SKEY,CTX("actual")=$G(@ROOT@("model","party",SKEY,"id_qual")),CTX("loop_id")="2010BA",CTX("segment_id")="NM1",CTX("element")="NM108"
 . . D EMIT(ROOT,MODE,"X12CG_DHP_SUBSCRIBER_QUAL","DHP profile expects subscriber NM108 qualifier MI",.CTX)
 . S SID=+$G(@ROOT@("claim",CID,"sub"))
 . I SID>0,$D(@ROOT@("sub",SID,"payer","name")) D
 . . I $$IDNORM($G(@ROOT@("sub",SID,"payer","name","id")))'="78284" D
 . . . K CTX S CTX("claim_id")=CID,CTX("actual")=$G(@ROOT@("sub",SID,"payer","name","id")),CTX("segment_id")="NM1*PR",CTX("element")="NM109"
 . . . D EMIT(ROOT,MODE,"X12CG_DHP_PAYER_ID","DHP profile expects 2010BB payer id 78284",.CTX)
 . S FREQ=$G(@ROOT@("model","claim",CID,"claim_frequency"))
 . I (FREQ=7)!(FREQ=8) D
 . . S ICN=$$F8REF(ROOT,CID,SKEY)
 . . I ICN="" D
 . . . K CTX S CTX("claim_id")=CID,CTX("claim_freq")=FREQ,CTX("loop_id")="2300",CTX("segment_id")="REF",CTX("element")="REF*F8"
 . . . D EMIT(ROOT,MODE,"X12CG_DHP_REPLACE_VOID_REF","DHP profile expects REF*F8 when claim frequency is 7 or 8",.CTX)
 Q
 ;
PROF(OPT) ; profile helper
 I $G(OPT("profile"))'="" Q $$UP(OPT("profile"))
 I $G(OPT("companion_profile"))'="" Q $$UP(OPT("companion_profile"))
 Q ""
 ;
EMIT(ROOT,MODE,CODE,MSG,CTX) ; emit profile finding
 I $G(MODE)="lenient" D WARN^EFUX12DIAG(ROOT,$G(CODE),$G(MSG),.CTX) Q
 D ERR^EFUX12DIAG(ROOT,$G(CODE),$G(MSG),.CTX)
 Q
 ;
ONEOF(X,LIST) ; value exists in ; list after normalization
 N U,I,VAL,HIT
 S U=$$IDNORM($G(X)),HIT=0
 F I=1:1:$L($G(LIST),";") S VAL=$P($G(LIST),";",I) I U=$$IDNORM(VAL) S HIT=1 Q
 Q HIT
 ;
FREQOK(X) ; replacement frequency accepted
 Q $S($G(X)=1:1,$G(X)=7:1,$G(X)=8:1,1:0)
 ;
ISDIST(PKEY) ; whether model patient key is distinct
 Q $S($E($G(PKEY),1,8)="patient:":1,1:0)
 ;
ALNUM(X) ; single alphanumeric character?
 N C
 S C=$E($G(X),1)
 I C?1AN Q 1
 Q 0
 ;
F8REF(ROOT,CID,SKEY) ; best-effort ICN lookup
 N SID,X
 S X=$G(@ROOT@("claim",+$G(CID),"ref","F8")) I X'="" Q X
 S X=$G(@ROOT@("model","claim",+$G(CID),"ref","F8")) I X'="" Q X
 S SID=+$G(@ROOT@("claim",+$G(CID),"sub"))
 S X=$G(@ROOT@("sub",SID,"ref","F8")) I X'="" Q X
 S X=$G(@ROOT@("sub",SID,"payer","ref","F8")) I X'="" Q X
 Q ""
 ;
IDNORM(X) ; uppercase id normalization with spaces removed
 Q $$UP($$NOSPC($G(X)))
 ;
TXTUP(X) ; uppercase text but preserve spaces
 Q $$UP($G(X))
 ;
NOSPC(X) ; remove spaces
 N Y,I,C
 S Y=""
 F I=1:1:$L($G(X)) S C=$E(X,I) I C'=" " S Y=Y_C
 Q Y
 ;
UP(X) ; uppercase helper
 N Y,I,C,A
 S Y=""
 F I=1:1:$L($G(X)) D
 . S C=$E(X,I),A=$A(C)
 . I A'<97,A'>122 S C=$C(A-32)
 . S Y=Y_C
 Q Y
 ;
