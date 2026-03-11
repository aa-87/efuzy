EFU837MODEL ; efuzy X12 837 normalized model v1
 ;
 ; Public:
 ;   VERSION()
 ;   INIT(ROOT)
 ;   BUILD(ROOT,.RES)
 ;   SETMETA(ROOT,KEY,VAL)
 ;
 Q
 ;
VERSION() Q 1
 ;
INIT(ROOT) ; initialize versioned model container
 K @ROOT@("model")
 S @ROOT@("model_version")=$$VERSION()
 S @ROOT@("model","meta","version")=$$VERSION()
 Q
 ;
SETMETA(ROOT,KEY,VAL) ; set model metadata value
 S @ROOT@("model","meta",$G(KEY))=$G(VAL)
 Q
 ;
BUILD(ROOT,RES) ; build model-v1 structures from current parser state
 N TX,CID,LN,SID,PID,PIDK,PIDI,TXID,PK
 K RES
 D INIT(ROOT)
 D SETMETA(ROOT,"engine","EFU837MODEL")
 D SETMETA(ROOT,"source_mode",$G(@ROOT@("meta","mode")))
 D SETMETA(ROOT,"lenient",+$G(@ROOT@("meta","lenient")))
 D SETMETA(ROOT,"accept_bad_envelope",+$G(@ROOT@("meta","accept_bad_envelope")))
 ; transactions
 S TX=0
 F  S TX=$O(@ROOT@("tx",TX)) Q:'TX  D
 . S @ROOT@("model","tx",TX,"tx_id")=TX
 . S @ROOT@("model","tx",TX,"tx_kind")=$$TXKIND^EFU837U(ROOT,TX)
 . S @ROOT@("model","tx",TX,"guide")=$G(@ROOT@("tx",TX,"st","guide"))
 . S @ROOT@("model","tx",TX,"isa_ctrl")=$G(@ROOT@("meta","isa","control"))
 . S @ROOT@("model","tx",TX,"gs_ctrl")=$G(@ROOT@("group",+$G(@ROOT@("tx",TX,"group")),"control"))
 . S @ROOT@("model","tx",TX,"st_ctrl")=$G(@ROOT@("tx",TX,"st","control"))
 . S @ROOT@("model","tx",TX,"submitter_id")=$G(@ROOT@("tx",TX,"submitter","name","id"))
 . S @ROOT@("model","tx",TX,"receiver_id")=$G(@ROOT@("tx",TX,"receiver","name","id"))
 . S @ROOT@("model","tx",TX,"billing_provider_id")=$$BILLID(ROOT,TX)
 . S @ROOT@("model","tx",TX,"claim_count")=0
 . S @ROOT@("model","tx",TX,"line_count")=0
 ; parties from subscriber/patient roots
 S SID=0
 F  S SID=$O(@ROOT@("sub",SID)) Q:'SID  D
 . D PARTYSUB(ROOT,SID)
 S PID=0
 F  S PID=$O(@ROOT@("patient",PID)) Q:'PID  D
 . D PARTYPAT(ROOT,PID)
 ; billing and claim providers
 D PARTYBILL(ROOT)
 ; claims and lines
 S CID=0
 F  S CID=$O(@ROOT@("claim",CID)) Q:'CID  D
 . S TXID=+$G(@ROOT@("claim",CID,"tx"))
 . S SID=+$G(@ROOT@("claim",CID,"sub"))
 . S PID=+$G(@ROOT@("claim",CID,"patient"))
 . S PK=$$PATKIND(ROOT,SID,PID)
 . I PK="sub" S PID=SID
 . S @ROOT@("model","claim",CID,"claim_id")=$G(@ROOT@("claim",CID,"claim_id"))
 . S @ROOT@("model","claim",CID,"tx_id")=TXID
 . S @ROOT@("model","claim",CID,"claim_no")=CID
 . S @ROOT@("model","claim",CID,"patient_control_number")=$G(@ROOT@("claim",CID,"claim_id"))
 . S @ROOT@("model","claim",CID,"claim_amount")=$G(@ROOT@("claim",CID,"total_charge"))
 . S @ROOT@("model","claim",CID,"claim_type")=$$TXKIND^EFU837U(ROOT,TXID)
 . S @ROOT@("model","claim",CID,"guide")=$G(@ROOT@("tx",TXID,"st","guide"))
 . S @ROOT@("model","claim",CID,"billing_provider_id")=$$BILLID(ROOT,TXID)
 . S @ROOT@("model","claim",CID,"subscriber_id")=$$PARTYID("sub",SID)
 . S PIDI=$$PARTYID(PK,PID)
 . S @ROOT@("model","claim",CID,"patient_id")=PIDI
 . S @ROOT@("model","claim",CID,"payer_id")=$$PAYERID(ROOT,SID,CID)
 . S @ROOT@("model","claim",CID,"facility_type")=$G(@ROOT@("claim",CID,"facility_code"))
 . S @ROOT@("model","claim",CID,"claim_frequency")=$G(@ROOT@("claim",CID,"claim_freq"))
 . S @ROOT@("model","claim",CID,"pos")=$G(@ROOT@("claim",CID,"claim_type"))
 . D MOVDIAG(ROOT,CID)
 . D MOVDATE(ROOT,CID)
 . D MOVREF(ROOT,CID)
 . S @ROOT@("model","tx",TXID,"claim_count")=+$G(@ROOT@("model","tx",TXID,"claim_count"))+1
 . S LN=0
 . F  S LN=$O(@ROOT@("claim",CID,"line",LN)) Q:'LN  D
 . . D MOVLINE(ROOT,CID,LN,TXID)
 . . S @ROOT@("model","tx",TXID,"line_count")=+$G(@ROOT@("model","tx",TXID,"line_count"))+1
 S RES("ok")=1
 S RES("claims")=$O(@ROOT@("model","claim",""),-1)
 S RES("transactions")=$O(@ROOT@("model","tx",""),-1)
 Q
 ;
PATKIND(ROOT,SID,PID) ; effective patient namespace for model claim linkage
 I +$G(PID)>0,$D(@ROOT@("patient",+$G(PID))) Q "patient"
 Q "sub"
 ;
PARTYSUB(ROOT,SID) ; build subscriber party
 N ID
 S ID=$$PARTYID("sub",SID)
 S @ROOT@("model","party",ID,"party_id")=ID
 S @ROOT@("model","party",ID,"source_kind")="sub"
 S @ROOT@("model","party",ID,"source_id")=SID
 S @ROOT@("model","party",ID,"kind")=$S($G(@ROOT@("sub",SID,"name","entity_type"))="2":"org",1:"person")
 S @ROOT@("model","party",ID,"role","subscriber")=1
 S @ROOT@("model","party",ID,"last_name")=$G(@ROOT@("sub",SID,"name","name_last"))
 S @ROOT@("model","party",ID,"first_name")=$G(@ROOT@("sub",SID,"name","name_first"))
 S @ROOT@("model","party",ID,"middle_name")=$G(@ROOT@("sub",SID,"name","name_middle"))
 S @ROOT@("model","party",ID,"id_qual")=$G(@ROOT@("sub",SID,"name","id_qual"))
 S @ROOT@("model","party",ID,"id_code")=$G(@ROOT@("sub",SID,"name","id"))
 S @ROOT@("model","party",ID,"addr1")=$G(@ROOT@("sub",SID,"addr","line1"))
 S @ROOT@("model","party",ID,"addr2")=$G(@ROOT@("sub",SID,"addr","line2"))
 S @ROOT@("model","party",ID,"city")=$G(@ROOT@("sub",SID,"addr","city"))
 S @ROOT@("model","party",ID,"state")=$G(@ROOT@("sub",SID,"addr","state"))
 S @ROOT@("model","party",ID,"zip")=$G(@ROOT@("sub",SID,"addr","zip"))
 S @ROOT@("model","party",ID,"dob")=$G(@ROOT@("sub",SID,"dmg","date"))
 S @ROOT@("model","party",ID,"sex")=$G(@ROOT@("sub",SID,"dmg","sex"))
 Q
 ;
PARTYPAT(ROOT,PID) ; build patient party
 N ID
 S ID=$$PARTYID("patient",PID)
 S @ROOT@("model","party",ID,"party_id")=ID
 S @ROOT@("model","party",ID,"source_kind")="patient"
 S @ROOT@("model","party",ID,"source_id")=PID
 S @ROOT@("model","party",ID,"kind")=$S($G(@ROOT@("patient",PID,"name","entity_type"))="2":"org",1:"person")
 S @ROOT@("model","party",ID,"role","patient")=1
 S @ROOT@("model","party",ID,"last_name")=$G(@ROOT@("patient",PID,"name","name_last"))
 S @ROOT@("model","party",ID,"first_name")=$G(@ROOT@("patient",PID,"name","name_first"))
 S @ROOT@("model","party",ID,"middle_name")=$G(@ROOT@("patient",PID,"name","name_middle"))
 S @ROOT@("model","party",ID,"id_qual")=$G(@ROOT@("patient",PID,"name","id_qual"))
 S @ROOT@("model","party",ID,"id_code")=$G(@ROOT@("patient",PID,"name","id"))
 S @ROOT@("model","party",ID,"addr1")=$G(@ROOT@("patient",PID,"addr","line1"))
 S @ROOT@("model","party",ID,"addr2")=$G(@ROOT@("patient",PID,"addr","line2"))
 S @ROOT@("model","party",ID,"city")=$G(@ROOT@("patient",PID,"addr","city"))
 S @ROOT@("model","party",ID,"state")=$G(@ROOT@("patient",PID,"addr","state"))
 S @ROOT@("model","party",ID,"zip")=$G(@ROOT@("patient",PID,"addr","zip"))
 Q
 ;
PARTYBILL(ROOT) ; build billing provider parties by transaction
 N TX,ID
 S TX=0
 F  S TX=$O(@ROOT@("tx",TX)) Q:'TX  D
 . S ID=$$BILLID(ROOT,TX) Q:ID=""
 . S @ROOT@("model","party",ID,"party_id")=ID
 . S @ROOT@("model","party",ID,"kind")=$S($G(@ROOT@("tx",TX,"billing","name","entity_type"))="2":"org",1:"person")
 . S @ROOT@("model","party",ID,"role","billing_provider")=1
 . S @ROOT@("model","party",ID,"last_name")=$G(@ROOT@("tx",TX,"billing","name","name_last"))
 . S @ROOT@("model","party",ID,"first_name")=$G(@ROOT@("tx",TX,"billing","name","name_first"))
 . S @ROOT@("model","party",ID,"middle_name")=$G(@ROOT@("tx",TX,"billing","name","name_middle"))
 . S @ROOT@("model","party",ID,"id_qual")=$G(@ROOT@("tx",TX,"billing","name","id_qual"))
 . S @ROOT@("model","party",ID,"id_code")=$G(@ROOT@("tx",TX,"billing","name","id"))
 Q
 ;
MOVDIAG(ROOT,CID) ; move claim diagnosis list
 N I
 S I=0
 F  S I=$O(@ROOT@("claim",CID,"diag",I)) Q:'I  D
 . S @ROOT@("model","claim",CID,"diag",I,"qual")=$G(@ROOT@("claim",CID,"diag",I,"qual"))
 . S @ROOT@("model","claim",CID,"diag",I,"code")=$G(@ROOT@("claim",CID,"diag",I,"code"))
 Q
 ;
MOVDATE(ROOT,CID) ; move common claim dates
 N QL
 S QL=""
 F  S QL=$O(@ROOT@("claim",CID,"dtp",QL)) Q:QL=""  D
 . I $D(@ROOT@("claim",CID,"dtp",QL,"value")) S @ROOT@("model","claim",CID,"date",QL)=$G(@ROOT@("claim",CID,"dtp",QL,"value"))
 . I '$D(@ROOT@("model","claim",CID,"date",QL)),$D(@ROOT@("claim",CID,"dtp",QL,"from")) D
 . . S @ROOT@("model","claim",CID,"date",QL)=$G(@ROOT@("claim",CID,"dtp",QL,"from"))_"-"_$G(@ROOT@("claim",CID,"dtp",QL,"thru"))
 Q
 ;
MOVREF(ROOT,CID) ; move claim references
 N QL
 S QL=""
 F  S QL=$O(@ROOT@("claim",CID,"ref",QL)) Q:QL=""  D
 . S @ROOT@("model","claim",CID,"ref",QL)=$G(@ROOT@("claim",CID,"ref",QL))
 Q
 ;
MOVLINE(ROOT,CID,LN,TXID) ; move one normalized line
 N NODE,SV
 S NODE=$NA(@ROOT@("model","line",CID,LN))
 S @NODE@("tx_id")=TXID
 S @NODE@("claim_id")=CID
 S @NODE@("line_no")=$G(@ROOT@("claim",CID,"line",LN,"line_no"))
 S SV=$G(@ROOT@("claim",CID,"line",LN,"service_kind"))
 S @NODE@("svc_kind")=SV
 S @NODE@("proc_code")=$G(@ROOT@("claim",CID,"line",LN,"proc_code"))
 S @NODE@("charge_amount")=$G(@ROOT@("claim",CID,"line",LN,"charge"))
 S @NODE@("unit_type")=$G(@ROOT@("claim",CID,"line",LN,"uom"))
 S @NODE@("unit_count")=$G(@ROOT@("claim",CID,"line",LN,"qty"))
 S @NODE@("revenue_code")=$G(@ROOT@("claim",CID,"line",LN,"revenue_code"))
 S @NODE@("date","472")=$G(@ROOT@("claim",CID,"line",LN,"dtp","472","value"))
 Q
 ;
PARTYID(KIND,ID) ; stable local party key
 Q $G(KIND)_":"_+$G(ID)
 ;
BILLID(ROOT,TX) ; billing provider local party key
 I '$D(@ROOT@("tx",TX,"billing","name")) Q ""
 Q "billing:"_TX
 ;
PAYERID(ROOT,SID,CID) ; best-effort payer local key
 I $G(@ROOT@("sub",SID,"payer","name","id"))'="" Q "payer:"_$G(@ROOT@("sub",SID,"payer","name","id"))
 I $G(@ROOT@("claim",CID,"other_sub",1,"payer","name","id"))'="" Q "payer:"_$G(@ROOT@("claim",CID,"other_sub",1,"payer","name","id"))
 Q ""
 ;
