EFU837XCFG ; efuzy 837 export profile definitions
	;
	; Public:
	;   HAS(PROFILE)
	;   ROWSRC(PROFILE)
	;   FIELDN(PROFILE)
	;   FIELD(PROFILE,IDX,.DEF)
	;   HEADERS(PROFILE,.OUT)
	;   LIST(.OUT)
	;
	Q
	;
HAS(PROFILE) ; 1 if profile exists
	N P
	S P=$$NORM(PROFILE)
	Q $S((P="CLAIM_SUMMARY")!(P="SERVICE_LINES")!(P="SUBSCRIBER_PATIENT")!(P="PROVIDER_CONTEXT")!(P="COMBINED_COMPACT")!(P="COMBINED_VERBOSE"):1,1:0)
	;
ROWSRC(PROFILE) ; row source: CLAIM / LINE / COMBINED
	N P
	S P=$$NORM(PROFILE)
	I P="CLAIM_SUMMARY" Q "CLAIM"
	I P="SERVICE_LINES" Q "LINE"
	I P="SUBSCRIBER_PATIENT" Q "CLAIM"
	I P="PROVIDER_CONTEXT" Q "CLAIM"
	I P="COMBINED_COMPACT" Q "COMBINED"
	I P="COMBINED_VERBOSE" Q "COMBINED"
	Q ""
	;
FIELDN(PROFILE) ; field count
	N P
	S P=$$NORM(PROFILE)
	I P="CLAIM_SUMMARY" Q 18
	I P="SERVICE_LINES" Q 16
	I P="SUBSCRIBER_PATIENT" Q 10
	I P="PROVIDER_CONTEXT" Q 8
	I P="COMBINED_COMPACT" Q 28
	I P="COMBINED_VERBOSE" Q 33
	Q 0
	;
FIELD(PROFILE,IDX,DEF) ; populate one field definition
	; DEF("header"), DEF("path"), DEF("xf"), DEF("default")
	N P
	K DEF
	S P=$$NORM(PROFILE)
	I 'IDX Q 0
	I P="CLAIM_SUMMARY" D FCLAIM(IDX,.DEF) Q $S($D(DEF("header")):1,1:0)
	I P="SERVICE_LINES" D FLINE(IDX,.DEF) Q $S($D(DEF("header")):1,1:0)
	I P="SUBSCRIBER_PATIENT" D FSUB(IDX,.DEF) Q $S($D(DEF("header")):1,1:0)
	I P="PROVIDER_CONTEXT" D FPROV(IDX,.DEF) Q $S($D(DEF("header")):1,1:0)
	I P="COMBINED_COMPACT" D FCOMB(IDX,.DEF) Q $S($D(DEF("header")):1,1:0)
	I P="COMBINED_VERBOSE" D FCOMBV(IDX,.DEF) Q $S($D(DEF("header")):1,1:0)
	Q 0
	;
HEADERS(PROFILE,OUT) ; ordered header row
	N I,N,DEF
	K OUT
	S N=$$FIELDN(PROFILE)
	F I=1:1:N D
	. K DEF
	. S %=$$FIELD(PROFILE,I,.DEF)
	. S OUT(I)=$G(DEF("header"))
	Q
	;
LIST(OUT) ; ordered profile names
	K OUT
	S OUT(1)="claim_summary"
	S OUT(2)="service_lines"
	S OUT(3)="subscriber_patient"
	S OUT(4)="provider_context"
	S OUT(5)="combined_compact"
	S OUT(6)="combined_verbose"
	S OUT("n")=6
	Q
	;
NORM(X) ; normalize profile name
	N Y
	S Y=$$UC^EFU837U($G(X))
	S Y=$TR(Y,"- ","__")
	Q Y
	;
SET(DEF,H,P,XF,DFLT) ; internal helper
	S DEF("header")=$G(H)
	S DEF("path")=$G(P)
	I $G(XF)'="" S DEF("xf")=XF
	I $D(DFLT) S DEF("default")=DFLT
	Q
	;
FCLAIM(IDX,DEF)
	I IDX=1 D SET(.DEF,"claim_id","claim.claim_id") Q
	I IDX=2 D SET(.DEF,"tx_kind","claim.tx_kind") Q
	I IDX=3 D SET(.DEF,"guide","claim.guide") Q
	I IDX=4 D SET(.DEF,"total_charge","claim.total_charge") Q
	I IDX=5 D SET(.DEF,"from_date","claim.from_date") Q
	I IDX=6 D SET(.DEF,"thru_date","claim.thru_date") Q
	I IDX=7 D SET(.DEF,"facility_code","claim.facility_code") Q
	I IDX=8 D SET(.DEF,"claim_freq","claim.claim_freq") Q
	I IDX=9 D SET(.DEF,"subscriber_name","claim.subscriber_name") Q
	I IDX=10 D SET(.DEF,"subscriber_member_id","claim.subscriber_member_id") Q
	I IDX=11 D SET(.DEF,"patient_name","claim.patient_name") Q
	I IDX=12 D SET(.DEF,"patient_member_id","claim.patient_member_id") Q
	I IDX=13 D SET(.DEF,"primary_payer_name","claim.primary_payer_name") Q
	I IDX=14 D SET(.DEF,"other_payer_name","claim.other_payer_name") Q
	I IDX=15 D SET(.DEF,"billing_provider_name","claim.billing_provider_name") Q
	I IDX=16 D SET(.DEF,"billing_provider_npi","claim.billing_provider_npi") Q
	I IDX=17 D SET(.DEF,"attending_provider_name","claim.attending_provider_name") Q
	I IDX=18 D SET(.DEF,"diag_codes","claim.diag_codes") Q
	Q
	;
FLINE(IDX,DEF)
	I IDX=1 D SET(.DEF,"claim_id","line.claim_id") Q
	I IDX=2 D SET(.DEF,"line_no","line.line_no") Q
	I IDX=3 D SET(.DEF,"tx_kind","line.tx_kind") Q
	I IDX=4 D SET(.DEF,"guide","line.guide") Q
	I IDX=5 D SET(.DEF,"service_kind","line.service_kind") Q
	I IDX=6 D SET(.DEF,"revenue_code","line.revenue_code") Q
	I IDX=7 D SET(.DEF,"procedure_qual","line.procedure_qual") Q
	I IDX=8 D SET(.DEF,"procedure_code","line.procedure_code") Q
	I IDX=9 D SET(.DEF,"charge","line.charge") Q
	I IDX=10 D SET(.DEF,"uom","line.uom") Q
	I IDX=11 D SET(.DEF,"qty","line.qty") Q
	I IDX=12 D SET(.DEF,"svc_date","line.svc_date") Q
	I IDX=13 D SET(.DEF,"subscriber_name","claim.subscriber_name") Q
	I IDX=14 D SET(.DEF,"patient_name","claim.patient_name") Q
	I IDX=15 D SET(.DEF,"billing_provider_name","claim.billing_provider_name") Q
	I IDX=16 D SET(.DEF,"diag_codes","claim.diag_codes") Q
	Q
	;
FSUB(IDX,DEF)
	I IDX=1 D SET(.DEF,"claim_id","claim.claim_id") Q
	I IDX=2 D SET(.DEF,"subscriber_name","sub.name") Q
	I IDX=3 D SET(.DEF,"subscriber_member_id","sub.member_id") Q
	I IDX=4 D SET(.DEF,"subscriber_dob","sub.dob") Q
	I IDX=5 D SET(.DEF,"subscriber_sex","sub.sex") Q
	I IDX=6 D SET(.DEF,"patient_name","patient.name") Q
	I IDX=7 D SET(.DEF,"patient_member_id","patient.member_id") Q
	I IDX=8 D SET(.DEF,"patient_dob","patient.dob") Q
	I IDX=9 D SET(.DEF,"patient_sex","patient.sex") Q
	I IDX=10 D SET(.DEF,"primary_payer_name","claim.primary_payer_name") Q
	Q
	;
FPROV(IDX,DEF)
	I IDX=1 D SET(.DEF,"claim_id","claim.claim_id") Q
	I IDX=2 D SET(.DEF,"billing_provider_name","prov.billing.name") Q
	I IDX=3 D SET(.DEF,"billing_provider_id","prov.billing.id") Q
	I IDX=4 D SET(.DEF,"billing_provider_id_qual","prov.billing.id_qual") Q
	I IDX=5 D SET(.DEF,"attending_provider_name","prov.attending.name") Q
	I IDX=6 D SET(.DEF,"attending_provider_id","prov.attending.id") Q
	I IDX=7 D SET(.DEF,"subscriber_name","claim.subscriber_name") Q
	I IDX=8 D SET(.DEF,"patient_name","claim.patient_name") Q
	Q
	;
FCOMB(IDX,DEF)
	I IDX=1 D SET(.DEF,"tx_kind","claim.tx_kind") Q
	I IDX=2 D SET(.DEF,"guide","claim.guide") Q
	I IDX=3 D SET(.DEF,"tx_control","claim.tx_control") Q
	I IDX=4 D SET(.DEF,"claim_id","claim.claim_id") Q
	I IDX=5 D SET(.DEF,"total_charge","claim.total_charge") Q
	I IDX=6 D SET(.DEF,"from_date","claim.from_date") Q
	I IDX=7 D SET(.DEF,"thru_date","claim.thru_date") Q
	I IDX=8 D SET(.DEF,"facility_code","claim.facility_code") Q
	I IDX=9 D SET(.DEF,"claim_freq","claim.claim_freq") Q
	I IDX=10 D SET(.DEF,"subscriber_name","claim.subscriber_name") Q
	I IDX=11 D SET(.DEF,"subscriber_member_id","claim.subscriber_member_id") Q
	I IDX=12 D SET(.DEF,"patient_name","claim.patient_name") Q
	I IDX=13 D SET(.DEF,"patient_member_id","claim.patient_member_id") Q
	I IDX=14 D SET(.DEF,"primary_payer_name","claim.primary_payer_name") Q
	I IDX=15 D SET(.DEF,"other_payer_name","claim.other_payer_name") Q
	I IDX=16 D SET(.DEF,"billing_provider_name","claim.billing_provider_name") Q
	I IDX=17 D SET(.DEF,"billing_provider_npi","claim.billing_provider_npi") Q
	I IDX=18 D SET(.DEF,"attending_provider_name","claim.attending_provider_name") Q
	I IDX=19 D SET(.DEF,"diag_codes","claim.diag_codes") Q
	I IDX=20 D SET(.DEF,"line_no","line.line_no") Q
	I IDX=21 D SET(.DEF,"service_kind","line.service_kind") Q
	I IDX=22 D SET(.DEF,"revenue_code","line.revenue_code") Q
	I IDX=23 D SET(.DEF,"procedure_qual","line.procedure_qual") Q
	I IDX=24 D SET(.DEF,"procedure_code","line.procedure_code") Q
	I IDX=25 D SET(.DEF,"charge","line.charge") Q
	I IDX=26 D SET(.DEF,"uom","line.uom") Q
	I IDX=27 D SET(.DEF,"qty","line.qty") Q
	I IDX=28 D SET(.DEF,"svc_date","line.svc_date") Q
	Q
	;
FCOMBV(IDX,DEF)
	D FCOMB($S(IDX<29:IDX,1:0),.DEF)
	I $D(DEF("header")) Q
	I IDX=29 D SET(.DEF,"subscriber_dob","sub.dob") Q
	I IDX=30 D SET(.DEF,"subscriber_sex","sub.sex") Q
	I IDX=31 D SET(.DEF,"attending_provider_id","prov.attending.id") Q
	I IDX=32 D SET(.DEF,"billing_provider_id_qual","prov.billing.id_qual") Q
	I IDX=33 D SET(.DEF,"line_count","claim.line_count") Q
	Q
	;
	;