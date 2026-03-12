EFU837RT ; efuzy 837 round-trip helpers v2
 ;
 ; Public:
 ;   RUN(INPATH,WORKBASE,ROOT,.OPT,.RES)
 ;   COMPARE(AROOT,BROOT,.RES)                  ; default export_safe mode
 ;   COMPAREM(AROOT,BROOT,MODE,.OPT,.RES)      ; explicit compare mode
 ;
 ; Supported compare modes:
 ;   core              - key structural fields only
 ;   export_safe       - canonical/export-facing equivalence (default)
 ;   strict_structural - adds names, payer/provider display fields,
 ;                       and extra-key detection for stronger reporting
 ;
 ; Notes:
 ;   - Round Trip v1/v2 compare structural equivalence, not bytes
 ;   - Current canonicalization may rewrite envelope / grouping shape
 ;   - Default mode remains export_safe for backward compatibility
 ;
 Q
 ;
RUN(INPATH,WORKBASE,ROOT,OPT,RES) ; parse -> canonical csv -> rebuild x12 -> parse -> compare
 N SROOT,RROOT,CROOT,P1,WRES,RBRES,E1,E2,W1,CMP
 N X12PATH,OUT1,OUT2,MODE
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
 S MODE=$$MODE(.OPT)
 D COMPAREM(SROOT,RROOT,MODE,.OPT,.CMP)
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
COMPARE(AROOT,BROOT,RES) ; backward-compatible default compare
 N OPT
 D COMPAREM(AROOT,BROOT,"export_safe",.OPT,.RES)
 Q
 ;
COMPAREM(AROOT,BROOT,MODE,OPT,RES) ; compare with explicit mode and richer reporting
 N NOK1,NOK2,FAIL,CFLD,LFLD
 K RES
 S MODE=$$NMODE($G(MODE))
 S RES("ok")=1,FAIL=0
 S RES("compare_mode")=MODE
 D ENSURE(AROOT,.NOK1) I '+$G(NOK1("ok")) S RES("ok")=0,RES("error")="norm_a_failed" Q
 D ENSURE(BROOT,.NOK2) I '+$G(NOK2("ok")) S RES("ok")=0,RES("error")="norm_b_failed" Q
 D INITSUM(.RES,MODE)
 D CLAIMFLDS(MODE,.CFLD,.RES)
 D LINEFLDS(MODE,.LFLD,.RES)
 D CMPCOUNT(.FAIL,.RES,"claims",+$G(@AROOT@("stats","claims")),+$G(@BROOT@("stats","claims")))
 D CMPCOUNT(.FAIL,.RES,"lines",+$G(@AROOT@("stats","lines")),+$G(@BROOT@("stats","lines")))
 D INDEX(AROOT,"A")
 D INDEX(BROOT,"B")
 D CMPCLA(.FAIL,.RES,AROOT,BROOT,.CFLD)
 D CMPLIN(.FAIL,.RES,AROOT,BROOT,.LFLD)
 D EXTRA(.FAIL,.RES,AROOT,BROOT,"claim")
 D EXTRA(.FAIL,.RES,AROOT,BROOT,"line")
 S RES("summary","failed")=+FAIL
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
CLAIMFLDS(MODE,ARR,RES) ; selected claim-level fields for compare mode
 K ARR
 D ADFLD(.ARR,.RES,"claim",1,"tx_kind")
 D ADFLD(.ARR,.RES,"claim",2,"guide")
 D ADFLD(.ARR,.RES,"claim",3,"total_charge")
 D ADFLD(.ARR,.RES,"claim",4,"from_date")
 D ADFLD(.ARR,.RES,"claim",5,"thru_date")
 D ADFLD(.ARR,.RES,"claim",6,"line_count")
 I MODE="core" Q
 D ADFLD(.ARR,.RES,"claim",7,"claim_id")
 D ADFLD(.ARR,.RES,"claim",8,"facility_code")
 D ADFLD(.ARR,.RES,"claim",9,"claim_freq")
 D ADFLD(.ARR,.RES,"claim",10,"claim_type")
 D ADFLD(.ARR,.RES,"claim",11,"subscriber_member_id")
 D ADFLD(.ARR,.RES,"claim",12,"patient_member_id")
 D ADFLD(.ARR,.RES,"claim",13,"billing_provider_npi")
 D ADFLD(.ARR,.RES,"claim",14,"attending_provider_id")
 D ADFLD(.ARR,.RES,"claim",15,"diag_codes")
 I MODE'="strict_structural" Q
 D ADFLD(.ARR,.RES,"claim",16,"tx_control")
 D ADFLD(.ARR,.RES,"claim",17,"subscriber_name")
 D ADFLD(.ARR,.RES,"claim",18,"patient_name")
 D ADFLD(.ARR,.RES,"claim",19,"primary_payer_name")
 D ADFLD(.ARR,.RES,"claim",20,"other_payer_name")
 D ADFLD(.ARR,.RES,"claim",21,"billing_provider_name")
 D ADFLD(.ARR,.RES,"claim",22,"attending_provider_name")
 Q
 ;
LINEFLDS(MODE,ARR,RES) ; selected line-level fields for compare mode
 K ARR
 D ADFLD(.ARR,.RES,"line",1,"service_kind")
 D ADFLD(.ARR,.RES,"line",2,"procedure_code")
 D ADFLD(.ARR,.RES,"line",3,"charge")
 D ADFLD(.ARR,.RES,"line",4,"qty")
 D ADFLD(.ARR,.RES,"line",5,"svc_date")
 I MODE="core" Q
 D ADFLD(.ARR,.RES,"line",6,"tx_kind")
 D ADFLD(.ARR,.RES,"line",7,"guide")
 D ADFLD(.ARR,.RES,"line",8,"claim_id")
 D ADFLD(.ARR,.RES,"line",9,"line_no")
 D ADFLD(.ARR,.RES,"line",10,"revenue_code")
 D ADFLD(.ARR,.RES,"line",11,"procedure_qual")
 D ADFLD(.ARR,.RES,"line",12,"uom")
 Q
 ;
ADFLD(ARR,RES,DOMAIN,SEQ,FIELD) ; add selected field metadata
 S ARR(SEQ)=FIELD
 S RES("field_group",$G(DOMAIN),$G(FIELD))=1
 S RES("summary",$G(DOMAIN)_"_fields")=+$G(RES("summary",$G(DOMAIN)_"_fields"))+1
 Q
 ;
CMPCLA(FAIL,RES,AROOT,BROOT,CFLD) ; claim-level equivalence by claim_id
 N ID,CA,CB,I,FIELD
 S ID=""
 F  S ID=$O(@AROOT@("rt","A","claim",ID)) Q:ID=""  D
 . S CA=+$G(@AROOT@("rt","A","claim",ID))
 . S CB=+$G(@BROOT@("rt","B","claim",ID))
 . I CB'>0 D MISS(.FAIL,.RES,"claim_missing",ID) Q
 . S RES("summary","claim_compared")=+$G(RES("summary","claim_compared"))+1
 . S I=0 F  S I=$O(CFLD(I)) Q:'I  D
 . . S FIELD=$G(CFLD(I)) Q:FIELD=""
 . . D CMPI(.FAIL,.RES,"claim",ID,FIELD,$G(@AROOT@("norm","claim",CA,FIELD)),$G(@BROOT@("norm","claim",CB,FIELD)))
 Q
 ;
CMPLIN(FAIL,RES,AROOT,BROOT,LFLD) ; line-level equivalence by claim_id + line_no
 N CID,LN,ID,KEY,CB,LNB,I,FIELD
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
 . . S RES("summary","line_compared")=+$G(RES("summary","line_compared"))+1
 . . S I=0 F  S I=$O(LFLD(I)) Q:'I  D
 . . . S FIELD=$G(LFLD(I)) Q:FIELD=""
 . . . D CMPI(.FAIL,.RES,"line",KEY,FIELD,$G(@AROOT@("norm","line",CID,LN,FIELD)),$G(@BROOT@("norm","line",CB,LNB,FIELD)))
 Q
 ;
EXTRA(FAIL,RES,AROOT,BROOT,KIND) ; detect keys present only on B side
 N TAG,ID,KEY
 S TAG=$S($G(KIND)="claim":"claim",1:"line")
 S KEY=""
 F  S KEY=$O(@BROOT@("rt","B",TAG,KEY)) Q:KEY=""  D
 . I $D(@AROOT@("rt","A",TAG,KEY)) Q
 . D MISS(.FAIL,.RES,KIND_"_extra",KEY)
 Q
 ;
CMPCOUNT(FAIL,RES,KEY,A,B) ; top-level counter compare
 S RES("summary","top_checks")=+$G(RES("summary","top_checks"))+1
 I +$G(A)=+$G(B) D  Q
 . S RES("summary","top_ok")=+$G(RES("summary","top_ok"))+1
 S FAIL=1
 S RES("mismatch",KEY,"left")=$G(A)
 S RES("mismatch",KEY,"right")=$G(B)
 S RES("mismatch","summary",KEY,"left")=$G(A)
 S RES("mismatch","summary",KEY,"right")=$G(B)
 S RES("summary","mismatch_count")=+$G(RES("summary","mismatch_count"))+1
 S RES("summary","top_fail")=+$G(RES("summary","top_fail"))+1
 Q
 ;
CMPI(FAIL,RES,DOMAIN,ID,FIELD,A,B) ; field compare with domain-aware reporting
 N K
 S K=$G(DOMAIN)_"_checks"
 S RES("summary",K)=+$G(RES("summary",K))+1
 I $G(A)=$G(B) D  Q
 . S RES("summary",$G(DOMAIN)_"_ok")=+$G(RES("summary",$G(DOMAIN)_"_ok"))+1
 S FAIL=1
 S RES("mismatch",ID,FIELD,"left")=$G(A)
 S RES("mismatch",ID,FIELD,"right")=$G(B)
 S RES("mismatch",$G(DOMAIN),ID,FIELD,"left")=$G(A)
 S RES("mismatch",$G(DOMAIN),ID,FIELD,"right")=$G(B)
 S RES("summary","mismatch_count")=+$G(RES("summary","mismatch_count"))+1
 S RES("summary",$G(DOMAIN)_"_fail")=+$G(RES("summary",$G(DOMAIN)_"_fail"))+1
 S RES("summary","field_fail",$G(DOMAIN),$G(FIELD))=+$G(RES("summary","field_fail",$G(DOMAIN),$G(FIELD)))+1
 Q
 ;
MISS(FAIL,RES,KIND,ID) ; missing/extra key capture
 S FAIL=1
 S RES("missing",$G(KIND),$G(ID))=1
 S RES("summary","missing_count")=+$G(RES("summary","missing_count"))+1
 S RES("summary","missing",$G(KIND))=+$G(RES("summary","missing",$G(KIND)))+1
 Q
 ;
INITSUM(RES,MODE) ; initialize compare summary container
 S RES("summary","mode")=$G(MODE)
 S RES("summary","mismatch_count")=0
 S RES("summary","missing_count")=0
 S RES("summary","top_checks")=0
 S RES("summary","top_ok")=0
 S RES("summary","top_fail")=0
 S RES("summary","claim_checks")=0
 S RES("summary","claim_ok")=0
 S RES("summary","claim_fail")=0
 S RES("summary","claim_compared")=0
 S RES("summary","line_checks")=0
 S RES("summary","line_ok")=0
 S RES("summary","line_fail")=0
 S RES("summary","line_compared")=0
 Q
 ;
MODE(OPT) ; selected compare mode from options
 Q $$NMODE($G(OPT("compare_mode")))
 ;
NMODE(MODE) ; normalize compare mode token
 S MODE=$TR($G(MODE),"-","_")
 I MODE="" Q "export_safe"
 I MODE="safe" Q "export_safe"
 I MODE="export" Q "export_safe"
 I MODE="strict" Q "strict_structural"
 I MODE="strictstructural" Q "strict_structural"
 I MODE="strict_structural" Q "strict_structural"
 I MODE="core" Q "core"
 Q "export_safe"
 ;
