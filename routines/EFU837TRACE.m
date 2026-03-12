EFU837TRACE ; efuzy 837 traceability and audit helpers
 ;
 ; Public:
 ;   BUILD(ROOT,.OPT,.RES)
 ;
 ; Notes:
 ;   - builds source-to-output trace metadata on top of parsed/normalized trees
 ;   - focuses on normalized claim/line fields used by preview/export/audit flows
 ;   - keeps backward compatibility by using best-effort segment provenance when
 ;     exact segment ordinals are not persisted in the parsed tree
 ;
 Q
 ;
BUILD(ROOT,OPT,RES) ; build trace metadata under @ROOT@(\"trace\")
 N NRES,CID,LN,CC,LC,TX,SID,PID
 K RES
 K @ROOT@("trace")
 I '$D(@ROOT@("norm","claim")) D BUILD^EFU837N(ROOT,.OPT,.NRES)
 S CID=0,CC=0,LC=0
 F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
 . S CC=CC+1
 . S TX=+$G(@ROOT@("norm","claim",CID,"tx"))
 . S SID=+$G(@ROOT@("norm","claim",CID,"subscriber_id"))
 . S PID=+$G(@ROOT@("norm","claim",CID,"patient_id"))
 . D CTRACE(ROOT,CID,TX,SID,PID)
 . S LN=0
 . F  S LN=$O(@ROOT@("norm","line",CID,LN)) Q:'LN  D
 . . S LC=LC+1
 . . D LTRACE(ROOT,CID,LN)
 S @ROOT@("trace","summary","claims")=CC
 S @ROOT@("trace","summary","lines")=LC
 S RES("ok")=1
 S RES("claims")=CC
 S RES("lines")=LC
 S RES("fields")=+$G(@ROOT@("trace","summary","fields"))
 S RES("segments")=+$G(@ROOT@("trace","summary","segments"))
 Q
 ;
CTRACE(ROOT,CID,TX,SID,PID) ; claim-level trace rows
 N CLMSEG,STSEG,PK,PSEG,PEX,SSEG,SSEX,DSEG,DEX,DISEG,DIEX
 N BSEG,BEX,ASEG,AEX,PRSEG,PREX,VAL
 S CLMSEG=+$G(@ROOT@("claim",CID,"segno"))
 S STSEG=+$G(@ROOT@("tx",TX,"st","segno"))
 S PK=$$PATK(ROOT,SID,PID)
 ; tx-level / structural
 D SETC(ROOT,CID,"tx_kind",$G(@ROOT@("norm","claim",CID,"tx_kind")),"ST",STSEG,"tx."_TX_".st.guide",$S(STSEG>0:1,1:0),"")
 D SETC(ROOT,CID,"guide",$G(@ROOT@("norm","claim",CID,"guide")),"ST",STSEG,"tx."_TX_".st.guide",$S(STSEG>0:1,1:0),"")
 D SETC(ROOT,CID,"tx_control",$G(@ROOT@("norm","claim",CID,"tx_control")),"ST",STSEG,"tx."_TX_".st.control",$S(STSEG>0:1,1:0),"")
 ; claim header
 D SETC(ROOT,CID,"claim_id",$G(@ROOT@("norm","claim",CID,"claim_id")),"CLM",CLMSEG,"claim."_CID_".claim_id",$S(CLMSEG>0:1,1:0),"")
 D SETC(ROOT,CID,"total_charge",$G(@ROOT@("norm","claim",CID,"total_charge")),"CLM",CLMSEG,"claim."_CID_".total_charge",$S(CLMSEG>0:1,1:0),"")
 D SETC(ROOT,CID,"facility_code",$G(@ROOT@("norm","claim",CID,"facility_code")),"CLM",CLMSEG,"claim."_CID_".facility_code",$S(CLMSEG>0:1,1:0),"")
 D SETC(ROOT,CID,"claim_freq",$G(@ROOT@("norm","claim",CID,"claim_freq")),"CLM",CLMSEG,"claim."_CID_".claim_freq",$S(CLMSEG>0:1,1:0),"")
 D SETC(ROOT,CID,"claim_type",$G(@ROOT@("norm","claim",CID,"claim_type")),"CLM",CLMSEG,"claim."_CID_".claim_type",$S(CLMSEG>0:1,1:0),"")
 ; claim dates
 S DSEG=+$G(@ROOT@("claim",CID,"dtp","434","segno")),DEX=$S(DSEG>0:1,1:0)
 I 'DSEG S DSEG=CLMSEG
 D SETC(ROOT,CID,"from_date",$G(@ROOT@("norm","claim",CID,"from_date")),"DTP",DSEG,"claim."_CID_".dtp.434",DEX,$S(DEX:"",1:"fallback_claim_segno"))
 D SETC(ROOT,CID,"thru_date",$G(@ROOT@("norm","claim",CID,"thru_date")),"DTP",DSEG,"claim."_CID_".dtp.434",DEX,$S(DEX:"",1:"fallback_claim_segno"))
 ; diagnosis list
 S DISEG=+$G(@ROOT@("claim",CID,"diag",1,"segno")),DIEX=$S(DISEG>0:1,1:0)
 I 'DISEG S DISEG=CLMSEG
 D SETC(ROOT,CID,"diag_codes",$G(@ROOT@("norm","claim",CID,"diag_codes")),"HI",DISEG,"claim."_CID_".diag",DIEX,$S(DIEX:"",1:"fallback_claim_segno"))
 ; subscriber / patient parties
 S SSEG=+$G(@ROOT@("sub",SID,"name","segno")),SSEX=$S(SSEG>0:1,1:0) I 'SSEG S SSEG=CLMSEG
 D SETC(ROOT,CID,"subscriber_name",$G(@ROOT@("norm","claim",CID,"subscriber_name")),"NM1",SSEG,"sub."_SID_".name",SSEX,$S(SSEX:"",1:"fallback_claim_segno"))
 D SETC(ROOT,CID,"subscriber_member_id",$G(@ROOT@("norm","claim",CID,"subscriber_member_id")),"NM1",SSEG,"sub."_SID_".name.id",SSEX,$S(SSEX:"",1:"fallback_claim_segno"))
 S PSEG=$$PSEG(ROOT,PK,PID,CLMSEG),PEX=$$PEXACT(ROOT,PK,PID)
 D SETC(ROOT,CID,"patient_name",$G(@ROOT@("norm","claim",CID,"patient_name")),"NM1",PSEG,$$PNODE(PK,PID),PEX,$S(PEX:"",1:"fallback_claim_segno"))
 D SETC(ROOT,CID,"patient_member_id",$G(@ROOT@("norm","claim",CID,"patient_member_id")),"NM1",PSEG,$$PNODE(PK,PID)_".id",PEX,$S(PEX:"",1:"fallback_claim_segno"))
 S PRSEG=+$G(@ROOT@("sub",SID,"payer","name","segno")),PREX=$S(PRSEG>0:1,1:0) I 'PRSEG S PRSEG=CLMSEG
 D SETC(ROOT,CID,"primary_payer_name",$G(@ROOT@("norm","claim",CID,"primary_payer_name")),"NM1",PRSEG,"sub."_SID_".payer.name",PREX,$S(PREX:"",1:"fallback_claim_segno"))
 ; billing provider / attending provider
 S BSEG=+$G(@ROOT@("tx",TX,"billing","name","segno")),BEX=$S(BSEG>0:1,1:0) I 'BSEG S BSEG=STSEG
 D SETC(ROOT,CID,"billing_provider_name",$G(@ROOT@("norm","claim",CID,"billing_provider_name")),"NM1",BSEG,"tx."_TX_".billing.name",BEX,$S(BEX:"",1:"fallback_st_segno"))
 D SETC(ROOT,CID,"billing_provider_npi",$G(@ROOT@("norm","claim",CID,"billing_provider_npi")),"NM1",BSEG,"tx."_TX_".billing.name.id",BEX,$S(BEX:"",1:"fallback_st_segno"))
 S ASEG=+$G(@ROOT@("claim",CID,"provider","71","name","segno")),AEX=$S(ASEG>0:1,1:0) I 'ASEG S ASEG=CLMSEG
 D SETC(ROOT,CID,"attending_provider_name",$G(@ROOT@("norm","claim",CID,"attending_provider_name")),"NM1",ASEG,"claim."_CID_".provider.71.name",AEX,$S(AEX:"",1:"fallback_claim_segno"))
 D SETC(ROOT,CID,"attending_provider_id",$G(@ROOT@("norm","claim",CID,"attending_provider_id")),"NM1",ASEG,"claim."_CID_".provider.71.name.id",AEX,$S(AEX:"",1:"fallback_claim_segno"))
 ; output-only helpful count
 D SETC(ROOT,CID,"line_count",$G(@ROOT@("norm","claim",CID,"line_count")),"CLM",CLMSEG,"claim."_CID_".line_last",$S(CLMSEG>0:1,1:0),"derived_from_claim")
 Q
 ;
LTRACE(ROOT,CID,LN) ; line-level trace rows
 N LXSEG,SVCSEG,SVSEGID,SVEX,DSEG,DEX,CLMSEG
 S CLMSEG=+$G(@ROOT@("claim",CID,"segno"))
 S LXSEG=+$G(@ROOT@("claim",CID,"line",LN,"segno"))
 S SVCSEG=+$G(@ROOT@("claim",CID,"line",LN,"svc_segno"))
 S SVSEGID=$G(@ROOT@("claim",CID,"line",LN,"service_kind")) I SVSEGID="" S SVSEGID="SV"
 S SVEX=$S(SVCSEG>0:1,1:0) I 'SVCSEG S SVCSEG=LXSEG I 'SVCSEG S SVCSEG=CLMSEG
 D SETL(ROOT,CID,LN,"claim_id",$G(@ROOT@("norm","line",CID,LN,"claim_id")),"CLM",CLMSEG,"claim."_CID_".claim_id",$S(CLMSEG>0:1,1:0),"")
 D SETL(ROOT,CID,LN,"line_no",$G(@ROOT@("norm","line",CID,LN,"line_no")),"LX",LXSEG,"claim."_CID_".line."_LN_".line_no",$S(LXSEG>0:1,1:0),"")
 D SETL(ROOT,CID,LN,"service_kind",$G(@ROOT@("norm","line",CID,LN,"service_kind")),SVSEGID,SVCSEG,"claim."_CID_".line."_LN_".service_kind",SVEX,$S(SVEX:"",1:"fallback_lx_or_claim_segno"))
 D SETL(ROOT,CID,LN,"revenue_code",$G(@ROOT@("norm","line",CID,LN,"revenue_code")),SVSEGID,SVCSEG,"claim."_CID_".line."_LN_".revenue_code",SVEX,$S(SVEX:"",1:"fallback_lx_or_claim_segno"))
 D SETL(ROOT,CID,LN,"procedure_qual",$G(@ROOT@("norm","line",CID,LN,"procedure_qual")),SVSEGID,SVCSEG,"claim."_CID_".line."_LN_".proc_qual",SVEX,$S(SVEX:"",1:"fallback_lx_or_claim_segno"))
 D SETL(ROOT,CID,LN,"procedure_code",$G(@ROOT@("norm","line",CID,LN,"procedure_code")),SVSEGID,SVCSEG,"claim."_CID_".line."_LN_".proc_code",SVEX,$S(SVEX:"",1:"fallback_lx_or_claim_segno"))
 D SETL(ROOT,CID,LN,"charge",$G(@ROOT@("norm","line",CID,LN,"charge")),SVSEGID,SVCSEG,"claim."_CID_".line."_LN_".charge",SVEX,$S(SVEX:"",1:"fallback_lx_or_claim_segno"))
 D SETL(ROOT,CID,LN,"uom",$G(@ROOT@("norm","line",CID,LN,"uom")),SVSEGID,SVCSEG,"claim."_CID_".line."_LN_".uom",SVEX,$S(SVEX:"",1:"fallback_lx_or_claim_segno"))
 D SETL(ROOT,CID,LN,"qty",$G(@ROOT@("norm","line",CID,LN,"qty")),SVSEGID,SVCSEG,"claim."_CID_".line."_LN_".qty",SVEX,$S(SVEX:"",1:"fallback_lx_or_claim_segno"))
 S DSEG=+$G(@ROOT@("claim",CID,"line",LN,"dtp","472","segno")),DEX=$S(DSEG>0:1,1:0)
 I 'DSEG S DSEG=LXSEG I 'DSEG S DSEG=CLMSEG
 D SETL(ROOT,CID,LN,"svc_date",$G(@ROOT@("norm","line",CID,LN,"svc_date")),"DTP",DSEG,"claim."_CID_".line."_LN_".dtp.472",DEX,$S(DEX:"",1:"fallback_lx_or_claim_segno"))
 D SETL(ROOT,CID,LN,"tx_kind",$G(@ROOT@("norm","line",CID,LN,"tx_kind")),"ST",+$G(@ROOT@("tx",+$G(@ROOT@("norm","claim",CID,"tx")),"st","segno")),"norm.claim."_CID_".tx_kind",1,"derived_from_tx")
 D SETL(ROOT,CID,LN,"guide",$G(@ROOT@("norm","line",CID,LN,"guide")),"ST",+$G(@ROOT@("tx",+$G(@ROOT@("norm","claim",CID,"tx")),"st","segno")),"norm.claim."_CID_".guide",1,"derived_from_tx")
 Q
 ;
SETC(ROOT,CID,FIELD,VALUE,SEGID,SEGNO,NODE,EXACT,NOTE) ; one claim trace field
 N T
 S T=$NA(@ROOT@("trace","claim",CID,"field",FIELD))
 S @T@("value")=$G(VALUE)
 S @T@("segid")=$G(SEGID)
 S @T@("segno")=+$G(SEGNO)
 S @T@("node")=$G(NODE)
 S @T@("exact_segno")=+$G(EXACT)
 S @T@("note")=$G(NOTE)
 D IDX(ROOT,"claim",CID,0,FIELD,+$G(SEGNO))
 S @ROOT@("trace","summary","fields")=+$G(@ROOT@("trace","summary","fields"))+1
 Q
 ;
SETL(ROOT,CID,LN,FIELD,VALUE,SEGID,SEGNO,NODE,EXACT,NOTE) ; one line trace field
 N T
 S T=$NA(@ROOT@("trace","line",CID,LN,"field",FIELD))
 S @T@("value")=$G(VALUE)
 S @T@("segid")=$G(SEGID)
 S @T@("segno")=+$G(SEGNO)
 S @T@("node")=$G(NODE)
 S @T@("exact_segno")=+$G(EXACT)
 S @T@("note")=$G(NOTE)
 D IDX(ROOT,"line",CID,LN,FIELD,+$G(SEGNO))
 S @ROOT@("trace","summary","fields")=+$G(@ROOT@("trace","summary","fields"))+1
 Q
 ;
IDX(ROOT,AREA,CID,LN,FIELD,SEGNO) ; reverse segment index for audit lookups
 I +$G(SEGNO)'>0 Q
 I '$D(@ROOT@("trace","seg",SEGNO)) S @ROOT@("trace","summary","segments")=+$G(@ROOT@("trace","summary","segments"))+1
 I AREA="claim" S @ROOT@("trace","seg",SEGNO,"claim",CID,"field",FIELD)=""
 I AREA="line" S @ROOT@("trace","seg",SEGNO,"line",CID,LN,"field",FIELD)=""
 Q
 ;
PATK(ROOT,SID,PID) ; effective patient namespace
 I +$G(PID)>0,$D(@ROOT@("patient",+$G(PID))) Q "patient"
 Q "sub"
 ;
PSEG(ROOT,KIND,ID,DEF) ; best-effort patient/subscriber name segno
 N SEG
 S SEG=0
 I $G(KIND)="patient" S SEG=+$G(@ROOT@("patient",+$G(ID),"name","segno"))
 I $G(KIND)="sub" S SEG=+$G(@ROOT@("sub",+$G(ID),"name","segno"))
 I SEG'>0 S SEG=+$G(DEF)
 Q SEG
 ;
PEXACT(ROOT,KIND,ID) ; exact patient/subscriber segno presence
 I $G(KIND)="patient" Q $S(+$G(@ROOT@("patient",+$G(ID),"name","segno"))>0:1,1:0)
 I $G(KIND)="sub" Q $S(+$G(@ROOT@("sub",+$G(ID),"name","segno"))>0:1,1:0)
 Q 0
 ;
PNODE(KIND,ID) ; logical patient/subscriber node path
 I $G(KIND)="patient" Q "patient."_+$G(ID)_".name"
 Q "sub."_+$G(ID)_".name"
 ;
