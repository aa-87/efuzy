EFU837MAP ; efuzy X12 837 export-facing mapping helpers
 ;
 ; Public:
 ;   HEADERS(TYPE,.OUT)
 ;   ROWCLAIM(ROOT,CID,.ROW)
 ;   ROWLINE(ROOT,CID,LN,.ROW)
 ;   ROWSUB(ROOT,CID,.ROW)
 ;   ROWPROV(ROOT,CID,.ROW)
 ;   ROWCOMB(ROOT,CID,LN,.ROW)
 ;
 Q
 ;
HEADERS(TYPE,OUT) ; default CSV-oriented header sets
 K OUT
 S TYPE=$$UC^EFU837U($G(TYPE))
 I TYPE="CLAIM" D  Q
 . S OUT(1)="claim_id"
 . S OUT(2)="total_charge"
 . S OUT(3)="from_date"
 . S OUT(4)="thru_date"
 . S OUT(5)="facility_code"
 . S OUT(6)="claim_freq"
 . S OUT(7)="subscriber_name"
 . S OUT(8)="subscriber_member_id"
 . S OUT(9)="patient_name"
 . S OUT(10)="patient_member_id"
 . S OUT(11)="primary_payer_name"
 . S OUT(12)="other_payer_name"
 . S OUT(13)="billing_provider_name"
 . S OUT(14)="billing_provider_npi"
 . S OUT(15)="attending_provider_name"
 . S OUT(16)="diag_codes"
 I TYPE="LINE" D  Q
 . S OUT(1)="claim_id"
 . S OUT(2)="line_no"
 . S OUT(3)="service_kind"
 . S OUT(4)="revenue_code"
 . S OUT(5)="procedure_qual"
 . S OUT(6)="procedure_code"
 . S OUT(7)="charge"
 . S OUT(8)="uom"
 . S OUT(9)="qty"
 . S OUT(10)="svc_date"
 I TYPE="SUBSCRIBER" D  Q
 . S OUT(1)="claim_id"
 . S OUT(2)="subscriber_name"
 . S OUT(3)="member_id"
 . S OUT(4)="dob"
 . S OUT(5)="sex"
 I TYPE="PROVIDER" D  Q
 . S OUT(1)="claim_id"
 . S OUT(2)="billing_provider_name"
 . S OUT(3)="billing_provider_id"
 . S OUT(4)="attending_provider_name"
 . S OUT(5)="attending_provider_id"
 I TYPE="COMBINED" D  Q
 . S OUT(1)="tx_kind"
 . S OUT(2)="guide"
 . S OUT(3)="tx_control"
 . S OUT(4)="claim_id"
 . S OUT(5)="total_charge"
 . S OUT(6)="from_date"
 . S OUT(7)="thru_date"
 . S OUT(8)="facility_code"
 . S OUT(9)="claim_freq"
 . S OUT(10)="subscriber_name"
 . S OUT(11)="subscriber_member_id"
 . S OUT(12)="patient_name"
 . S OUT(13)="patient_member_id"
 . S OUT(14)="primary_payer_name"
 . S OUT(15)="other_payer_name"
 . S OUT(16)="billing_provider_name"
 . S OUT(17)="billing_provider_npi"
 . S OUT(18)="attending_provider_name"
 . S OUT(19)="diag_codes"
 . S OUT(20)="line_no"
 . S OUT(21)="service_kind"
 . S OUT(22)="revenue_code"
 . S OUT(23)="procedure_qual"
 . S OUT(24)="procedure_code"
 . S OUT(25)="charge"
 . S OUT(26)="uom"
 . S OUT(27)="qty"
 . S OUT(28)="svc_date"
 Q
 ;
ROWCLAIM(ROOT,CID,ROW) ; normalized claim row
 K ROW
 S ROW(1)=$G(@ROOT@("norm","claim",CID,"claim_id"))
 S ROW(2)=$G(@ROOT@("norm","claim",CID,"total_charge"))
 S ROW(3)=$G(@ROOT@("norm","claim",CID,"from_date"))
 S ROW(4)=$G(@ROOT@("norm","claim",CID,"thru_date"))
 S ROW(5)=$G(@ROOT@("norm","claim",CID,"facility_code"))
 S ROW(6)=$G(@ROOT@("norm","claim",CID,"claim_freq"))
 S ROW(7)=$G(@ROOT@("norm","claim",CID,"subscriber_name"))
 S ROW(8)=$G(@ROOT@("norm","claim",CID,"subscriber_member_id"))
 S ROW(9)=$G(@ROOT@("norm","claim",CID,"patient_name"))
 S ROW(10)=$G(@ROOT@("norm","claim",CID,"patient_member_id"))
 S ROW(11)=$G(@ROOT@("norm","claim",CID,"primary_payer_name"))
 S ROW(12)=$G(@ROOT@("norm","claim",CID,"other_payer_name"))
 S ROW(13)=$G(@ROOT@("norm","claim",CID,"billing_provider_name"))
 S ROW(14)=$G(@ROOT@("norm","claim",CID,"billing_provider_npi"))
 S ROW(15)=$G(@ROOT@("norm","claim",CID,"attending_provider_name"))
 S ROW(16)=$G(@ROOT@("norm","claim",CID,"diag_codes"))
 Q
 ;
ROWLINE(ROOT,CID,LN,ROW) ; normalized service line row
 K ROW
 S ROW(1)=$G(@ROOT@("norm","line",CID,LN,"claim_id"))
 S ROW(2)=$G(@ROOT@("norm","line",CID,LN,"line_no"))
 S ROW(3)=$G(@ROOT@("norm","line",CID,LN,"service_kind"))
 S ROW(4)=$G(@ROOT@("norm","line",CID,LN,"revenue_code"))
 S ROW(5)=$G(@ROOT@("norm","line",CID,LN,"procedure_qual"))
 S ROW(6)=$G(@ROOT@("norm","line",CID,LN,"procedure_code"))
 S ROW(7)=$G(@ROOT@("norm","line",CID,LN,"charge"))
 S ROW(8)=$G(@ROOT@("norm","line",CID,LN,"uom"))
 S ROW(9)=$G(@ROOT@("norm","line",CID,LN,"qty"))
 S ROW(10)=$G(@ROOT@("norm","line",CID,LN,"svc_date"))
 Q
 ;
ROWSUB(ROOT,CID,ROW) ; subscriber-oriented row
 K ROW
 S ROW(1)=$G(@ROOT@("norm","claim",CID,"claim_id"))
 S ROW(2)=$G(@ROOT@("norm","party","subscriber",CID,"name"))
 S ROW(3)=$G(@ROOT@("norm","party","subscriber",CID,"member_id"))
 S ROW(4)=$G(@ROOT@("norm","party","subscriber",CID,"dob"))
 S ROW(5)=$G(@ROOT@("norm","party","subscriber",CID,"sex"))
 Q
 ;
ROWPROV(ROOT,CID,ROW) ; provider/billing context row
 K ROW
 S ROW(1)=$G(@ROOT@("norm","claim",CID,"claim_id"))
 S ROW(2)=$G(@ROOT@("norm","provider","billing",CID,"name"))
 S ROW(3)=$G(@ROOT@("norm","provider","billing",CID,"id"))
 S ROW(4)=$G(@ROOT@("norm","provider","claim",CID,"71","name"))
 S ROW(5)=$G(@ROOT@("norm","provider","claim",CID,"71","id"))
 Q
 ;
ROWCOMB(ROOT,CID,LN,ROW) ; combined claim + line row
 K ROW
 S ROW(1)=$G(@ROOT@("norm","claim",CID,"tx_kind"))
 S ROW(2)=$G(@ROOT@("norm","claim",CID,"guide"))
 S ROW(3)=$G(@ROOT@("norm","claim",CID,"tx_control"))
 S ROW(4)=$G(@ROOT@("norm","claim",CID,"claim_id"))
 S ROW(5)=$G(@ROOT@("norm","claim",CID,"total_charge"))
 S ROW(6)=$G(@ROOT@("norm","claim",CID,"from_date"))
 S ROW(7)=$G(@ROOT@("norm","claim",CID,"thru_date"))
 S ROW(8)=$G(@ROOT@("norm","claim",CID,"facility_code"))
 S ROW(9)=$G(@ROOT@("norm","claim",CID,"claim_freq"))
 S ROW(10)=$G(@ROOT@("norm","claim",CID,"subscriber_name"))
 S ROW(11)=$G(@ROOT@("norm","claim",CID,"subscriber_member_id"))
 S ROW(12)=$G(@ROOT@("norm","claim",CID,"patient_name"))
 S ROW(13)=$G(@ROOT@("norm","claim",CID,"patient_member_id"))
 S ROW(14)=$G(@ROOT@("norm","claim",CID,"primary_payer_name"))
 S ROW(15)=$G(@ROOT@("norm","claim",CID,"other_payer_name"))
 S ROW(16)=$G(@ROOT@("norm","claim",CID,"billing_provider_name"))
 S ROW(17)=$G(@ROOT@("norm","claim",CID,"billing_provider_npi"))
 S ROW(18)=$G(@ROOT@("norm","claim",CID,"attending_provider_name"))
 S ROW(19)=$G(@ROOT@("norm","claim",CID,"diag_codes"))
 S ROW(20)=$G(@ROOT@("norm","line",CID,LN,"line_no"))
 S ROW(21)=$G(@ROOT@("norm","line",CID,LN,"service_kind"))
 S ROW(22)=$G(@ROOT@("norm","line",CID,LN,"revenue_code"))
 S ROW(23)=$G(@ROOT@("norm","line",CID,LN,"procedure_qual"))
 S ROW(24)=$G(@ROOT@("norm","line",CID,LN,"procedure_code"))
 S ROW(25)=$G(@ROOT@("norm","line",CID,LN,"charge"))
 S ROW(26)=$G(@ROOT@("norm","line",CID,LN,"uom"))
 S ROW(27)=$G(@ROOT@("norm","line",CID,LN,"qty"))
 S ROW(28)=$G(@ROOT@("norm","line",CID,LN,"svc_date"))
 Q
 ;
