EFU837W ; efuzy 837 controlled canonical writer v1
 ;
 ; Public:
 ;   WRITE(ROOT,PATH,.OPT,.RES)
 ;   FROMCSV(INBASE,PATH,ROOT,.OPT,.RES)
 ;
 ; Notes:
 ;   - deterministic internal writer for round-trip and controlled export
 ;   - writes one transaction set per canonical claim row
 ;   - defaults to transaction-only output; optional envelope wrapper
 ;   - parser-compatibility is the priority over full outbound compliance
 ;
 Q
 ;
FROMCSV(INBASE,PATH,ROOT,OPT,RES) ; load canonical csv package then write X12
 N LRES
 K RES
 I $G(ROOT)="" S ROOT=$NA(^TMP($J,"EFU837W"))
 D LOAD^EFU837CAN(INBASE,ROOT,.LRES)
 I '+$G(LRES("ok")) S RES("ok")=0,RES("error")="load_failed" M RES("load")=LRES Q
 D WRITE(ROOT,PATH,.OPT,.RES)
 M RES("load")=LRES
 Q
 ;
WRITE(ROOT,PATH,OPT,RES) ; write canonical claim package to deterministic X12
 N DEV,OLDIO,TERM,ELEM,COMP,REP,CID,TXN,GCOUNT,FIRSTG,ENV
 K RES
 S RES("ok")=0
 I $G(ROOT)="" S RES("error")="missing_root" Q
 I $G(PATH)="" S RES("error")="missing_path" Q
 I '$D(@ROOT@("canon","claim")) S RES("error")="missing_canonical" Q
 S TERM=$S($G(OPT("seg"))'="":OPT("seg"),1:"~")
 S ELEM=$S($G(OPT("elem"))'="":OPT("elem"),1:"*")
 S COMP=$S($G(OPT("comp"))'="":OPT("comp"),1:":")
 S REP=$S($G(OPT("rep"))'="":OPT("rep"),1:"^")
 S ENV=+$G(OPT("envelope"))
 S DEV=PATH,OLDIO=$IO
 O DEV:(NEWVERSION:STREAM:WRITEONLY):1
 I '$T S RES("error")="open_failed" U OLDIO Q
 U DEV
 S GCOUNT=$$CLAIMS(ROOT)
 I ENV D WISA(ELEM,REP,COMP,TERM),WGS(ROOT,1,ELEM,TERM)
 S CID=0,TXN=0,FIRSTG=""
 F  S CID=$O(@ROOT@("canon","claim",CID)) Q:'CID  D
 . N CTRL,GUIDE
 . S TXN=TXN+1
 . S CTRL=$$TXCTRL(ROOT,CID,TXN)
 . S GUIDE=$$GUIDE(ROOT,CID)
 . I FIRSTG="" S FIRSTG=GUIDE
 . D WTX(ROOT,CID,CTRL,GUIDE,ELEM,COMP,TERM,.OPT)
 I ENV D WGE(TXN,ELEM,TERM),WIEA(ELEM,TERM)
 C DEV
 U OLDIO
 S RES("ok")=1
 S RES("path")=PATH
 S RES("transactions")=TXN
 S RES("claims")=$$CLAIMS(ROOT)
 Q
 ;
WTX(ROOT,CID,CTRL,GUIDE,ELEM,COMP,TERM,OPT) ; write one canonical claim as one 837 tx
 N SEG,N,CLM,TXK,SVK,CTYP,FAC,FREQ,FROM,THRU,SDATE,PDATE
 N SUBN,SUBID,SUBDOB,SUBSEX,PATN,PATID,PATDOB,PATSEX,PAYER
 N BILLN,BILLID,ATTN,ATTID,HASPAT,LN
 S TXK=$$TXK(ROOT,CID)
 S SVK=$$SVK(ROOT,CID)
 S CTYP=$$CTYPE(ROOT,CID,TXK)
 S FAC=$$CVAL(ROOT,CID,"facility_code") I FAC="" S FAC=11
 S FREQ=$$CVAL(ROOT,CID,"claim_freq") I FREQ="" S FREQ=1
 S FROM=$$CVAL(ROOT,CID,"from_date")
 S THRU=$$CVAL(ROOT,CID,"thru_date")
 S SUBN=$$CVAL(ROOT,CID,"subscriber_name")
 S SUBID=$$CVAL(ROOT,CID,"subscriber_member_id")
 S SUBDOB=$$CVAL(ROOT,CID,"subscriber_dob")
 S SUBSEX=$$CVAL(ROOT,CID,"subscriber_sex")
 S PATN=$$CVAL(ROOT,CID,"patient_name")
 S PATID=$$CVAL(ROOT,CID,"patient_member_id")
 S PATDOB=$$CVAL(ROOT,CID,"patient_dob")
 S PATSEX=$$CVAL(ROOT,CID,"patient_sex")
 S PAYER=$$CVAL(ROOT,CID,"primary_payer_name")
 S BILLN=$$CVAL(ROOT,CID,"billing_provider_name")
 S BILLID=$$CVAL(ROOT,CID,"billing_provider_npi")
 S ATTN=$$CVAL(ROOT,CID,"attending_provider_name")
 S ATTID=$$CVAL(ROOT,CID,"attending_provider_id")
 S HASPAT=$$HASPAT(ROOT,CID)
 S N=0
 D APP(.SEG,.N,"ST"_ELEM_"837"_ELEM_CTRL_ELEM_GUIDE)
 D APP(.SEG,.N,$$BHT(ROOT,CID,ELEM))
 D APP(.SEG,.N,"HL"_ELEM_1_ELEM_ELEM_20_ELEM_1)
 D APP(.SEG,.N,"NM1"_ELEM_41_ELEM_2_ELEM_$$SAFE($$OPT("submitter_name","SUBMITTER",.OPT))_ELEM_ELEM_ELEM_ELEM_ELEM_46_ELEM_$$SAFE($$OPT("submitter_id","SUBMITTER",.OPT)))
 D APP(.SEG,.N,"NM1"_ELEM_40_ELEM_2_ELEM_$$SAFE($$OPT("receiver_name","RECEIVER",.OPT))_ELEM_ELEM_ELEM_ELEM_ELEM_46_ELEM_$$SAFE($$OPT("receiver_id","RECEIVER",.OPT)))
 I BILLN'=""!(BILLID'="") D APP(.SEG,.N,$$NM1ORG(85,BILLN,"XX",BILLID,ELEM))
 D APP(.SEG,.N,"HL"_ELEM_2_ELEM_1_ELEM_22_ELEM_$S(HASPAT:1,1:0))
 D APP(.SEG,.N,"SBR"_ELEM_"P"_ELEM_18_ELEM_ELEM_ELEM_ELEM_ELEM_ELEM_ELEM_"MC")
 D APP(.SEG,.N,$$NM1PERSON("IL",SUBN,SUBID,ELEM))
 I SUBDOB'=""!(SUBSEX'="") D APP(.SEG,.N,$$DMG(SUBDOB,SUBSEX,ELEM))
 I PAYER'="" D APP(.SEG,.N,$$NM1ORG("PR",PAYER,"PI","PAYER",ELEM))
 I HASPAT D
 . D APP(.SEG,.N,"HL"_ELEM_3_ELEM_2_ELEM_23_ELEM_0)
 . D APP(.SEG,.N,"PAT"_ELEM_19)
 . D APP(.SEG,.N,$$NM1PERSON("IL",PATN,PATID,ELEM))
 . I PATDOB'=""!(PATSEX'="") D APP(.SEG,.N,$$DMG(PATDOB,PATSEX,ELEM))
 D APP(.SEG,.N,$$CLM(ROOT,CID,CTYP,FAC,FREQ,ELEM,COMP))
 I FROM'="" D APP(.SEG,.N,$$DTP434(FROM,THRU,ELEM,COMP))
 D HI(ROOT,CID,.SEG,.N,ELEM,COMP)
 I ATTN'=""!(ATTID'="") D APP(.SEG,.N,$$NM1PERSON("71",ATTN,ATTID,ELEM))
 S LN=0
 F  S LN=$O(@ROOT@("canon","claim",CID,"line",LN)) Q:'LN  D
 . D APP(.SEG,.N,"LX"_ELEM_+$G(@ROOT@("canon","claim",CID,"line",LN,"line_no"),LN))
 . D APP(.SEG,.N,$$SV(ROOT,CID,LN,SVK,ELEM,COMP))
 . S SDATE=$G(@ROOT@("canon","claim",CID,"line",LN,"svc_date"))
 . I SDATE="" S SDATE=FROM
 . I SDATE'="" D APP(.SEG,.N,"DTP"_ELEM_472_ELEM_"D8"_ELEM_SDATE)
 D APP(.SEG,.N,"SE"_ELEM_(N+1)_ELEM_CTRL)
 D WSEG(.SEG,N,TERM)
 Q
 ;
APP(SEG,N,TXT) ; append one segment to local segment array
 S N=+$G(N)+1
 S SEG(N)=$G(TXT)
 Q
 ;
WSEG(SEG,N,TERM) ; write N local segments
 N I
 F I=1:1:+$G(N) W $G(SEG(I))_$G(TERM)
 Q
 ;
WISA(ELEM,REP,COMP,TERM) ; deterministic single ISA wrapper
 N SND,RCV
 S SND=$$PAD($$SAFE("SENDERID1234567"),15)
 S RCV=$$PAD($$SAFE("RECEIVER123456"),15)
 W "ISA"_ELEM_"00"_ELEM_"          "_ELEM_"00"_ELEM_"          "_ELEM_"ZZ"_ELEM_SND_ELEM_"ZZ"_ELEM_RCV_ELEM_"260311"_ELEM_"1200"_ELEM_REP_ELEM_"00501"_ELEM_"000000001"_ELEM_0_ELEM_"T"_ELEM_COMP_TERM
 Q
 ;
WGS(ROOT,CTRL,ELEM,TERM) ; deterministic single GS wrapper
 N GUIDE
 S GUIDE=$$GUIDE(ROOT,$O(@ROOT@("canon","claim",0)))
 W "GS"_ELEM_"HC"_ELEM_"SENDER"_ELEM_"RECV"_ELEM_"20260311"_ELEM_"1200"_ELEM_+$G(CTRL)_ELEM_"X"_ELEM_GUIDE_TERM
 Q
 ;
WGE(CNT,ELEM,TERM) W "GE"_ELEM_+$G(CNT)_ELEM_1_TERM Q
WIEA(ELEM,TERM) W "IEA"_ELEM_1_ELEM_"000000001"_TERM Q
 ;
CLAIMS(ROOT) ; canonical claim count
 Q +$G(@ROOT@("canon","claims"))
 ;
TXCTRL(ROOT,CID,SEQ) ; deterministic transaction control
 N X
 S X=$$CVAL(ROOT,CID,"tx_control")
 I X'="" Q X
 Q +$G(SEQ)
 ;
GUIDE(ROOT,CID) ; best-effort guide
 N G,T
 S G=$$CVAL(ROOT,+$G(CID),"guide")
 I G'="" Q G
 S T=$$TXK(ROOT,+$G(CID))
 I T="837I" Q "005010X223A2"
 I T="837D" Q "005010X224A2"
 Q "005010X222A1"
 ;
TXK(ROOT,CID) ; best-effort tx kind
 N T,G,SV
 S T=$$UC^EFU837U($$CVAL(ROOT,CID,"tx_kind")) I T'="" Q T
 S G=$$GUIDE(ROOT,CID),T=$$KIND^EFU837SPEC(G) I T'="" Q T
 S SV=$$SVK(ROOT,CID)
 I SV="SV2" Q "837I"
 I SV="SV3" Q "837D"
 Q "837P"
 ;
SVK(ROOT,CID) ; best-effort required service segment kind
 N LN,S
 S S=$$REQSVC^EFU837SPEC($$GUIDE(ROOT,CID)) I S'="" Q S
 S LN=$O(@ROOT@("canon","claim",CID,"line",0))
 I LN>0,$G(@ROOT@("canon","claim",CID,"line",LN,"service_kind"))'="" Q $G(@ROOT@("canon","claim",CID,"line",LN,"service_kind"))
 Q "SV1"
 ;
CTYPE(ROOT,CID,TXK) ; claim type code carried in CLM07 in current samples
 N X
 S X=$$CVAL(ROOT,CID,"claim_type")
 I X'="" Q X
 I $G(TXK)="837I" Q "I"
 I $G(TXK)="837D" Q "D"
 Q "Y"
 ;
CVAL(ROOT,CID,KEY) ; canonical claim field
 Q $G(@ROOT@("canon","claim",+$G(CID),$G(KEY)))
 ;
HASPAT(ROOT,CID) ; whether a distinct patient loop should be emitted
 N SN,SID,PN,PID
 S SN=$$CVAL(ROOT,CID,"subscriber_name")
 S SID=$$CVAL(ROOT,CID,"subscriber_member_id")
 S PN=$$CVAL(ROOT,CID,"patient_name")
 S PID=$$CVAL(ROOT,CID,"patient_member_id")
 I PN="",PID="" Q 0
 I PN=SN,PID=SID Q 0
 Q 1
 ;
BHT(ROOT,CID,ELEM) ; deterministic BHT
 N REF,DATE,TIME
 S REF=$$SAFE($$CVAL(ROOT,CID,"claim_id"))
 I REF="" S REF="BHT"_CID
 S DATE=$$CVAL(ROOT,CID,"from_date") I DATE="" S DATE="20260311"
 S TIME="1200"
 Q "BHT"_ELEM_"0019"_ELEM_"00"_ELEM_REF_ELEM_DATE_ELEM_TIME_ELEM_"CH"
 ;
CLM(ROOT,CID,CTYPE,FAC,FREQ,ELEM,COMP) ; claim segment
 N ID,AMT
 S ID=$$SAFE($$CVAL(ROOT,CID,"claim_id")) I ID="" S ID="CLM"_CID
 S AMT=$$SAFE($$CVAL(ROOT,CID,"total_charge")) I AMT="" S AMT=0
 Q "CLM"_ELEM_ID_ELEM_AMT_ELEM_ELEM_ELEM_FAC_COMP_"B"_COMP_FREQ_ELEM_"Y"_ELEM_"A"_ELEM_"Y"_ELEM_$$SAFE(CTYPE)
 ;
DTP434(FROM,THRU,ELEM,COMP) ; claim date segment
 I $G(THRU)=""!($G(THRU)=$G(FROM)) Q "DTP"_ELEM_434_ELEM_"D8"_ELEM_$$SAFE(FROM)
 Q "DTP"_ELEM_434_ELEM_"RD8"_ELEM_$$SAFE(FROM)_"-"_$$SAFE(THRU)
 ;
HI(ROOT,CID,SEG,N,ELEM,COMP) ; claim diagnosis list
 N X,I,CODES,OUT,C
 S CODES=$$CVAL(ROOT,CID,"diag_codes")
 I CODES="" Q
 S OUT="HI",I=0
 F I=1:1:$L(CODES,"|") D
 . S C=$P(CODES,"|",I) Q:C=""
 . S OUT=OUT_ELEM_"BK"_COMP_$$SAFE(C)
 D APP(.SEG,.N,OUT)
 Q
 ;
SV(ROOT,CID,LN,SVK,ELEM,COMP) ; one service detail segment
 N REV,PQ,PC,AMT,UOM,QTY
 S REV=$G(@ROOT@("canon","claim",CID,"line",LN,"revenue_code"))
 S PQ=$G(@ROOT@("canon","claim",CID,"line",LN,"procedure_qual")) I PQ="" S PQ="HC"
 S PC=$G(@ROOT@("canon","claim",CID,"line",LN,"procedure_code"))
 S AMT=$G(@ROOT@("canon","claim",CID,"line",LN,"charge")) I AMT="" S AMT=0
 S UOM=$G(@ROOT@("canon","claim",CID,"line",LN,"uom")) I UOM="" S UOM="UN"
 S QTY=$G(@ROOT@("canon","claim",CID,"line",LN,"qty")) I QTY="" S QTY=1
 I $G(SVK)="SV2" Q "SV2"_ELEM_$$SAFE(REV)_ELEM_$$SAFE(PQ)_COMP_$$SAFE(PC)_ELEM_AMT_ELEM_UOM_ELEM_QTY
 I $G(SVK)="SV3" Q "SV3"_ELEM_$$SAFE(PQ)_COMP_$$SAFE(PC)_ELEM_AMT_ELEM_UOM_ELEM_QTY
 Q "SV1"_ELEM_$$SAFE(PQ)_COMP_$$SAFE(PC)_ELEM_AMT_ELEM_UOM_ELEM_QTY_ELEM_ELEM_ELEM_1
 ;
DMG(DOB,SEX,ELEM) ; simple DMG
 Q "DMG"_ELEM_"D8"_ELEM_$$SAFE(DOB)_ELEM_$$SAFE(SEX)
 ;
NM1PERSON(ENT,NAME,ID,ELEM) ; simple NM1 person emitter
 N LAST,FIRST,MID
 D SPLITN($G(NAME),.LAST,.FIRST,.MID)
 I LAST="" S LAST=$G(NAME)
 Q "NM1"_ELEM_$$SAFE(ENT)_ELEM_1_ELEM_$$SAFE(LAST)_ELEM_$$SAFE(FIRST)_ELEM_$$SAFE(MID)_ELEM_ELEM_ELEM_"MI"_ELEM_$$SAFE(ID)
 ;
NM1ORG(ENT,NAME,QUAL,ID,ELEM) ; simple NM1 org emitter
 Q "NM1"_ELEM_$$SAFE(ENT)_ELEM_2_ELEM_$$SAFE(NAME)_ELEM_ELEM_ELEM_ELEM_ELEM_$$SAFE(QUAL)_ELEM_$$SAFE(ID)
 ;
SPLITN(NAME,LAST,FIRST,MID) ; split "LAST, FIRST M" into parts
 N T
 S LAST="",FIRST="",MID=""
 S T=$$TRIM^EFU837U($G(NAME))
 I T="" Q
 I T'["," S LAST=T Q
 S LAST=$$TRIM^EFU837U($P(T,",",1))
 S FIRST=$$TRIM^EFU837U($P($P(T,",",2,99)," ",1))
 S MID=$$TRIM^EFU837U($P($P(T,",",2,99)," ",2,99))
 Q
 ;
PAD(X,N) ; right-pad or trim to exact width
 N Y
 S Y=$E($G(X),1,+$G(N))
 F  Q:$L(Y)'<+$G(N)  S Y=Y_" "
 Q Y
 ;
SAFE(X) ; remove delimiters from free text deterministically
 N Y
 S Y=$G(X)
 S Y=$TR(Y,"*~:^","    ")
 Q $$TRIM^EFU837U(Y)
 ;
OPT(KEY,DFLT,OPT) ; option value helper
 Q $S($G(OPT($G(KEY)))'="":OPT($G(KEY)),1:$G(DFLT))
 ;
