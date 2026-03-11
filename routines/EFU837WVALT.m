EFU837WVALT ; efuzy 837 writer preflight tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFU837WVALT"
 Q
 ;
ALL(FAIL) ; full suite
 D T900(.FAIL)
 D T901(.FAIL)
 D T902(.FAIL)
 D T903(.FAIL)
 D T904(.FAIL)
 D T905(.FAIL)
 D T906(.FAIL)
 Q
 ;
T900(FAIL) ; valid canonical 837P passes strict preflight
 N ROOT,OPT,RES
 S ROOT=$NA(^TMP($J,"EFU837WVALT",900))
 D SYN(ROOT,"837P")
 D STRICT^EFU837WVAL(ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T900][ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T900][errors]",+$G(RES("error")),0)
 D EQ(.FAIL,"[T900][warns]",+$G(RES("warn")),0)
 K @ROOT Q
 ;
T901(FAIL) ; missing claim id fails strict and blocks writer
 N ROOT,OPT,RES,WRES,PATH
 S ROOT=$NA(^TMP($J,"EFU837WVALT",901))
 D SYN(ROOT,"837P")
 K @ROOT@("canon","claim",1,"claim_id")
 D STRICT^EFU837WVAL(ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T901][ok false]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T901][claim id code]",$$HAS(ROOT,"error","X12W_CLAIM_ID_REQUIRED"),1)
 S PATH="efu837wvalt_901_"_$J_".edi"
 S OPT("writer_strict")=1
 D WRITE^EFU837W(ROOT,PATH,.OPT,.WRES)
 D EQ(.FAIL,"[T901][write blocked]",+$G(WRES("ok")),0)
 D EQ(.FAIL,"[T901][write err]",$G(WRES("error")),"writer_preflight_failed")
 K @ROOT Q
 ;
T902(FAIL) ; service kind mismatch fails strict
 N ROOT,OPT,RES
 S ROOT=$NA(^TMP($J,"EFU837WVALT",902))
 D SYN(ROOT,"837I")
 S @ROOT@("canon","claim",1,"line",1,"service_kind")="SV1"
 D STRICT^EFU837WVAL(ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T902][ok false]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T902][svc mismatch]",$$HAS(ROOT,"error","X12W_SERVICE_KIND_MISMATCH"),1)
 K @ROOT Q
 ;
T903(FAIL) ; missing line date warns in lenient when claim date exists
 N ROOT,OPT,RES,WRES,PATH
 S ROOT=$NA(^TMP($J,"EFU837WVALT",903))
 D SYN(ROOT,"837P")
 K @ROOT@("canon","claim",1,"line",1,"svc_date")
 S OPT("writer_lenient")=1
 D LENIENT^EFU837WVAL(ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T903][ok true]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T903][date warn]",$$HAS(ROOT,"warn","X12W_LINE_DATE_DEFAULTED"),1)
 S PATH="efu837wvalt_903_"_$J_".edi"
 D WRITE^EFU837W(ROOT,PATH,.OPT,.WRES)
 D EQ(.FAIL,"[T903][write ok]",+$G(WRES("ok")),1)
 K @ROOT Q
 ;
T904(FAIL) ; CHCN profile flags receiver, ISA11, and billing NPI
 N ROOT,OPT,RES
 S ROOT=$NA(^TMP($J,"EFU837WVALT",904))
 D SYN(ROOT,"837P")
 K @ROOT@("canon","claim",1,"billing_provider_npi")
 S OPT("profile")="CHCN_837P"
 S OPT("envelope")=1
 S OPT("isa_receiver_id")="BAD"
 S OPT("gs_receiver_id")="BAD"
 S OPT("rep")="^"
 D STRICT^EFU837WVAL(ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T904][ok false]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T904][isa08]",$$HAS(ROOT,"error","X12W_PROFILE_CHCN_ISA08"),1)
 D EQ(.FAIL,"[T904][gs03]",$$HAS(ROOT,"error","X12W_PROFILE_CHCN_GS03"),1)
 D EQ(.FAIL,"[T904][isa11]",$$HAS(ROOT,"error","X12W_PROFILE_CHCN_ISA11"),1)
 D EQ(.FAIL,"[T904][billing npi]",$$HAS(ROOT,"error","X12W_PROFILE_CHCN_BILLING_NPI"),1)
 K @ROOT Q
 ;
T905(FAIL) ; ForwardHealth profile flags uppercase and receiver controls
 N ROOT,OPT,RES
 S ROOT=$NA(^TMP($J,"EFU837WVALT",905))
 D SYN(ROOT,"837P")
 S @ROOT@("canon","claim",1,"subscriber_name")="Doe, John"
 S OPT("profile")="FORWARDHEALTH_837P"
 S OPT("envelope")=1
 S OPT("isa_receiver_id")="BAD"
 S OPT("gs_receiver_id")="BAD"
 S OPT("receiver_id")="BAD"
 S OPT("receiver_name")="RECEIVER"
 S OPT("isa_sender_id")="123456789"
 S OPT("submitter_id")="987654321"
 S OPT("bht_type")="RP"
 D STRICT^EFU837WVAL(ROOT,.OPT,.RES)
 D EQ(.FAIL,"[T905][ok false]",+$G(RES("ok")),0)
 D EQ(.FAIL,"[T905][isa08]",$$HAS(ROOT,"error","X12W_PROFILE_FORWARD_ISA08"),1)
 D EQ(.FAIL,"[T905][gs03]",$$HAS(ROOT,"error","X12W_PROFILE_FORWARD_GS03"),1)
 D EQ(.FAIL,"[T905][nm109]",$$HAS(ROOT,"error","X12W_PROFILE_FORWARD_NM109"),1)
 D EQ(.FAIL,"[T905][receiver name]",$$HAS(ROOT,"error","X12W_PROFILE_FORWARD_RECEIVER_NAME"),1)
 D EQ(.FAIL,"[T905][bht06]",$$HAS(ROOT,"error","X12W_PROFILE_FORWARD_BHT06"),1)
 D EQ(.FAIL,"[T905][submitter id]",$$HAS(ROOT,"error","X12W_PROFILE_FORWARD_SUBMITTER_ID"),1)
 D EQ(.FAIL,"[T905][uppercase]",$$HAS(ROOT,"error","X12W_PROFILE_FORWARD_UPPERCASE"),1)
 K @ROOT Q
 ;
T906(FAIL) ; valid strict write returns preflight summary and emits file
 N ROOT,OPT,RES,PATH
 S ROOT=$NA(^TMP($J,"EFU837WVALT",906))
 D SYN(ROOT,"837I")
 S OPT("writer_strict")=1
 S PATH="efu837wvalt_906_"_$J_".edi"
 D WRITE^EFU837W(ROOT,PATH,.OPT,.RES)
 D EQ(.FAIL,"[T906][write ok]",+$G(RES("ok")),1)
 D EQ(.FAIL,"[T906][preflight ok]",+$G(RES("preflight","ok")),1)
 D EQ(.FAIL,"[T906][transactions]",+$G(RES("transactions")),1)
 K @ROOT Q
 ;
SYN(ROOT,KIND) ; synthetic canonical claim package
 N TXK,GUIDE,SV,CTYPE
 K @ROOT
 S TXK=$G(KIND) I TXK="" S TXK="837P"
 S GUIDE=$S(TXK="837I":"005010X223A2",TXK="837D":"005010X224A2",1:"005010X222A1")
 S SV=$S(TXK="837I":"SV2",TXK="837D":"SV3",1:"SV1")
 S CTYPE=$S(TXK="837I":"I",TXK="837D":"D",1:"Y")
 S @ROOT@("canon","claims")=1
 S @ROOT@("canon","claim",1,"claim_id")="WVAL1"
 S @ROOT@("canon","claim",1,"tx_kind")=TXK
 S @ROOT@("canon","claim",1,"guide")=GUIDE
 S @ROOT@("canon","claim",1,"tx_control")=1
 S @ROOT@("canon","claim",1,"total_charge")=125
 S @ROOT@("canon","claim",1,"from_date")=20260311
 S @ROOT@("canon","claim",1,"thru_date")=20260311
 S @ROOT@("canon","claim",1,"facility_code")=11
 S @ROOT@("canon","claim",1,"claim_freq")=1
 S @ROOT@("canon","claim",1,"claim_type")=CTYPE
 S @ROOT@("canon","claim",1,"subscriber_name")="DOE, JOHN"
 S @ROOT@("canon","claim",1,"subscriber_member_id")="SUB123"
 S @ROOT@("canon","claim",1,"subscriber_dob")=19800101
 S @ROOT@("canon","claim",1,"subscriber_sex")="M"
 S @ROOT@("canon","claim",1,"patient_name")="DOE, JOHN"
 S @ROOT@("canon","claim",1,"patient_member_id")="SUB123"
 S @ROOT@("canon","claim",1,"patient_dob")=19800101
 S @ROOT@("canon","claim",1,"patient_sex")="M"
 S @ROOT@("canon","claim",1,"primary_payer_name")="MEDICARE"
 S @ROOT@("canon","claim",1,"billing_provider_name")="BILLING CLINIC"
 S @ROOT@("canon","claim",1,"billing_provider_npi")="1234567890"
 S @ROOT@("canon","claim",1,"attending_provider_name")="SMITH, ADAM"
 S @ROOT@("canon","claim",1,"attending_provider_id")="1111111111"
 S @ROOT@("canon","claim",1,"diag_codes")="A123|B456"
 S @ROOT@("canon","claim",1,"line",1,"line_no")=1
 S @ROOT@("canon","claim",1,"line",1,"service_kind")=SV
 S @ROOT@("canon","claim",1,"line",1,"revenue_code")=$S(SV="SV2":"0300",1:"")
 S @ROOT@("canon","claim",1,"line",1,"procedure_qual")=$S(SV="SV3":"AD",1:"HC")
 S @ROOT@("canon","claim",1,"line",1,"procedure_code")=$S(SV="SV3":"D1110",SV="SV2":"85025",1:"99213")
 S @ROOT@("canon","claim",1,"line",1,"charge")=125
 S @ROOT@("canon","claim",1,"line",1,"uom")="UN"
 S @ROOT@("canon","claim",1,"line",1,"qty")=1
 S @ROOT@("canon","claim",1,"line",1,"svc_date")=20260311
 Q
 ;
HAS(ROOT,SEV,CODE) ; whether one writer diagnostic exists
 N I,HIT
 S HIT=0,I=0
 F  S I=$O(@ROOT@("wdiag","item",I)) Q:'I  D  Q:HIT
 . I $G(@ROOT@("wdiag","item",I,"severity"))=$G(SEV),$G(@ROOT@("wdiag","item",I,"code"))=$G(CODE) S HIT=1
 Q +$G(HIT)
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
