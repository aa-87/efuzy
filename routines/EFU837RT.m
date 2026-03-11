EFU837RT ; efuzy 837 round-trip helpers v1
	;
	; Public:
	;   RUN(INPATH,WORKBASE,ROOT,.OPT,.RES)
	;   COMPARE(AROOT,BROOT,.RES)
	;
	; Notes:
	;   - Round Trip v1 compares key canonical structural fields
	;   - It does not claim byte-for-byte or envelope-preserving equivalence
	;   - Current canonicalization writes one claim per rebuilt transaction
	;
	Q
	;
RUN(INPATH,WORKBASE,ROOT,OPT,RES) ; parse -> canonical csv -> rebuild x12 -> parse -> compare
	N SROOT,RROOT,CROOT,P1,WRES,RBRES,E1,E2,W1,CMP
	N X12PATH,OUT1,OUT2
	K RES
	S RES("ok")=0
	I $G(INPATH)="" S RES("error")="missing_inpath" Q
	I $G(WORKBASE)="" S RES("error")="missing_workbase" Q
	I $G(ROOT)="" S ROOT=$NA(^TMP($J,"EFU837RT"))
	S SROOT=$NA(@ROOT@("src"))
	S RROOT=$NA(@ROOT@("rebuilt"))
	S CROOT=$NA(@ROOT@("canon"))
	K @SROOT,@RROOT,@CROOT
	D PARSE^EFU837P(INPATH,SROOT,.OPT,.P1)
	I '+$G(P1("ok")) S RES("error")="parse_src_failed" M RES("parse_src")=P1 Q
	S OUT1=WORKBASE_"-src"
	D EXPORT^EFU837CAN(SROOT,OUT1,.E1)
	I '+$G(E1("ok")) S RES("error")="export_src_failed" M RES("export_src")=E1 Q
	D LOAD^EFU837CAN(OUT1,CROOT,.W1)
	I '+$G(W1("ok")) S RES("error")="load_src_failed" M RES("load_src")=W1 Q
	S X12PATH=WORKBASE_"-rebuilt.edi"
	D WRITE^EFU837W(CROOT,X12PATH,.OPT,.WRES)
	I '+$G(WRES("ok")) S RES("error")="write_failed" M RES("write")=WRES Q
	D PARSE^EFU837P(X12PATH,RROOT,.OPT,.RBRES)
	I '+$G(RBRES("ok")) S RES("error")="parse_rebuilt_failed" M RES("parse_rebuilt")=RBRES Q
	S OUT2=WORKBASE_"-rebuilt"
	D EXPORT^EFU837CAN(RROOT,OUT2,.E2)
	I '+$G(E2("ok")) S RES("error")="export_rebuilt_failed" M RES("export_rebuilt")=E2 Q
	D COMPARE(SROOT,RROOT,.CMP)
	M RES=CMP
	M RES("parse_src")=P1
	M RES("write")=WRES
	M RES("parse_rebuilt")=RBRES
	M RES("export_src")=E1
	M RES("export_rebuilt")=E2
	S RES("claims")=+$G(@RROOT@("stats","claims"))
	S RES("lines")=+$G(@RROOT@("stats","lines"))
	S RES("rebuilt_path")=X12PATH
	S RES("src_base")=OUT1
	S RES("rebuilt_base")=OUT2
	Q
	;
COMPARE(AROOT,BROOT,RES) ; compare key normalized structural equivalence
	N NOK1,NOK2,CA,CB,LTA,LTB,FAIL
	K RES
	S RES("ok")=1,FAIL=0
	D ENSURE(AROOT,.NOK1) I '+$G(NOK1("ok")) S RES("ok")=0,RES("error")="norm_a_failed" Q
	D ENSURE(BROOT,.NOK2) I '+$G(NOK2("ok")) S RES("ok")=0,RES("error")="norm_b_failed" Q
	D CMPCOUNT(.FAIL,.RES,"claims",+$G(@AROOT@("stats","claims")),+$G(@BROOT@("stats","claims")))
	D CMPCOUNT(.FAIL,.RES,"lines",+$G(@AROOT@("stats","lines")),+$G(@BROOT@("stats","lines")))
	D INDEX(AROOT,"A")
	D INDEX(BROOT,"B")
	D CMPCLA(.FAIL,.RES,AROOT,BROOT)
	D CMPLIN(.FAIL,.RES,AROOT,BROOT)
	S RES("ok")=$S(FAIL:0,1:1)
	Q
	;
ENSURE(ROOT,RES) ; ensure normalized structures exist
	N NRES,OPT
	K RES
	I $D(@ROOT@("norm","claim"))!$D(@ROOT@("norm","line")) S RES("ok")=1 Q
	D BUILD^EFU837N(ROOT,.OPT,.NRES)
	M RES=NRES
	Q
	;
INDEX(ROOT,TAG) ; build temporary by-claim-id indexes under root
	N CID,LN,ID,KEY
	K @ROOT@("rt",TAG)
	S CID=0
	F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
	. S ID=$G(@ROOT@("norm","claim",CID,"claim_id")) I ID="" S ID=CID
	. S @ROOT@("rt",TAG,"claim",ID)=CID
	. S LN=0
	. F  S LN=$O(@ROOT@("norm","line",CID,LN)) Q:'LN  D
	. . S KEY=ID_"|"_$G(@ROOT@("norm","line",CID,LN,"line_no"),LN)
	. . S @ROOT@("rt",TAG,"line",KEY)=LN
	Q
	;
CMPCLA(FAIL,RES,AROOT,BROOT) ; claim-level equivalence by claim_id
	N ID,CA,CB
	S ID=""
	F  S ID=$O(@AROOT@("rt","A","claim",ID)) Q:ID=""  D
	. S CA=+$G(@AROOT@("rt","A","claim",ID))
	. S CB=+$G(@BROOT@("rt","B","claim",ID))
	. I CB'>0 D MISS(.FAIL,.RES,"claim_missing",ID) Q
	. D CMPI(.FAIL,.RES,ID,"tx_kind",$G(@AROOT@("norm","claim",CA,"tx_kind")),$G(@BROOT@("norm","claim",CB,"tx_kind")))
	. D CMPI(.FAIL,.RES,ID,"guide",$G(@AROOT@("norm","claim",CA,"guide")),$G(@BROOT@("norm","claim",CB,"guide")))
	. D CMPI(.FAIL,.RES,ID,"total_charge",$G(@AROOT@("norm","claim",CA,"total_charge")),$G(@BROOT@("norm","claim",CB,"total_charge")))
	. D CMPI(.FAIL,.RES,ID,"from_date",$G(@AROOT@("norm","claim",CA,"from_date")),$G(@BROOT@("norm","claim",CB,"from_date")))
	. D CMPI(.FAIL,.RES,ID,"thru_date",$G(@AROOT@("norm","claim",CA,"thru_date")),$G(@BROOT@("norm","claim",CB,"thru_date")))
	. D CMPI(.FAIL,.RES,ID,"facility_code",$G(@AROOT@("norm","claim",CA,"facility_code")),$G(@BROOT@("norm","claim",CB,"facility_code")))
	. D CMPI(.FAIL,.RES,ID,"claim_freq",$G(@AROOT@("norm","claim",CA,"claim_freq")),$G(@BROOT@("norm","claim",CB,"claim_freq")))
	. D CMPI(.FAIL,.RES,ID,"subscriber_member_id",$G(@AROOT@("norm","claim",CA,"subscriber_member_id")),$G(@BROOT@("norm","claim",CB,"subscriber_member_id")))
	. D CMPI(.FAIL,.RES,ID,"patient_member_id",$G(@AROOT@("norm","claim",CA,"patient_member_id")),$G(@BROOT@("norm","claim",CB,"patient_member_id")))
	. D CMPI(.FAIL,.RES,ID,"billing_provider_npi",$G(@AROOT@("norm","claim",CA,"billing_provider_npi")),$G(@BROOT@("norm","claim",CB,"billing_provider_npi")))
	. D CMPI(.FAIL,.RES,ID,"attending_provider_id",$G(@AROOT@("norm","claim",CA,"attending_provider_id")),$G(@BROOT@("norm","claim",CB,"attending_provider_id")))
	. D CMPI(.FAIL,.RES,ID,"diag_codes",$G(@AROOT@("norm","claim",CA,"diag_codes")),$G(@BROOT@("norm","claim",CB,"diag_codes")))
	. D CMPI(.FAIL,.RES,ID,"line_count",+$G(@AROOT@("norm","claim",CA,"line_count")),+$G(@BROOT@("norm","claim",CB,"line_count")))
	Q
	;
CMPLIN(FAIL,RES,AROOT,BROOT) ; line-level equivalence by claim_id + line_no
	N CID,LN,ID,KEY,CB,LNB
	S CID=0
	F  S CID=$O(@AROOT@("norm","line",CID)) Q:'CID  D
	. S ID=$G(@AROOT@("norm","line",CID,1,"claim_id"))
	. I ID="" S ID=$G(@AROOT@("norm","claim",CID,"claim_id"),CID)
	. S LN=0
	. F  S LN=$O(@AROOT@("norm","line",CID,LN)) Q:'LN  D
	. . S KEY=ID_"|"_$G(@AROOT@("norm","line",CID,LN,"line_no"),LN)
	. . S LNB=+$G(@BROOT@("rt","B","line",KEY))
	. . S CB=+$G(@BROOT@("rt","B","claim",ID))
	. . I CB'>0!(LNB'>0) D MISS(.FAIL,.RES,"line_missing",KEY) Q
	. . D CMPI(.FAIL,.RES,KEY,"service_kind",$G(@AROOT@("norm","line",CID,LN,"service_kind")),$G(@BROOT@("norm","line",CB,LNB,"service_kind")))
	. . D CMPI(.FAIL,.RES,KEY,"revenue_code",$G(@AROOT@("norm","line",CID,LN,"revenue_code")),$G(@BROOT@("norm","line",CB,LNB,"revenue_code")))
	. . D CMPI(.FAIL,.RES,KEY,"procedure_qual",$G(@AROOT@("norm","line",CID,LN,"procedure_qual")),$G(@BROOT@("norm","line",CB,LNB,"procedure_qual")))
	. . D CMPI(.FAIL,.RES,KEY,"procedure_code",$G(@AROOT@("norm","line",CID,LN,"procedure_code")),$G(@BROOT@("norm","line",CB,LNB,"procedure_code")))
	. . D CMPI(.FAIL,.RES,KEY,"charge",$G(@AROOT@("norm","line",CID,LN,"charge")),$G(@BROOT@("norm","line",CB,LNB,"charge")))
	. . D CMPI(.FAIL,.RES,KEY,"uom",$G(@AROOT@("norm","line",CID,LN,"uom")),$G(@BROOT@("norm","line",CB,LNB,"uom")))
	. . D CMPI(.FAIL,.RES,KEY,"qty",$G(@AROOT@("norm","line",CID,LN,"qty")),$G(@BROOT@("norm","line",CB,LNB,"qty")))
	. . D CMPI(.FAIL,.RES,KEY,"svc_date",$G(@AROOT@("norm","line",CID,LN,"svc_date")),$G(@BROOT@("norm","line",CB,LNB,"svc_date")))
	Q
	;
CMPCOUNT(FAIL,RES,KEY,A,B) ; top-level counter compare
	I +$G(A)=+$G(B) Q
	S FAIL=1
	S RES("mismatch",KEY,"left")=$G(A)
	S RES("mismatch",KEY,"right")=$G(B)
	Q
	;
CMPI(FAIL,RES,ID,FIELD,A,B) ; field compare
	I $G(A)=$G(B) Q
	S FAIL=1
	S RES("mismatch",ID,FIELD,"left")=$G(A)
	S RES("mismatch",ID,FIELD,"right")=$G(B)
	Q
	;
MISS(FAIL,RES,KIND,ID) ; missing key capture
	S FAIL=1
	S RES("missing",KIND,$G(ID))=1
	Q
	;
	;