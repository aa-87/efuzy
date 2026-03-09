EFU837MAP ; 837 export field map definitions
 ;
 Q
 ;
LOADMAPS(TCTX)
 ; Modes
 S TCTX("maps","modes",1,"id")="claim_summary"
 S TCTX("maps","modes",1,"label")="Claim Summary CSV"
 S TCTX("maps","modes",1,"rowSource")="claim"
 S TCTX("maps","modes",2,"id")="service_line"
 S TCTX("maps","modes",2,"label")="Service Line CSV"
 S TCTX("maps","modes",2,"rowSource")="line"
 S TCTX("maps","modes",3,"id")="subscriber_patient"
 S TCTX("maps","modes",3,"label")="Subscriber / Patient CSV"
 S TCTX("maps","modes",3,"rowSource")="claim"
 S TCTX("maps","modes",4,"id")="provider_context"
 S TCTX("maps","modes",4,"label")="Provider / Billing Context CSV"
 S TCTX("maps","modes",4,"rowSource")="claim"
 S TCTX("maps","modes",5,"id")="custom"
 S TCTX("maps","modes",5,"label")="Custom CSV export"
 S TCTX("maps","modes",5,"rowSource")="claim"
 ;
 D MODEFIELDS(.TCTX,"claim_summary","claim","claim_id^Claim ID|total_charge^Total Charge|claim_date^Claim Date|subscriber_id^Subscriber ID|subscriber_last^Subscriber Last|subscriber_first^Subscriber First|patient_last^Patient Last|patient_first^Patient First|billing_provider_name^Billing Provider|payer_name^Payer|service_line_count^Service Lines")
 D MODEFIELDS(.TCTX,"service_line","line","claim_id^Claim ID|line_number^Line Number|procedure_code^Procedure Code|procedure_qualifier^Procedure Qualifier|line_charge^Line Charge|units^Units|line_service_date^Line Service Date|subscriber_id^Subscriber ID|patient_last^Patient Last|patient_first^Patient First")
 D MODEFIELDS(.TCTX,"subscriber_patient","claim","claim_id^Claim ID|subscriber_id^Subscriber ID|subscriber_last^Subscriber Last|subscriber_first^Subscriber First|patient_last^Patient Last|patient_first^Patient First|claim_date^Claim Date")
 D MODEFIELDS(.TCTX,"provider_context","claim","claim_id^Claim ID|billing_provider_name^Billing Provider|billing_provider_id^Billing Provider ID|payer_name^Payer|payer_id^Payer ID|submitter_name^Submitter|receiver_name^Receiver|claim_date^Claim Date")
 D MODEFIELDS(.TCTX,"custom","claim","claim_id^Claim ID|total_charge^Total Charge|claim_date^Claim Date|subscriber_id^Subscriber ID|subscriber_last^Subscriber Last|subscriber_first^Subscriber First|patient_last^Patient Last|patient_first^Patient First|billing_provider_name^Billing Provider|payer_name^Payer|service_line_count^Service Lines")
 Q
 ;
MODEFIELDS(TCTX,MODE,ROWSRC,SPEC)
 N I,N,P,NM,LB
 S N=0
 F I=1:1:$L(SPEC,"|") S P=$P(SPEC,"|",I) I P'="" D
 . S N=N+1
 . S NM=$P(P,"^",1),LB=$P(P,"^",2)
 . S TCTX("maps","fields",MODE,N,"name")=NM
 . S TCTX("maps","fields",MODE,N,"label")=LB
 . S TCTX("maps","fields",MODE,N,"rowSource")=ROWSRC
 Q
 ;
DFLIST(MODE)
 I $G(MODE)="service_line" Q "claim_id,line_number,procedure_code,procedure_qualifier,line_charge,units,line_service_date,subscriber_id,patient_last,patient_first"
 I $G(MODE)="subscriber_patient" Q "claim_id,subscriber_id,subscriber_last,subscriber_first,patient_last,patient_first,claim_date"
 I $G(MODE)="provider_context" Q "claim_id,billing_provider_name,billing_provider_id,payer_name,payer_id,submitter_name,receiver_name,claim_date"
 I $G(MODE)="custom" Q "claim_id,total_charge,claim_date,subscriber_id,subscriber_last,subscriber_first,patient_last,patient_first,billing_provider_name,payer_name,service_line_count"
 Q "claim_id,total_charge,claim_date,subscriber_id,subscriber_last,subscriber_first,patient_last,patient_first,billing_provider_name,payer_name,service_line_count"
 ;
ROWSRC(MODE)
 I $G(MODE)="service_line" Q "line"
 Q "claim"
 ;
COMB(L,F)
 Q $G(L)_$S($G(L)'=""&($G(F)'=""):", ",1:"")_$G(F)
 ;
