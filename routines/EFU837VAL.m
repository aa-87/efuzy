EFU837VAL ; efuzy X12 837 validation helpers
 ;
 ; Public:
 ;   POST(ROOT,.RES)
 ;
 Q
 ;
POST(ROOT,RES) ; post-parse validation sweep
 N TX,CID,CLM,FRAME
 K RES
 S FRAME=$G(@ROOT@("meta","delim","framing"))
 I FRAME="transaction" D
 . I '$D(@ROOT@("meta","isa","control")) D ADDDIAG^EFU837U(ROOT,"warning","tx_only_no_isa","Transaction-only sample does not include ISA/IEA envelope",0,"ISA")
 E  D
 . I '$D(@ROOT@("meta","isa","control")) D MISS(ROOT,"missing_isa","ISA segment not found",0,"ISA")
 . I '$D(@ROOT@("meta","iea","control")) D MISS(ROOT,"missing_iea","IEA segment not found",0,"IEA")
 I +$G(@ROOT@("stats","transactions"))=0 D ADDDIAG^EFU837U(ROOT,"error","no_transactions","No ST/SE transaction set was parsed",0,"ST")
 I +$G(@ROOT@("stats","claims"))=0 D ADDDIAG^EFU837U(ROOT,"warning","no_claims","File parsed but no CLM segments were found",0,"CLM")
 S TX=0
 F  S TX=$O(@ROOT@("tx",TX)) Q:'TX  D
 . I '$D(@ROOT@("tx",TX,"st","control")) D ADDDIAG^EFU837U(ROOT,"error","missing_st_control","ST02 missing",0,"ST")
 . I '$D(@ROOT@("tx",TX,"se","control")) D ADDDIAG^EFU837U(ROOT,"error","missing_se","SE segment missing for transaction",0,"SE")
 S CID=0
 F  S CID=$O(@ROOT@("claim",CID)) Q:'CID  D
 . S CLM=$G(@ROOT@("claim",CID,"claim_id"))
 . I CLM="" D ADDDIAG^EFU837U(ROOT,"error","claim_id_missing","CLM01 missing on claim",+$G(@ROOT@("claim",CID,"segno")),"CLM")
 . I $G(@ROOT@("claim",CID,"sub"))="" D ADDDIAG^EFU837U(ROOT,"warning","claim_sub_missing","Claim not linked to subscriber loop",+$G(@ROOT@("claim",CID,"segno")),"CLM")
 S RES("ok")=$S(+$G(@ROOT@("stats","error"))>0:0,1:1)
 S RES("errors")=+$G(@ROOT@("stats","error"))
 S RES("warnings")=+$G(@ROOT@("stats","warning"))
 Q
 ;
MISS(ROOT,CODE,MSG,SEGNO,SEGID) ; missing envelope diag with optional lenient downgrade
 N SEV,OK
 S OK=($G(@ROOT@("meta","lenient"))=1)!($G(@ROOT@("meta","accept_bad_envelope"))=1)
 S SEV=$S(OK:"warning",1:"error")
 D ADDDIAG^EFU837U(ROOT,SEV,$G(CODE),$G(MSG),+$G(SEGNO),$G(SEGID))
 Q
 ;
