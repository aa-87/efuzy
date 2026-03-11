EFU837N ; efuzy X12 837 normalization layer
 ;
 ; Public:
 ;   BUILD(ROOT,.OPT,.RES)
 ;
 Q
 ;
BUILD(ROOT,OPT,RES) ; build normalized export-facing views
 N CID,LN,SID,PID,TX,OS1,PK
 K RES
 K @ROOT@("norm")
 S CID=0
 F  S CID=$O(@ROOT@("claim",CID)) Q:'CID  D
 . S TX=+$G(@ROOT@("claim",CID,"tx"))
 . S SID=+$G(@ROOT@("claim",CID,"sub"))
 . S PID=+$G(@ROOT@("claim",CID,"patient"))
 . S PK=$$PATKIND(ROOT,SID,PID)
 . I PK="sub" S PID=SID
 . S @ROOT@("norm","claim",CID,"tx")=TX
 . S @ROOT@("norm","claim",CID,"tx_kind")=$$TXKIND^EFU837U(ROOT,TX)
 . S @ROOT@("norm","claim",CID,"guide")=$G(@ROOT@("tx",TX,"st","guide"))
 . S @ROOT@("norm","claim",CID,"tx_control")=$G(@ROOT@("tx",TX,"st","control"))
 . S @ROOT@("norm","claim",CID,"claim_id")=$G(@ROOT@("claim",CID,"claim_id"))
 . S @ROOT@("norm","claim",CID,"total_charge")=$G(@ROOT@("claim",CID,"total_charge"))
 . S @ROOT@("norm","claim",CID,"facility_code")=$G(@ROOT@("claim",CID,"facility_code"))
 . S @ROOT@("norm","claim",CID,"claim_freq")=$G(@ROOT@("claim",CID,"claim_freq"))
 . S @ROOT@("norm","claim",CID,"claim_type")=$G(@ROOT@("claim",CID,"claim_type"))
 . S @ROOT@("norm","claim",CID,"from_date")=$$FROM(ROOT,CID)
 . S @ROOT@("norm","claim",CID,"thru_date")=$$THRU(ROOT,CID)
 . S @ROOT@("norm","claim",CID,"diag_codes")=$$JOINCODES^EFU837U(ROOT,CID,"|")
 . S @ROOT@("norm","claim",CID,"subscriber_id")=SID
 . S @ROOT@("norm","claim",CID,"patient_id")=PID
 . S @ROOT@("norm","claim",CID,"subscriber_name")=$$PNAME(ROOT,"sub",SID)
 . S @ROOT@("norm","claim",CID,"patient_name")=$$PNAME(ROOT,PK,PID)
 . S @ROOT@("norm","claim",CID,"subscriber_member_id")=$G(@ROOT@("sub",SID,"name","id"))
 . S @ROOT@("norm","claim",CID,"patient_member_id")=$$PMEMBER(ROOT,PK,PID)
 . S @ROOT@("norm","claim",CID,"primary_payer_name")=$G(@ROOT@("sub",SID,"payer","name","name_last"))
 . S OS1=$O(@ROOT@("claim",CID,"other_sub",0))
 . S @ROOT@("norm","claim",CID,"other_payer_name")=$S(OS1>0:$G(@ROOT@("claim",CID,"other_sub",OS1,"payer","name","name_last")),1:"")
 . S @ROOT@("norm","claim",CID,"billing_provider_name")=$G(@ROOT@("tx",TX,"billing","name","name_last"))
 . S @ROOT@("norm","claim",CID,"billing_provider_npi")=$G(@ROOT@("tx",TX,"billing","name","id"))
 . S @ROOT@("norm","claim",CID,"attending_provider_name")=$$PROVNAME(ROOT,CID,"71")
 . S @ROOT@("norm","claim",CID,"attending_provider_id")=$$PROVID(ROOT,CID,"71")
 . S @ROOT@("norm","claim",CID,"line_count")=+$G(@ROOT@("claim",CID,"line_last"))
 . S @ROOT@("norm","party","subscriber",CID,"name")=$$PNAME(ROOT,"sub",SID)
 . S @ROOT@("norm","party","subscriber",CID,"member_id")=$G(@ROOT@("sub",SID,"name","id"))
 . S @ROOT@("norm","party","subscriber",CID,"dob")=$G(@ROOT@("sub",SID,"dmg","date"))
 . S @ROOT@("norm","party","subscriber",CID,"sex")=$G(@ROOT@("sub",SID,"dmg","sex"))
 . S @ROOT@("norm","party","patient",CID,"name")=$$PNAME(ROOT,PK,PID)
 . S @ROOT@("norm","party","patient",CID,"member_id")=$$PMEMBER(ROOT,PK,PID)
 . S @ROOT@("norm","provider","billing",CID,"name")=$G(@ROOT@("tx",TX,"billing","name","name_last"))
 . S @ROOT@("norm","provider","billing",CID,"id")=$G(@ROOT@("tx",TX,"billing","name","id"))
 . S @ROOT@("norm","provider","billing",CID,"id_qual")=$G(@ROOT@("tx",TX,"billing","name","id_qual"))
 . S @ROOT@("norm","provider","claim",CID,"71","name")=$$PROVNAME(ROOT,CID,"71")
 . S @ROOT@("norm","provider","claim",CID,"71","id")=$$PROVID(ROOT,CID,"71")
 . S LN=0
 . F  S LN=$O(@ROOT@("claim",CID,"line",LN)) Q:'LN  D
 . . S @ROOT@("norm","line",CID,LN,"tx_kind")=$G(@ROOT@("norm","claim",CID,"tx_kind"))
 . . S @ROOT@("norm","line",CID,LN,"guide")=$G(@ROOT@("norm","claim",CID,"guide"))
 . . S @ROOT@("norm","line",CID,LN,"claim_id")=$G(@ROOT@("claim",CID,"claim_id"))
 . . S @ROOT@("norm","line",CID,LN,"line_no")=$G(@ROOT@("claim",CID,"line",LN,"line_no"))
 . . S @ROOT@("norm","line",CID,LN,"service_kind")=$G(@ROOT@("claim",CID,"line",LN,"service_kind"))
 . . S @ROOT@("norm","line",CID,LN,"revenue_code")=$G(@ROOT@("claim",CID,"line",LN,"revenue_code"))
 . . S @ROOT@("norm","line",CID,LN,"procedure_qual")=$G(@ROOT@("claim",CID,"line",LN,"proc_qual"))
 . . S @ROOT@("norm","line",CID,LN,"procedure_code")=$G(@ROOT@("claim",CID,"line",LN,"proc_code"))
 . . S @ROOT@("norm","line",CID,LN,"charge")=$G(@ROOT@("claim",CID,"line",LN,"charge"))
 . . S @ROOT@("norm","line",CID,LN,"uom")=$G(@ROOT@("claim",CID,"line",LN,"uom"))
 . . S @ROOT@("norm","line",CID,LN,"qty")=$G(@ROOT@("claim",CID,"line",LN,"qty"))
 . . S @ROOT@("norm","line",CID,LN,"svc_date")=$G(@ROOT@("claim",CID,"line",LN,"dtp","472","value"))
 . . I @ROOT@("norm","line",CID,LN,"svc_date")="" S @ROOT@("norm","line",CID,LN,"svc_date")=$G(@ROOT@("norm","claim",CID,"from_date"))
 S RES("ok")=1
 S RES("claims")=+$G(@ROOT@("stats","claims"))
 S RES("lines")=+$G(@ROOT@("stats","lines"))
 Q
 ;
FROM(ROOT,CID) ; normalized claim from date
 I $D(@ROOT@("claim",CID,"dtp","434","from")) Q $G(@ROOT@("claim",CID,"dtp","434","from"))
 I $D(@ROOT@("claim",CID,"dtp","434","value")) Q $G(@ROOT@("claim",CID,"dtp","434","value"))
 I $D(@ROOT@("claim",CID,"dtp","472","value")) Q $G(@ROOT@("claim",CID,"dtp","472","value"))
 Q ""
 ;
THRU(ROOT,CID) ; normalized claim thru date
 I $D(@ROOT@("claim",CID,"dtp","434","thru")) Q $G(@ROOT@("claim",CID,"dtp","434","thru"))
 I $D(@ROOT@("claim",CID,"dtp","434","value")) Q $G(@ROOT@("claim",CID,"dtp","434","value"))
 I $D(@ROOT@("claim",CID,"dtp","472","value")) Q $G(@ROOT@("claim",CID,"dtp","472","value"))
 Q ""
 ;
PATKIND(ROOT,SID,PID) ; effective normalized patient source kind
 I +$G(PID)>0,$D(@ROOT@("patient",+$G(PID))) Q "patient"
 Q "sub"
 ;
PMEMBER(ROOT,KIND,ID) ; effective normalized patient/member id
 I $G(KIND)="patient" Q $G(@ROOT@("patient",+$G(ID),"name","id"))
 Q $G(@ROOT@("sub",+$G(ID),"name","id"))
 ;
PNAME(ROOT,KIND,ID) ; pretty person/org name
 N L,F,M,S
 I KIND="sub" S L=$G(@ROOT@("sub",ID,"name","name_last")),F=$G(@ROOT@("sub",ID,"name","name_first")),M=$G(@ROOT@("sub",ID,"name","name_middle"))
 I KIND="patient" S L=$G(@ROOT@("patient",ID,"name","name_last")),F=$G(@ROOT@("patient",ID,"name","name_first")),M=$G(@ROOT@("patient",ID,"name","name_middle"))
 S S=L
 I F'="" S S=$S(S'="":S_", ",1:"")_F
 I M'="" S S=S_" "_M
 Q S
 ;
PROVNAME(ROOT,CID,ROLE) ; claim provider name
 N L,F,M,S
 S L=$G(@ROOT@("claim",CID,"provider",ROLE,"name","name_last"))
 S F=$G(@ROOT@("claim",CID,"provider",ROLE,"name","name_first"))
 S M=$G(@ROOT@("claim",CID,"provider",ROLE,"name","name_middle"))
 S S=L
 I F'="" S S=$S(S'="":S_", ",1:"")_F
 I M'="" S S=S_" "_M
 Q S
 ;
PROVID(ROOT,CID,ROLE) ; claim provider id
 Q $G(@ROOT@("claim",CID,"provider",ROLE,"name","id"))
 ;
