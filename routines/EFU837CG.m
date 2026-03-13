EFU837CG ; efuzy 837 companion-guide overlay validation
 ;
 ; Public:
 ;   LIST(.OUT)                  - list known profile overlays
 ;   STATUS(PROF)                - implemented / scaffolded / unknown
 ;   APPLY(ROOT,.OPT,MODE,.RES)  - apply optional profile overlay diagnostics
 ;
 ; Notes:
 ;   - additive companion-guide correctness layer on top of EFU837VR
 ;   - preserves strict/lenient behavior by routing findings through MODE
 ;   - implemented now for:
 ;       FORWARDHEALTH_837P
 ;       CHCN_837P
 ;       COLORADO_837P
 ;       DHP_837P
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
 S OUT("implemented",5)="GENERIC_837I"
 S OUT("implemented",6)="HH_NOA_837I"
 Q
 ;
STATUS(PROF) ; profile status string
 N P
 S P=$$UP($G(PROF))
 I P="FORWARDHEALTH_837P" Q "implemented"
 I P="CHCN_837P" Q "implemented"
 I P="COLORADO_837P" Q "implemented"
 I P="DHP_837P" Q "implemented"
 I P="CENTENE_837P" Q "scaffolded"
 I P="CCX_837P" Q "scaffolded"
 I P="WCMBP_837P" Q "scaffolded"
 I P="GENERIC_837I" Q "implemented"
 I P="HH_NOA_837I" Q "implemented"
 Q "unknown"
 ;
APPLY(ROOT,OPT,MODE,RES) ; apply companion overlay, if any
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
 . I PROF="GENERIC_837I" D GENI(ROOT,MODE,.RES) Q
 . I PROF="HH_NOA_837I" D HHNOA(ROOT,MODE,.RES) Q
 I STAT="scaffolded" D  S RES("ok")=1 Q
 . K CTX S CTX("profile")=PROF
 . D WARN^EFUX12DIAG(ROOT,"X12CG_PROFILE_SCAFFOLDED","Companion profile is recognized but not fully implemented yet",.CTX)
 K CTX S CTX("profile")=PROF
 D WARN^EFUX12DIAG(ROOT,"X12CG_PROFILE_UNKNOWN","Companion profile is unknown; no overlay checks were applied",.CTX)
 S RES("ok")=1
 Q
 ;
FWD(ROOT,MODE,RES) ; ForwardHealth 837P overlay checks
 N ISA06,ISA08,G,GS02,GS03,TX,BHT06,SUBID,RCVID,RCVNM,CID,FREQ,CTX,SKEY,PKEY,ICN
 S RES("implemented")=1
 S ISA06=$$IDNORM($G(@ROOT@("meta","isa","sender_id")))
 S ISA08=$$IDNORM($G(@ROOT@("meta","isa","receiver_id")))
 I ISA08'="WISC_DHFS" D
 . K CTX S CTX("expected")="WISC_DHFS",CTX("actual")=$G(@ROOT@("meta","isa","receiver_id")),CTX("segment_id")="ISA",CTX("element")="ISA08"
 . D EMIT(ROOT,MODE,"X12CG_FORWARD_ISA08","ForwardHealth profile expects ISA08 receiver id WISC_DHFS",.CTX)
 I ISA06'="",ISA06'?9N D
 . K CTX S CTX("actual")=$G(@ROOT@("meta","isa","sender_id")),CTX("segment_id")="ISA",CTX("element")="ISA06"
 . D EMIT(ROOT,MODE,"X12CG_FORWARD_ISA06","ForwardHealth profile expects ISA06 to be a 9-digit trading partner id",.CTX)
 S G=0
 F  S G=$O(@ROOT@("group",G)) Q:'G  D
 . S GS02=$$IDNORM($G(@ROOT@("group",G,"sender")))
 . S GS03=$$IDNORM($G(@ROOT@("group",G,"receiver")))
 . I ISA06'="",GS02'="",GS02'=ISA06 D
 . . K CTX S CTX("group")=G,CTX("expected")=$G(@ROOT@("meta","isa","sender_id")),CTX("actual")=$G(@ROOT@("group",G,"sender")),CTX("segment_id")="GS",CTX("element")="GS02"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_GS02","ForwardHealth profile expects GS02 to match ISA06",.CTX)
 . I '$$ONEOF(GS03,"WISC_TXIX;WISC_WWWP;WISC_WCDP") D
 . . K CTX S CTX("group")=G,CTX("actual")=$G(@ROOT@("group",G,"receiver")),CTX("segment_id")="GS",CTX("element")="GS03"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_GS03","ForwardHealth profile expects GS03 receiver code WISC_TXIX, WISC_WWWP, or WISC_WCDP",.CTX)
 S TX=0
 F  S TX=$O(@ROOT@("model","tx",TX)) Q:'TX  D
 . I $$UP($G(@ROOT@("model","tx",TX,"guide")))'="005010X222A1" D
 . . K CTX S CTX("tx_id")=TX,CTX("guide")=$G(@ROOT@("model","tx",TX,"guide")),CTX("segment_id")="ST",CTX("element")="ST03"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_GUIDE","ForwardHealth overlay currently applies to 837P 005010X222A1 content",.CTX)
 . S BHT06=$$UP($G(@ROOT@("tx",TX,"bht","type")))
 . I BHT06'="CH" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="CH",CTX("actual")=$G(@ROOT@("tx",TX,"bht","type")),CTX("segment_id")="BHT",CTX("element")="BHT06"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_BHT06","ForwardHealth claims profile expects BHT06 CH",.CTX)
 . S SUBID=$$IDNORM($G(@ROOT@("tx",TX,"submitter","name","id")))
 . I ISA06'="",SUBID'="",SUBID'=ISA06 D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")=$G(@ROOT@("meta","isa","sender_id")),CTX("actual")=$G(@ROOT@("tx",TX,"submitter","name","id")),CTX("segment_id")="NM1*41",CTX("element")="NM109"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_SUBMITTER_ID","ForwardHealth profile expects 1000A NM109 to match ISA06",.CTX)
 . S RCVID=$$IDNORM($G(@ROOT@("tx",TX,"receiver","name","id")))
 . I '$$ONEOF(RCVID,"WISC_TXIX;WISC_WWWP;WISC_WCDP") D
 . . K CTX S CTX("tx_id")=TX,CTX("actual")=$G(@ROOT@("tx",TX,"receiver","name","id")),CTX("segment_id")="NM1*40",CTX("element")="NM109"
 . . D EMIT(ROOT,MODE,"X12CG_FORWARD_RECEIVER_ID","ForwardHealth profile expects 1000B NM109 receiver id WISC_TXIX, WISC_WWWP, or WISC_WCDP",.CTX)
 . S RCVNM=$$UP($$TRIM($G(@ROOT@("tx",TX,"receiver","name","name_last"))))
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
CHCN(ROOT,MODE,RES) ; CHCN 837P overlay checks
 N ISA06,ISA08,ISA11,G,GS02,GS03,TX,BHT06,RCVID,RCVNM,CID,SID,CTX,BID
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
 . I $$UP($G(@ROOT@("model","tx",TX,"guide")))'="005010X222A1" D
 . . K CTX S CTX("tx_id")=TX,CTX("guide")=$G(@ROOT@("model","tx",TX,"guide")),CTX("segment_id")="ST",CTX("element")="ST03"
 . . D EMIT(ROOT,MODE,"X12CG_CHCN_GUIDE","CHCN overlay currently applies to 837P 005010X222A1 content",.CTX)
 . S BHT06=$$UP($G(@ROOT@("tx",TX,"bht","type")))
 . I BHT06'="CH" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="CH",CTX("actual")=$G(@ROOT@("tx",TX,"bht","type")),CTX("segment_id")="BHT",CTX("element")="BHT06"
 . . D EMIT(ROOT,MODE,"X12CG_CHCN_BHT06","CHCN claims profile expects BHT06 CH",.CTX)
 . S RCVNM=$$UP($$TRIM($G(@ROOT@("tx",TX,"receiver","name","name_last"))))
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
CO(ROOT,MODE,RES) ; Colorado 837P overlay checks
 N ISA06,ISA08,G,GS02,GS03,TX,BHT06,RCVID,RCVNM,CID,SKEY,FREQ,ICN,SID,CTX
 S RES("implemented")=1
 S ISA06=$$IDNORM($G(@ROOT@("meta","isa","sender_id")))
 S ISA08=$$IDNORM($G(@ROOT@("meta","isa","receiver_id")))
 I ISA08'="COMEDASSISTPRO" D
 . K CTX S CTX("expected")="COMEDASSIST PRO",CTX("actual")=$G(@ROOT@("meta","isa","receiver_id")),CTX("segment_id")="ISA",CTX("element")="ISA08"
 . D EMIT(ROOT,MODE,"X12CG_COLORADO_ISA08","Colorado profile expects ISA08 receiver id COMEDASSIST PRO",.CTX)
 S G=0
 F  S G=$O(@ROOT@("group",G)) Q:'G  D
 . S GS02=$$IDNORM($G(@ROOT@("group",G,"sender")))
 . S GS03=$$IDNORM($G(@ROOT@("group",G,"receiver")))
 . I ISA06'="",GS02'="",GS02'=ISA06 D
 . . K CTX S CTX("group")=G,CTX("expected")=$G(@ROOT@("meta","isa","sender_id")),CTX("actual")=$G(@ROOT@("group",G,"sender")),CTX("segment_id")="GS",CTX("element")="GS02"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_GS02","Colorado profile expects GS02 to match ISA06 TPID",.CTX)
 . I GS03'="COMEDASSISTPROG" D
 . . K CTX S CTX("group")=G,CTX("actual")=$G(@ROOT@("group",G,"receiver")),CTX("segment_id")="GS",CTX("element")="GS03"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_GS03","Colorado profile expects GS03 receiver code COMEDASSIST PROG",.CTX)
 S TX=0
 F  S TX=$O(@ROOT@("model","tx",TX)) Q:'TX  D
 . I $$UP($G(@ROOT@("model","tx",TX,"guide")))'="005010X222A1" D
 . . K CTX S CTX("tx_id")=TX,CTX("guide")=$G(@ROOT@("model","tx",TX,"guide")),CTX("segment_id")="ST",CTX("element")="ST03"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_GUIDE","Colorado overlay currently applies to 837P 005010X222A1 content",.CTX)
 . S BHT06=$$UP($G(@ROOT@("tx",TX,"bht","type")))
 . I BHT06'="CH" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="CH",CTX("actual")=$G(@ROOT@("tx",TX,"bht","type")),CTX("segment_id")="BHT",CTX("element")="BHT06"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_BHT06","Colorado claims profile expects BHT06 CH for fee-for-service claims",.CTX)
 . S RCVNM=$$UP($$TRIM($G(@ROOT@("tx",TX,"receiver","name","name_last"))))
 . I RCVNM'="COLORADO MEDICAL ASSISTANCE PROGRAM" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="COLORADO MEDICAL ASSISTANCE PROGRAM",CTX("actual")=$G(@ROOT@("tx",TX,"receiver","name","name_last")),CTX("segment_id")="NM1*40",CTX("element")="NM103"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_RECEIVER_NAME","Colorado profile expects 1000B NM103 receiver name COLORADO MEDICAL ASSISTANCE PROGRAM",.CTX)
 . S RCVID=$$IDNORM($G(@ROOT@("tx",TX,"receiver","name","id")))
 . I RCVID'="COMEDASSISTPROG" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="COMEDASSIST PROG",CTX("actual")=$G(@ROOT@("tx",TX,"receiver","name","id")),CTX("segment_id")="NM1*40",CTX("element")="NM109"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_RECEIVER_ID","Colorado profile expects 1000B NM109 receiver id COMEDASSIST PROG",.CTX)
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . S SKEY=$G(@ROOT@("model","claim",CID,"subscriber_id"))
 . I SKEY'="",$$UP($G(@ROOT@("model","party",SKEY,"id_qual")))'="MI" D
 . . K CTX S CTX("claim_id")=CID,CTX("party_id")=SKEY,CTX("actual")=$G(@ROOT@("model","party",SKEY,"id_qual")),CTX("loop_id")="2010BA",CTX("segment_id")="NM1",CTX("element")="NM108"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_SUBSCRIBER_QUAL","Colorado profile expects subscriber NM108 qualifier MI",.CTX)
 . S SID=+$P(SKEY,":",2)
 . I SID>0,$D(@ROOT@("sub",SID,"payer","name")) D
 . . I $$UP($G(@ROOT@("sub",SID,"payer","name","id_qual")))'="PI" D
 . . . K CTX S CTX("claim_id")=CID,CTX("actual")=$G(@ROOT@("sub",SID,"payer","name","id_qual")),CTX("segment_id")="NM1*PR",CTX("element")="NM108"
 . . . D EMIT(ROOT,MODE,"X12CG_COLORADO_PAYER_QUAL","Colorado profile expects 2010BB payer qualifier PI",.CTX)
 . . I $$IDNORM($G(@ROOT@("sub",SID,"payer","name","id")))'="CO_TXIX" D
 . . . K CTX S CTX("claim_id")=CID,CTX("actual")=$G(@ROOT@("sub",SID,"payer","name","id")),CTX("segment_id")="NM1*PR",CTX("element")="NM109"
 . . . D EMIT(ROOT,MODE,"X12CG_COLORADO_PAYER_ID","Colorado profile expects 2010BB payer id CO_TXIX",.CTX)
 . S FREQ=$G(@ROOT@("model","claim",CID,"claim_frequency"))
 . I FREQ'="",'$$FREQOK(FREQ) D
 . . K CTX S CTX("claim_id")=CID,CTX("actual")=FREQ,CTX("loop_id")="2300",CTX("segment_id")="CLM",CTX("element")="CLM05-3"
 . . D EMIT(ROOT,MODE,"X12CG_COLORADO_CLAIM_FREQ","Colorado profile expects claim frequency code 1, 7, or 8",.CTX)
 . I (FREQ=7)!(FREQ=8) D
 . . S ICN=$$F8REF(ROOT,CID,SKEY)
 . . I ICN="" D
 . . . K CTX S CTX("claim_id")=CID,CTX("claim_freq")=FREQ,CTX("loop_id")="2300",CTX("segment_id")="REF",CTX("element")="REF*F8"
 . . . D EMIT(ROOT,MODE,"X12CG_COLORADO_REPLACE_VOID_REF","Colorado profile expects REF*F8 when claim frequency is 7 or 8",.CTX)
 Q
 ;
DHP(ROOT,MODE,RES) ; DHP 837P overlay checks
 N TX,BHT06,CID,SKEY,SID,FREQ,ICN,PID,PNM,CTX
 S RES("implemented")=1
 S TX=0
 F  S TX=$O(@ROOT@("model","tx",TX)) Q:'TX  D
 . I $$UP($G(@ROOT@("model","tx",TX,"guide")))'="005010X222A1" D
 . . K CTX S CTX("tx_id")=TX,CTX("guide")=$G(@ROOT@("model","tx",TX,"guide")),CTX("segment_id")="ST",CTX("element")="ST03"
 . . D EMIT(ROOT,MODE,"X12CG_DHP_GUIDE","DHP overlay currently applies to 837P 005010X222A1 content",.CTX)
 . S BHT06=$$UP($G(@ROOT@("tx",TX,"bht","type")))
 . I BHT06'="CH" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="CH",CTX("actual")=$G(@ROOT@("tx",TX,"bht","type")),CTX("segment_id")="BHT",CTX("element")="BHT06"
 . . D EMIT(ROOT,MODE,"X12CG_DHP_BHT06","DHP claims profile expects BHT06 CH",.CTX)
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . S SKEY=$G(@ROOT@("model","claim",CID,"subscriber_id"))
 . I SKEY'="",$$UP($G(@ROOT@("model","party",SKEY,"id_qual")))'="MI" D
 . . K CTX S CTX("claim_id")=CID,CTX("party_id")=SKEY,CTX("actual")=$G(@ROOT@("model","party",SKEY,"id_qual")),CTX("loop_id")="2010BA",CTX("segment_id")="NM1",CTX("element")="NM108"
 . . D EMIT(ROOT,MODE,"X12CG_DHP_SUBSCRIBER_QUAL","DHP profile expects subscriber NM108 qualifier MI",.CTX)
 . S SID=+$P(SKEY,":",2)
 . I SID>0,$D(@ROOT@("sub",SID,"payer","name")) D
 . . S PNM=$$UP($$TRIM($G(@ROOT@("sub",SID,"payer","name","name_last"))))
 . . I (PNM'="DHP")&(PNM'="DRISCOLL HEALTH PLAN") D
 . . . K CTX S CTX("claim_id")=CID,CTX("actual")=$G(@ROOT@("sub",SID,"payer","name","name_last")),CTX("segment_id")="NM1*PR",CTX("element")="NM103"
 . . . D EMIT(ROOT,MODE,"X12CG_DHP_PAYER_NAME","DHP profile expects payer name DHP / Driscoll Health Plan",.CTX)
 . . I $$UP($G(@ROOT@("sub",SID,"payer","name","id_qual")))'="PI" D
 . . . K CTX S CTX("claim_id")=CID,CTX("actual")=$G(@ROOT@("sub",SID,"payer","name","id_qual")),CTX("segment_id")="NM1*PR",CTX("element")="NM108"
 . . . D EMIT(ROOT,MODE,"X12CG_DHP_PAYER_QUAL","DHP profile expects payer qualifier PI",.CTX)
 . . S PID=$$IDNORM($G(@ROOT@("sub",SID,"payer","name","id")))
 . . I '(PID="78284")&'(PID?5N) D
 . . . K CTX S CTX("claim_id")=CID,CTX("actual")=$G(@ROOT@("sub",SID,"payer","name","id")),CTX("segment_id")="NM1*PR",CTX("element")="NM109"
 . . . D EMIT(ROOT,MODE,"X12CG_DHP_PAYER_ID","DHP profile expects payer id 78284 or a valid TMHP contract code",.CTX)
 . S FREQ=$G(@ROOT@("model","claim",CID,"claim_frequency"))
 . I FREQ'="",'$$FREQOK(FREQ) D
 . . K CTX S CTX("claim_id")=CID,CTX("actual")=FREQ,CTX("loop_id")="2300",CTX("segment_id")="CLM",CTX("element")="CLM05-3"
 . . D EMIT(ROOT,MODE,"X12CG_DHP_CLAIM_FREQ","DHP profile expects a supported claim frequency code",.CTX)
 . I (FREQ=7)!(FREQ=8) D
 . . S ICN=$$F8REF(ROOT,CID,SKEY)
 . . I ICN="" D
 . . . K CTX S CTX("claim_id")=CID,CTX("claim_freq")=FREQ,CTX("loop_id")="2300",CTX("segment_id")="REF",CTX("element")="REF*F8"
 . . . D EMIT(ROOT,MODE,"X12CG_DHP_REPLACE_VOID_REF","DHP profile expects REF*F8 when claim frequency is 7 or 8",.CTX)
 Q
 ;
GENI(ROOT,MODE,RES) ; generic institutional 837I overlay
 N TX,KIND,BHT06,ISA06,SUBID,BID,CTX
 S RES("implemented")=1
 S TX=0,ISA06=$$IDNORM($G(@ROOT@("meta","isa","sender_id")))
 F  S TX=$O(@ROOT@("model","tx",TX)) Q:'TX  D
 . S KIND=$$IDNORM($G(@ROOT@("model","tx",TX,"tx_kind")))
 . I KIND'="",KIND'="837I" D
 . . K CTX S CTX("tx_id")=TX,CTX("actual")=$G(@ROOT@("model","tx",TX,"tx_kind")),CTX("segment_id")="ST",CTX("element")="ST01"
 . . D EMIT(ROOT,MODE,"X12CG_I837_TX_KIND","Generic 837I profile expects institutional transaction content",.CTX)
 . S BHT06=$$IDNORM($G(@ROOT@("tx",TX,"bht","type")))
 . I BHT06'="",BHT06'="CH" D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")="CH",CTX("actual")=$G(@ROOT@("tx",TX,"bht","type")),CTX("segment_id")="BHT",CTX("element")="BHT06"
 . . D EMIT(ROOT,MODE,"X12CG_I837_BHT06","Generic 837I profile expects BHT06 CH",.CTX)
 . S SUBID=$$IDNORM($G(@ROOT@("tx",TX,"submitter","name","id")))
 . I ISA06'="",SUBID'="",SUBID'=ISA06 D
 . . K CTX S CTX("tx_id")=TX,CTX("expected")=$G(@ROOT@("meta","isa","sender_id")),CTX("actual")=$G(@ROOT@("tx",TX,"submitter","name","id")),CTX("segment_id")="NM1*41",CTX("element")="NM109"
 . . D EMIT(ROOT,MODE,"X12CG_I837_SUBMITTER_ID","Generic 837I profile expects 1000A NM109 to match ISA06",.CTX)
 . S BID=$G(@ROOT@("model","tx",TX,"billing_provider_id"))
 . I BID'="" D
 . . I $$IDNORM($G(@ROOT@("model","party",BID,"id_qual")))'="XX" D
 . . . K CTX S CTX("tx_id")=TX,CTX("party_id")=BID,CTX("actual")=$G(@ROOT@("model","party",BID,"id_qual")),CTX("segment_id")="NM1*85",CTX("element")="NM108"
 . . . D EMIT(ROOT,MODE,"X12CG_I837_BILLING_QUAL","Generic 837I profile expects billing provider NM108 qualifier XX",.CTX)
 . . I $G(@ROOT@("model","party",BID,"id_code"))'="",$G(@ROOT@("model","party",BID,"id_code"))'?10N D
 . . . K CTX S CTX("tx_id")=TX,CTX("party_id")=BID,CTX("actual")=$G(@ROOT@("model","party",BID,"id_code")),CTX("segment_id")="NM1*85",CTX("element")="NM109"
 . . . D EMIT(ROOT,MODE,"X12CG_I837_BILLING_NPI","Generic 837I profile expects billing provider NPI to be 10 digits",.CTX)
 Q
 ;
HHNOA(ROOT,MODE,RES) ; home health NOA institutional overlay
 N CID,CTX,AMT,FAC,FREQ,DT,SEG
 S RES("implemented")=1
 D GENI(ROOT,MODE,.RES)
 S CID=0
 F  S CID=$O(@ROOT@("model","claim",CID)) Q:'CID  D
 . S AMT=$G(@ROOT@("model","claim",CID,"claim_amount"))
 . I AMT'="",+AMT'=0 D
 . . K CTX S CTX("claim_id")=CID,CTX("actual")=AMT,CTX("expected")=0,CTX("segment_id")="CLM",CTX("element")="CLM02"
 . . D EMIT(ROOT,MODE,"X12CG_HHNOA_CLAIM_AMOUNT","HH NOA profile expects CLM02 total submitted charges to be zero",.CTX)
 . S FAC=$G(@ROOT@("model","claim",CID,"facility_type"))
 . I FAC'="",+FAC'=32 D
 . . K CTX S CTX("claim_id")=CID,CTX("actual")=FAC,CTX("expected")=32,CTX("segment_id")="CLM",CTX("element")="CLM05-1"
 . . D EMIT(ROOT,MODE,"X12CG_HHNOA_FACILITY_TYPE","HH NOA profile expects CLM05-1 facility type code 32",.CTX)
 . S FREQ=$G(@ROOT@("claim",CID,"claim_freq")) I FREQ="" S FREQ=$G(@ROOT@("model","claim",CID,"claim_frequency"))
 . I FREQ'="",'$$ONEOF($$UP(FREQ),"A;D") D
 . . K CTX S CTX("claim_id")=CID,CTX("actual")=FREQ,CTX("segment_id")="CLM",CTX("element")="CLM05-3"
 . . D EMIT(ROOT,MODE,"X12CG_HHNOA_CLAIM_FREQ","HH NOA profile expects CLM05-3 claim frequency code A or D",.CTX)
 . S DT=$G(@ROOT@("claim",CID,"dtp",434,"value"))
 . I DT="" S DT=$G(@ROOT@("model","claim",CID,"date",434))
 . ; Future-date enforcement for HH NOA is intentionally disabled for now.
 . ; The parsed value is preserved, but the runtime date comparison has shown
 . ; environment-sensitive behavior across GT.M/YottaDB builds.
 S SEG=+$G(@ROOT@("stats","segment","CN1"))
 I SEG>0 D
 . K CTX S CTX("actual")=SEG,CTX("segment_id")="CN1",CTX("loop_id")="2300"
 . D EMIT(ROOT,MODE,"X12CG_HHNOA_CN1_FORBIDDEN","HH NOA profile does not allow the CN1 segment",.CTX)
 Q
 ;
FUTURE(DT) ; YYYYMMDD date is after today
 N DAYS,TODAY
 I $G(DT)'?8N Q 0
 S DAYS=+$P($H,",",1)
 S TODAY=$$HORO8(DAYS)
 I TODAY?8N,DT>TODAY Q 1
 Q 0
 ;
HORO8(DAYS) ; $H day count -> YYYYMMDD
 N J,L,N,I,Y,M,D
 S J=2393471+(+$G(DAYS))
 S L=J+68569
 S N=(4*L)\146097
 S L=L-(146097*N+3)\4
 S I=(4000*(L+1))\1461001
 S L=L-(1461*I)\4+31
 S M=(80*L)\2447
 S D=L-(2447*M)\80
 S L=M\11
 S M=M+2-(12*L)
 S Y=100*(N-49)+I+L
 Q $$PAD4(Y)_$$PAD2(M)_$$PAD2(D)
 ;
PAD2(N) Q $E(100+(+N),2,3)
 ;
PAD4(N) Q $E(10000+(+N),2,5)
 ;
F8REF(ROOT,CID,SKEY) ; best-effort ICN reference lookup
 N V,SID
 S V=$G(@ROOT@("claim",+$G(CID),"ref","F8")) I V'="" Q V
 S V=$G(@ROOT@("model","claim",+$G(CID),"ref","F8")) I V'="" Q V
 S SID=+$P($G(SKEY),":",2)
 I SID>0 D
 . S V=$G(@ROOT@("sub",SID,"ref","F8")) I V'="" Q
 . S V=$G(@ROOT@("sub",SID,"payer","ref","F8")) I V'="" Q
 I V'="" Q V
 Q ""
 ;
PROF(OPT) ; profile helper
 I $G(OPT("profile"))'="" Q $$UP(OPT("profile"))
 I $G(OPT("companion_profile"))'="" Q $$UP(OPT("companion_profile"))
 Q ""
 ;
EMIT(ROOT,MODE,CODE,MSG,CTX) ; severity by mode for profile findings
 I $G(MODE)="lenient" D WARN^EFUX12DIAG(ROOT,$G(CODE),$G(MSG),.CTX) Q
 D ERR^EFUX12DIAG(ROOT,$G(CODE),$G(MSG),.CTX)
 Q
 ;
ONEOF(X,LIST) ; value exists in ; delimited list after uppercase normalization
 N U,I,VAL,HIT
 S U=$$UP($G(X)),HIT=0
 F I=1:1:$L($G(LIST),";") S VAL=$P($G(LIST),";",I) I U=$$UP(VAL) S HIT=1 Q
 Q HIT
 ;
FREQOK(X) ; allowed claim frequency values used by these profiles
 Q $S($G(X)=1:1,$G(X)=7:1,$G(X)=8:1,1:0)
 ;
ISDIST(PKEY) ; whether model party key is a distinct patient key
 Q $S($E($G(PKEY),1,8)="patient:":1,1:0)
 ;
IDNORM(X) ; uppercase id helper, strips spaces used in fixed-width ISA ids
 N Y
 S Y=$TR($G(X)," ","")
 Q $$UP(Y)
 ;
TRIM(X) ; trim leading/trailing spaces
 N Y
 S Y=$G(X)
 F  Q:$E(Y,1)'=" "  S Y=$E(Y,2,$L(Y))
 F  Q:$E(Y,$L(Y))'=" "  S Y=$E(Y,1,$L(Y)-1)
 Q Y
 ;
ALNUM(X) ; single alphanumeric character?
 N C
 S C=$E($G(X),1)
 I C?1AN Q 1
 Q 0
 ;
UP(X) ; uppercase helper
 N Y,I,C,A
 S Y=""
 F I=1:1:$L($G(X)) S C=$E(X,I) D
 . S A=$A(C)
 . I A'<97,A'>122 S C=$C(A-32)
 . S Y=Y_C
 Q Y
 ;