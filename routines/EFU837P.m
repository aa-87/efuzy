EFU837P ; efuzy X12 837 parser foundation
 ;
 ; Public:
 ;   PARSE(PATH,ROOT,.OPT,.RES)
 ;   PARSEONLY(PATH,ROOT,.OPT,.RES)
 ;   PREVIEW(PATH,ROOT,.OPT,.RES)
 ;
 ; Notes:
 ;   - streaming scanner reads a file in chunks and emits one segment at a time
 ;   - parser stores only normalized working data and targeted raw values
 ;   - parser does not retain the entire file or every raw segment
 ;
 Q
 ;
PARSE(PATH,ROOT,OPT,RES) ; full parse + normalize + validate
 N NRES,VRES
 D PARSEONLY(PATH,ROOT,.OPT,.RES)
 I '+$G(RES("ok")) Q
 D BUILD^EFU837N(ROOT,.OPT,.NRES)
 D POST^EFU837VAL(ROOT,.VRES)
 S RES("ok")=$S(+$G(@ROOT@("stats","error"))>0:0,1:1)
 S RES("claims")=+$G(@ROOT@("stats","claims"))
 S RES("lines")=+$G(@ROOT@("stats","lines"))
 S RES("transactions")=+$G(@ROOT@("stats","transactions"))
 S RES("warnings")=+$G(@ROOT@("stats","warning"))
 S RES("errors")=+$G(@ROOT@("stats","error"))
 Q
 ;
PREVIEW(PATH,ROOT,OPT,RES) ; parse but skip heavier normalization
 S OPT("mode")="preview"
 D PARSEONLY(PATH,ROOT,.OPT,.RES)
 I '+$G(RES("ok")) Q
 D POST^EFU837VAL(ROOT,.RES)
 S RES("claims")=+$G(@ROOT@("stats","claims"))
 S RES("lines")=+$G(@ROOT@("stats","lines"))
 S RES("transactions")=+$G(@ROOT@("stats","transactions"))
 S RES("segments")=+$G(@ROOT@("stats","segment_total"))
 Q
 ;
PARSEONLY(PATH,ROOT,OPT,RES) ; streaming parse only
 N SCAN,ERR,EOF,SEG,STATE
 I $G(ROOT)="" S ROOT=$NA(^TMP($J,"EFU837"))
 D INIT^EFU837U(ROOT,.OPT)
 K RES
 S RES("ok")=0
 S @ROOT@("meta","file","path")=$G(PATH)
 D OPEN^EFU837S(PATH,.SCAN,.OPT,.ERR)
 I +$G(ERR) D  Q
 . D ADDDIAG^EFU837U(ROOT,"error","open_failed","Unable to open or inspect input file",0,"FILE")
 . S RES("error")="open_failed"
 D INITST(.STATE)
 M STATE("del")=SCAN("del")
 M @ROOT@("meta","delim")=SCAN("del")
 F  D  Q:EOF!(+$G(ERR))
 . D NEXT^EFU837S(.SCAN,.SEG,.EOF,.ERR)
 . I EOF Q
 . I +$G(ERR) Q
 . D ONSEG(ROOT,.STATE,.SEG,SCAN("segno"))
 D CLOSE^EFU837S(.SCAN)
 I +$G(ERR) D ADDDIAG^EFU837U(ROOT,"error","scan_error","Scanner aborted while reading file",+$G(SCAN("segno")),"")
 I $G(STATE("tx"))>0 D ADDDIAG^EFU837U(ROOT,"error","unterminated_tx","Transaction ended without SE",+$G(SCAN("segno")),"SE")
 S RES("ok")=$S(+$G(@ROOT@("stats","error"))>0:0,1:1)
 S RES("claims")=+$G(@ROOT@("stats","claims"))
 S RES("lines")=+$G(@ROOT@("stats","lines"))
 S RES("transactions")=+$G(@ROOT@("stats","transactions"))
 S RES("segments")=+$G(@ROOT@("stats","segment_total"))
 Q
 ;
INITST(STATE) ; initialize parser state
 K STATE
 S STATE("tx")=0
 S STATE("group")=0
 S STATE("claim")=0
 S STATE("line")=0
 S STATE("sub")=0
 S STATE("patient")=0
 S STATE("other_sub")=0
 S STATE("scope")=""
 S STATE("last","kind")=""
 S STATE("last","role")=""
 S STATE("last","id")=0
 S STATE("txseg")=0
 Q
 ;
ONSEG(ROOT,STATE,SEG,SEGNO) ; tokenize and handle one segment
 N TOK,ID
 D TOK(SEG,$G(STATE("del","elem")),.TOK)
 S ID=$G(TOK("id"))
 I ID="" Q
 S @ROOT@("stats","segment_total")=+$G(@ROOT@("stats","segment_total"))+1
 S @ROOT@("stats","segment",ID)=+$G(@ROOT@("stats","segment",ID))+1
 I $G(STATE("tx"))>0,ID'="ST" S STATE("txseg")=+$G(STATE("txseg"))+1
 I ID="ISA" D HISA(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="IEA" D HIEA(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="GS" D HGS(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="GE" D HGE(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="ST" D HST(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="SE" D HSE(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="BHT" D HBHT(ROOT,.STATE,.TOK) Q
 I ID="HL" D HHL(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="SBR" D HSBR(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="PAT" D HPAT(ROOT,.STATE,.TOK) Q
 I ID="NM1" D HNM1(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="PER" D HPER(ROOT,.STATE,.TOK) Q
 I ID="N3" D HN3(ROOT,.STATE,.TOK) Q
 I ID="N4" D HN4(ROOT,.STATE,.TOK) Q
 I ID="REF" D HREF(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="DMG" D HDMG(ROOT,.STATE,.TOK) Q
 I ID="CLM" D HCLM(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="CL1" D HCL1(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="DTP" D HDTP(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="HI" D HHI(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="OI" D HOI(ROOT,.STATE,.TOK,SEGNO) Q
 I ID="LX" D HLX(ROOT,.STATE,.TOK,SEGNO) Q
 I (ID="SV1")!(ID="SV2")!(ID="SV3") D HSV(ROOT,.STATE,.TOK,SEGNO,ID) Q
 Q
 ;
TOK(SEG,SEP,TOK) ; segment tokenizer
 N I,N
 K TOK
 S TOK("id")=$P(SEG,SEP,1)
 S N=$L(SEG,SEP)
 S TOK("n")=N-1
 F I=2:1:N S TOK(I-1)=$P(SEG,SEP,I)
 Q
 ;
HISA(ROOT,STATE,TOK,SEGNO) ; ISA envelope
 S @ROOT@("meta","isa","segno")=SEGNO
 S @ROOT@("meta","isa","auth_qual")=$G(TOK(1))
 S @ROOT@("meta","isa","sec_qual")=$G(TOK(3))
 S @ROOT@("meta","isa","sender_qual")=$G(TOK(5))
 S @ROOT@("meta","isa","sender_id")=$G(TOK(6))
 S @ROOT@("meta","isa","receiver_qual")=$G(TOK(7))
 S @ROOT@("meta","isa","receiver_id")=$G(TOK(8))
 S @ROOT@("meta","isa","date")=$G(TOK(9))
 S @ROOT@("meta","isa","time")=$G(TOK(10))
 S @ROOT@("meta","isa","rep")=$G(TOK(11))
 S @ROOT@("meta","isa","version")=$G(TOK(12))
 S @ROOT@("meta","isa","control")=$G(TOK(13))
 S @ROOT@("meta","isa","ack_req")=$G(TOK(14))
 S @ROOT@("meta","isa","usage")=$G(TOK(15))
 S @ROOT@("meta","isa","comp")=$G(TOK(16))
 Q
 ;
HIEA(ROOT,STATE,TOK,SEGNO) ; IEA trailer
 S @ROOT@("meta","iea","segno")=SEGNO
 S @ROOT@("meta","iea","groups")=$G(TOK(1))
 S @ROOT@("meta","iea","control")=$G(TOK(2))
 I $G(@ROOT@("meta","isa","control"))'="",@ROOT@("meta","isa","control")'=$G(TOK(2)) D ADDDIAG^EFU837U(ROOT,"error","isa_iea_mismatch","ISA13 and IEA02 do not match",SEGNO,"IEA")
 Q
 ;
HGS(ROOT,STATE,TOK,SEGNO) ; GS envelope
 S STATE("group")=+$G(STATE("group"))+1
 S @ROOT@("group",STATE("group"),"segno")=SEGNO
 S @ROOT@("group",STATE("group"),"func_id")=$G(TOK(1))
 S @ROOT@("group",STATE("group"),"sender")=$G(TOK(2))
 S @ROOT@("group",STATE("group"),"receiver")=$G(TOK(3))
 S @ROOT@("group",STATE("group"),"date")=$G(TOK(4))
 S @ROOT@("group",STATE("group"),"time")=$G(TOK(5))
 S @ROOT@("group",STATE("group"),"control")=$G(TOK(6))
 S @ROOT@("group",STATE("group"),"agency")=$G(TOK(7))
 S @ROOT@("group",STATE("group"),"version")=$G(TOK(8))
 Q
 ;
HGE(ROOT,STATE,TOK,SEGNO) ; GE trailer
 N G
 S G=+$G(STATE("group"))
 I G'>0 D ADDDIAG^EFU837U(ROOT,"warning","ge_without_gs","GE seen without active GS",SEGNO,"GE") Q
 S @ROOT@("group",G,"ge","tx_count")=$G(TOK(1))
 S @ROOT@("group",G,"ge","control")=$G(TOK(2))
 I $G(@ROOT@("group",G,"control"))'="",@ROOT@("group",G,"control")'=$G(TOK(2)) D ADDDIAG^EFU837U(ROOT,"error","gs_ge_mismatch","GS06 and GE02 do not match",SEGNO,"GE")
 Q
 ;
HST(ROOT,STATE,TOK,SEGNO) ; ST start transaction
 I $G(STATE("tx"))>0 D ADDDIAG^EFU837U(ROOT,"error","nested_st","ST encountered before prior SE",SEGNO,"ST")
 S STATE("tx")=+$G(@ROOT@("idx","tx"))+1
 S @ROOT@("idx","tx")=STATE("tx")
 S @ROOT@("stats","transactions")=+$G(@ROOT@("stats","transactions"))+1
 S STATE("claim")=0,STATE("line")=0,STATE("other_sub")=0
 S STATE("scope")="TX"
 S STATE("txseg")=1
 S @ROOT@("tx",STATE("tx"),"st","segno")=SEGNO
 S @ROOT@("tx",STATE("tx"),"st","type")=$G(TOK(1))
 S @ROOT@("tx",STATE("tx"),"st","control")=$G(TOK(2))
 S @ROOT@("tx",STATE("tx"),"st","guide")=$G(TOK(3))
 S @ROOT@("meta","last_guide")=$G(TOK(3))
 Q
 ;
HSE(ROOT,STATE,TOK,SEGNO) ; SE end transaction
 N TX,REP
 S TX=+$G(STATE("tx"))
 I TX'>0 D ADDDIAG^EFU837U(ROOT,"error","se_without_st","SE encountered without ST",SEGNO,"SE") Q
 S @ROOT@("tx",TX,"se","segno")=SEGNO
 S @ROOT@("tx",TX,"se","count")=$G(TOK(1))
 S @ROOT@("tx",TX,"se","control")=$G(TOK(2))
 S REP=+$G(TOK(1))
 I $G(@ROOT@("tx",TX,"st","control"))'=$G(TOK(2)) D ADDDIAG^EFU837U(ROOT,"error","st_se_mismatch","ST02 and SE02 do not match",SEGNO,"SE")
 I REP'=(+$G(STATE("txseg"))) D ADDDIAG^EFU837U(ROOT,"warning","se_count_mismatch","Observed ST-SE segment count does not match SE01",SEGNO,"SE")
 S STATE("tx")=0
 S STATE("claim")=0
 S STATE("line")=0
 S STATE("other_sub")=0
 S STATE("scope")=""
 S STATE("txseg")=0
 Q
 ;
HBHT(ROOT,STATE,TOK) ; BHT transaction header
 N TX
 S TX=+$G(STATE("tx"))
 I TX'>0 Q
 S @ROOT@("tx",TX,"bht","purpose_code")=$G(TOK(1))
 S @ROOT@("tx",TX,"bht","ref")=$G(TOK(3))
 S @ROOT@("tx",TX,"bht","date")=$G(TOK(4))
 S @ROOT@("tx",TX,"bht","time")=$G(TOK(5))
 S @ROOT@("tx",TX,"bht","type")=$G(TOK(6))
 Q
 ;
HHL(ROOT,STATE,TOK,SEGNO) ; HL hierarchy
 N HLID,PAR,CODE,CHILD,SID,PID
 S HLID=$G(TOK(1)),PAR=$G(TOK(2)),CODE=$G(TOK(3)),CHILD=$G(TOK(4))
 S @ROOT@("hl",HLID,"parent")=PAR
 S @ROOT@("hl",HLID,"code")=CODE
 S @ROOT@("hl",HLID,"child")=CHILD
 S STATE("hl")=HLID
 S STATE("line")=0
 S STATE("other_sub")=0
 I CODE="20" D  Q
 . S STATE("scope")="BILLING"
 . S STATE("claim")=0
 . S STATE("patient")=0
 . S SID=0
 I CODE="22" D  Q
 . S SID=+$G(@ROOT@("idx","subscriber"))+1
 . S @ROOT@("idx","subscriber")=SID
 . S STATE("sub")=SID,STATE("patient")=0,STATE("claim")=0
 . S @ROOT@("sub",SID,"tx")=+$G(STATE("tx"))
 . S @ROOT@("sub",SID,"hl_id")=HLID
 . S @ROOT@("sub",SID,"hl_parent")=PAR
 . S STATE("scope")="SUBSCRIBER"
 I CODE="23" D  Q
 . S PID=+$G(@ROOT@("idx","patient"))+1
 . S @ROOT@("idx","patient")=PID
 . S STATE("patient")=PID,STATE("claim")=0
 . S @ROOT@("patient",PID,"tx")=+$G(STATE("tx"))
 . S @ROOT@("patient",PID,"hl_id")=HLID
 . S @ROOT@("patient",PID,"sub")=+$G(STATE("sub"))
 . S STATE("scope")="PATIENT"
 D ADDDIAG^EFU837U(ROOT,"warning","hl_code_unhandled","HL03 "_CODE_" is not yet mapped to a strong loop role",SEGNO,"HL")
 S STATE("scope")="HL"
 Q
 ;
HSBR(ROOT,STATE,TOK,SEGNO) ; SBR subscriber or other subscriber
 N SID,CID,OID
 S CID=+$G(STATE("claim"))
 I CID>0,($G(STATE("scope"))'="LINE") D  Q
 . S OID=+$G(@ROOT@("claim",CID,"other_sub_last"))+1
 . S @ROOT@("claim",CID,"other_sub_last")=OID
 . S STATE("other_sub")=OID
 . S STATE("scope")="OTHER_SUBSCRIBER"
 . S @ROOT@("claim",CID,"other_sub",OID,"segno")=SEGNO
 . S @ROOT@("claim",CID,"other_sub",OID,"sbr",1)=$G(TOK(1))
 . S @ROOT@("claim",CID,"other_sub",OID,"sbr",2)=$G(TOK(2))
 . S @ROOT@("claim",CID,"other_sub",OID,"sbr",3)=$G(TOK(3))
 . S @ROOT@("claim",CID,"other_sub",OID,"sbr",4)=$G(TOK(4))
 . S @ROOT@("claim",CID,"other_sub",OID,"sbr",9)=$G(TOK(9))
 S SID=+$G(STATE("sub"))
 I SID'>0 D ADDDIAG^EFU837U(ROOT,"warning","sbr_without_subscriber","SBR found outside subscriber context",SEGNO,"SBR") Q
 S @ROOT@("sub",SID,"sbr",1)=$G(TOK(1))
 S @ROOT@("sub",SID,"sbr",2)=$G(TOK(2))
 S @ROOT@("sub",SID,"sbr",3)=$G(TOK(3))
 S @ROOT@("sub",SID,"sbr",4)=$G(TOK(4))
 S @ROOT@("sub",SID,"sbr",9)=$G(TOK(9))
 S STATE("scope")="SUBSCRIBER"
 Q
 ;
HPAT(ROOT,STATE,TOK) ; PAT patient info
 N PID
 S PID=+$G(STATE("patient"))
 I PID'>0 Q
 S @ROOT@("patient",PID,"pat",1)=$G(TOK(1))
 S @ROOT@("patient",PID,"pat",2)=$G(TOK(2))
 S @ROOT@("patient",PID,"pat",3)=$G(TOK(3))
 Q
 ;
HNM1(ROOT,STATE,TOK,SEGNO) ; NM1 routing
 N ENT,TX,SID,PID,CID,OID,ROLE,TROOT
 S ENT=$G(TOK(1))
 S TX=+$G(STATE("tx"))
 S SID=+$G(STATE("sub"))
 S PID=+$G(STATE("patient"))
 S CID=+$G(STATE("claim"))
 S OID=+$G(STATE("other_sub"))
 I ENT="41" D  Q
 . S TROOT=$NA(@ROOT@("tx",TX,"submitter","name"))
 . D NAME^EFU837U(TROOT,.TOK)
 . D LAST(.STATE,"submitter",TX,"")
 I ENT="40" D  Q
 . S TROOT=$NA(@ROOT@("tx",TX,"receiver","name"))
 . D NAME^EFU837U(TROOT,.TOK)
 . D LAST(.STATE,"receiver",TX,"")
 I ENT="85" D  Q
 . S TROOT=$NA(@ROOT@("tx",TX,"billing","name"))
 . D NAME^EFU837U(TROOT,.TOK)
 . D LAST(.STATE,"billing",TX,"")
 I ENT="IL" D  Q
 . I $G(STATE("scope"))="OTHER_SUBSCRIBER",CID>0,OID>0 D  Q
 . . S TROOT=$NA(@ROOT@("claim",CID,"other_sub",OID,"subscriber","name"))
 . . D NAME^EFU837U(TROOT,.TOK)
 . . D LAST(.STATE,"other_subscriber",OID,"")
 . I PID>0,$G(STATE("scope"))="PATIENT" D  Q
 . . S TROOT=$NA(@ROOT@("patient",PID,"name"))
 . . D NAME^EFU837U(TROOT,.TOK)
 . . D LAST(.STATE,"patient",PID,"")
 . I SID>0 D
 . . S TROOT=$NA(@ROOT@("sub",SID,"name"))
 . . D NAME^EFU837U(TROOT,.TOK)
 . . D LAST(.STATE,"subscriber",SID,"")
 I ENT="PR" D  Q
 . I $G(STATE("scope"))="OTHER_SUBSCRIBER",CID>0,OID>0 D  Q
 . . S TROOT=$NA(@ROOT@("claim",CID,"other_sub",OID,"payer","name"))
 . . D NAME^EFU837U(TROOT,.TOK)
 . . D LAST(.STATE,"other_payer",OID,"")
 . I SID>0 D
 . . S TROOT=$NA(@ROOT@("sub",SID,"payer","name"))
 . . D NAME^EFU837U(TROOT,.TOK)
 . . D LAST(.STATE,"subpayer",SID,"")
 I (ENT="71")!(ENT="72")!(ENT="73")!(ENT="77")!(ENT="82")!(ENT="DN")!(ENT="PW") D  Q
 . I CID'>0 D ADDDIAG^EFU837U(ROOT,"warning","provider_without_claim","Claim-level provider seen before CLM",SEGNO,"NM1") Q
 . S ROLE=ENT
 . S TROOT=$NA(@ROOT@("claim",CID,"provider",ROLE,"name"))
 . D NAME^EFU837U(TROOT,.TOK)
 . D LAST(.STATE,"claim_provider",CID,ROLE)
 Q
 ;
HPER(ROOT,STATE,TOK) ; PER contact
 N TX
 S TX=+$G(STATE("tx"))
 I TX'>0 Q
 I $G(STATE("last","kind"))="submitter" D
 . S @ROOT@("tx",TX,"submitter","per","func")=$G(TOK(1))
 . S @ROOT@("tx",TX,"submitter","per","name")=$G(TOK(2))
 . S @ROOT@("tx",TX,"submitter","per","qual1")=$G(TOK(3))
 . S @ROOT@("tx",TX,"submitter","per","val1")=$G(TOK(4))
 Q
 ;
HN3(ROOT,STATE,TOK) ; N3 address
 I $G(STATE("last","kind"))="submitter" D  Q
 . N TX S TX=+$G(STATE("last","id"))
 . S @ROOT@("tx",TX,"submitter","addr1")=$G(TOK(1))
 . S @ROOT@("tx",TX,"submitter","addr2")=$G(TOK(2))
 I $G(STATE("last","kind"))="receiver" D  Q
 . N TX S TX=+$G(STATE("last","id"))
 . S @ROOT@("tx",TX,"receiver","addr1")=$G(TOK(1))
 . S @ROOT@("tx",TX,"receiver","addr2")=$G(TOK(2))
 I $G(STATE("last","kind"))="billing" D  Q
 . N TX S TX=+$G(STATE("last","id"))
 . S @ROOT@("tx",TX,"billing","addr1")=$G(TOK(1))
 . S @ROOT@("tx",TX,"billing","addr2")=$G(TOK(2))
 I $G(STATE("last","kind"))="subscriber" D  Q
 . N SID S SID=+$G(STATE("last","id"))
 . S @ROOT@("sub",SID,"addr1")=$G(TOK(1))
 . S @ROOT@("sub",SID,"addr2")=$G(TOK(2))
 I $G(STATE("last","kind"))="patient" D  Q
 . N PID S PID=+$G(STATE("last","id"))
 . S @ROOT@("patient",PID,"addr1")=$G(TOK(1))
 . S @ROOT@("patient",PID,"addr2")=$G(TOK(2))
 I $G(STATE("last","kind"))="other_subscriber" D  Q
 . N CID,OID S CID=+$G(STATE("claim")),OID=+$G(STATE("last","id"))
 . S @ROOT@("claim",CID,"other_sub",OID,"subscriber","addr1")=$G(TOK(1))
 . S @ROOT@("claim",CID,"other_sub",OID,"subscriber","addr2")=$G(TOK(2))
 Q
 ;
HN4(ROOT,STATE,TOK) ; N4 address city/state/zip
 I $G(STATE("last","kind"))="billing" D  Q
 . N TX S TX=+$G(STATE("last","id"))
 . S @ROOT@("tx",TX,"billing","city")=$G(TOK(1))
 . S @ROOT@("tx",TX,"billing","state")=$G(TOK(2))
 . S @ROOT@("tx",TX,"billing","zip")=$G(TOK(3))
 I $G(STATE("last","kind"))="subscriber" D  Q
 . N SID S SID=+$G(STATE("last","id"))
 . S @ROOT@("sub",SID,"city")=$G(TOK(1))
 . S @ROOT@("sub",SID,"state")=$G(TOK(2))
 . S @ROOT@("sub",SID,"zip")=$G(TOK(3))
 I $G(STATE("last","kind"))="patient" D  Q
 . N PID S PID=+$G(STATE("last","id"))
 . S @ROOT@("patient",PID,"city")=$G(TOK(1))
 . S @ROOT@("patient",PID,"state")=$G(TOK(2))
 . S @ROOT@("patient",PID,"zip")=$G(TOK(3))
 I $G(STATE("last","kind"))="other_subscriber" D  Q
 . N CID,OID S CID=+$G(STATE("claim")),OID=+$G(STATE("last","id"))
 . S @ROOT@("claim",CID,"other_sub",OID,"subscriber","city")=$G(TOK(1))
 . S @ROOT@("claim",CID,"other_sub",OID,"subscriber","state")=$G(TOK(2))
 . S @ROOT@("claim",CID,"other_sub",OID,"subscriber","zip")=$G(TOK(3))
 Q
 ;
HREF(ROOT,STATE,TOK,SEGNO) ; REF identifiers
 N Q,V,CID,LN,SID,PID,TX,ROLE,OID
 S Q=$G(TOK(1)),V=$G(TOK(2))
 S CID=+$G(STATE("claim"))
 S LN=+$G(STATE("line"))
 S SID=+$G(STATE("sub"))
 S PID=+$G(STATE("patient"))
 S TX=+$G(STATE("tx"))
 S OID=+$G(STATE("other_sub"))
 I $G(STATE("last","kind"))="billing" D  Q
 . S @ROOT@("tx",TX,"billing","ref",Q)=V
 I $G(STATE("last","kind"))="subpayer" D  Q
 . S @ROOT@("sub",SID,"payer","ref",Q)=V
 I $G(STATE("last","kind"))="subscriber" D  Q
 . S @ROOT@("sub",SID,"ref",Q)=V
 I $G(STATE("last","kind"))="patient" D  Q
 . S @ROOT@("patient",PID,"ref",Q)=V
 I $G(STATE("last","kind"))="other_payer" D  Q
 . S @ROOT@("claim",CID,"other_sub",OID,"payer","ref",Q)=V
 I $G(STATE("last","kind"))="other_subscriber" D  Q
 . S @ROOT@("claim",CID,"other_sub",OID,"subscriber","ref",Q)=V
 I $G(STATE("last","kind"))="claim_provider" D  Q
 . S ROLE=$G(STATE("last","role"))
 . S @ROOT@("claim",CID,"provider",ROLE,"ref",Q)=V
 I LN>0 D  Q
 . S @ROOT@("claim",CID,"line",LN,"ref",Q)=V
 I CID>0 D  Q
 . S @ROOT@("claim",CID,"ref",Q)=V
 D ADDDIAG^EFU837U(ROOT,"warning","orphan_ref","REF could not be attached to a known context",SEGNO,"REF")
 Q
 ;
HDMG(ROOT,STATE,TOK) ; DMG demographics
 N SID,PID
 S SID=+$G(STATE("sub"))
 S PID=+$G(STATE("patient"))
 I PID>0,$G(STATE("scope"))="PATIENT" D  Q
 . S @ROOT@("patient",PID,"dmg","format")=$G(TOK(1))
 . S @ROOT@("patient",PID,"dmg","date")=$G(TOK(2))
 . S @ROOT@("patient",PID,"dmg","sex")=$G(TOK(3))
 I SID>0 D
 . S @ROOT@("sub",SID,"dmg","format")=$G(TOK(1))
 . S @ROOT@("sub",SID,"dmg","date")=$G(TOK(2))
 . S @ROOT@("sub",SID,"dmg","sex")=$G(TOK(3))
 Q
 ;
HCLM(ROOT,STATE,TOK,SEGNO) ; claim header
 N CID,CMP,SID,PID,TX
 S TX=+$G(STATE("tx"))
 I TX'>0 D ADDDIAG^EFU837U(ROOT,"error","clm_without_tx","CLM encountered before ST",SEGNO,"CLM") Q
 S SID=+$G(STATE("sub"))
 S PID=+$G(STATE("patient"))
 S CID=+$G(@ROOT@("idx","claim"))+1
 S @ROOT@("idx","claim")=CID
 S @ROOT@("stats","claims")=+$G(@ROOT@("stats","claims"))+1
 S STATE("claim")=CID
 S STATE("line")=0
 S STATE("other_sub")=0
 S STATE("scope")="CLAIM"
 S @ROOT@("claim",CID,"segno")=SEGNO
 S @ROOT@("claim",CID,"tx")=TX
 S @ROOT@("claim",CID,"sub")=SID
 S @ROOT@("claim",CID,"patient")=PID
 S @ROOT@("claim",CID,"claim_id")=$G(TOK(1))
 S @ROOT@("claim",CID,"total_charge")=$G(TOK(2))
 S @ROOT@("claim",CID,"place_of_service")=$G(TOK(5))
 D COMP^EFU837U($G(TOK(5)),$G(STATE("del","comp")),.CMP)
 S @ROOT@("claim",CID,"facility_code")=$G(CMP(1))
 S @ROOT@("claim",CID,"facility_qual")=$G(CMP(2))
 S @ROOT@("claim",CID,"claim_freq")=$G(CMP(3))
 S @ROOT@("claim",CID,"claim_type")=$G(TOK(7))
 S @ROOT@("claim",CID,"benefits_assign")=$G(TOK(8))
 S @ROOT@("claim",CID,"release_info")=$G(TOK(9))
 Q
 ;
HCL1(ROOT,STATE,TOK,SEGNO) ; institutional CL1 data
 N CID
 S CID=+$G(STATE("claim"))
 I CID'>0 D ADDDIAG^EFU837U(ROOT,"warning","cl1_without_claim","CL1 encountered outside claim",SEGNO,"CL1") Q
 S @ROOT@("claim",CID,"cl1","admission_type")=$G(TOK(1))
 S @ROOT@("claim",CID,"cl1","admission_source")=$G(TOK(3))
 Q
 ;
HDTP(ROOT,STATE,TOK,SEGNO) ; DTP date routing
 N CID,LN,TROOT,Q,F,V
 S Q=$G(TOK(1)),F=$G(TOK(2)),V=$G(TOK(3))
 S CID=+$G(STATE("claim"))
 S LN=+$G(STATE("line"))
 I LN>0,CID>0 D  Q
 . S TROOT=$NA(@ROOT@("claim",CID,"line",LN,"dtp",Q))
 . D DTP^EFU837U(Q,F,V,TROOT)
 I CID>0 D  Q
 . S TROOT=$NA(@ROOT@("claim",CID,"dtp",Q))
 . D DTP^EFU837U(Q,F,V,TROOT)
 I $G(STATE("tx"))>0 D  Q
 . S TROOT=$NA(@ROOT@("tx",+$G(STATE("tx")),"dtp",Q))
 . D DTP^EFU837U(Q,F,V,TROOT)
 D ADDDIAG^EFU837U(ROOT,"warning","dtp_orphan","DTP could not be attached to a known claim/line/tx context",SEGNO,"DTP")
 Q
 ;
HHI(ROOT,STATE,TOK,SEGNO) ; HI diagnosis/condition composites
 N CID,I,SEQ,CMP
 S CID=+$G(STATE("claim"))
 I CID'>0 D ADDDIAG^EFU837U(ROOT,"warning","hi_without_claim","HI encountered outside claim",SEGNO,"HI") Q
 F I=1:1:+$G(TOK("n")) I $G(TOK(I))'="" D
 . S SEQ=+$G(@ROOT@("claim",CID,"diag_last"))+1
 . S @ROOT@("claim",CID,"diag_last")=SEQ
 . D COMP^EFU837U($G(TOK(I)),$G(STATE("del","comp")),.CMP)
 . S @ROOT@("claim",CID,"diag",SEQ,"qual")=$G(CMP(1))
 . S @ROOT@("claim",CID,"diag",SEQ,"code")=$G(CMP(2))
 . S @ROOT@("claim",CID,"diag",SEQ,"form")=$G(CMP(3))
 . S @ROOT@("claim",CID,"diag",SEQ,"date")=$G(CMP(4))
 . S @ROOT@("claim",CID,"diag",SEQ,"raw")=$G(TOK(I))
 Q
 ;
HOI(ROOT,STATE,TOK,SEGNO) ; OI claim other insurance
 N CID
 S CID=+$G(STATE("claim"))
 I CID'>0 D ADDDIAG^EFU837U(ROOT,"warning","oi_without_claim","OI encountered outside claim",SEGNO,"OI") Q
 S @ROOT@("claim",CID,"oi",1)=$G(TOK(1))
 S @ROOT@("claim",CID,"oi",2)=$G(TOK(2))
 S @ROOT@("claim",CID,"oi",3)=$G(TOK(3))
 S @ROOT@("claim",CID,"oi",4)=$G(TOK(4))
 S @ROOT@("claim",CID,"oi",5)=$G(TOK(5))
 S @ROOT@("claim",CID,"oi",6)=$G(TOK(6))
 Q
 ;
HLX(ROOT,STATE,TOK,SEGNO) ; service line start
 N CID,LN
 S CID=+$G(STATE("claim"))
 I CID'>0 D ADDDIAG^EFU837U(ROOT,"error","lx_without_claim","LX encountered before CLM",SEGNO,"LX") Q
 S LN=+$G(@ROOT@("claim",CID,"line_last"))+1
 S @ROOT@("claim",CID,"line_last")=LN
 S @ROOT@("stats","lines")=+$G(@ROOT@("stats","lines"))+1
 S STATE("line")=LN
 S STATE("scope")="LINE"
 S @ROOT@("claim",CID,"line",LN,"segno")=SEGNO
 S @ROOT@("claim",CID,"line",LN,"line_no")=$G(TOK(1))
 Q
 ;
HSV(ROOT,STATE,TOK,SEGNO,ID) ; service detail SV1/SV2/SV3
 N CID,LN,CMP
 S CID=+$G(STATE("claim"))
 S LN=+$G(STATE("line"))
 I CID'>0!(LN'>0) D ADDDIAG^EFU837U(ROOT,"error","sv_without_lx","Service segment encountered without active LX",SEGNO,ID) Q
 S @ROOT@("claim",CID,"line",LN,"service_kind")=ID
 I ID="SV1" D  Q
 . D COMP^EFU837U($G(TOK(1)),$G(STATE("del","comp")),.CMP)
 . S @ROOT@("claim",CID,"line",LN,"proc_qual")=$G(CMP(1))
 . S @ROOT@("claim",CID,"line",LN,"proc_code")=$G(CMP(2))
 . S @ROOT@("claim",CID,"line",LN,"charge")=$G(TOK(2))
 . S @ROOT@("claim",CID,"line",LN,"uom")=$G(TOK(3))
 . S @ROOT@("claim",CID,"line",LN,"qty")=$G(TOK(4))
 I ID="SV2" D  Q
 . S @ROOT@("claim",CID,"line",LN,"revenue_code")=$G(TOK(1))
 . D COMP^EFU837U($G(TOK(2)),$G(STATE("del","comp")),.CMP)
 . S @ROOT@("claim",CID,"line",LN,"proc_qual")=$G(CMP(1))
 . S @ROOT@("claim",CID,"line",LN,"proc_code")=$G(CMP(2))
 . S @ROOT@("claim",CID,"line",LN,"charge")=$G(TOK(3))
 . S @ROOT@("claim",CID,"line",LN,"uom")=$G(TOK(4))
 . S @ROOT@("claim",CID,"line",LN,"qty")=$G(TOK(5))
 I ID="SV3" D  Q
 . D COMP^EFU837U($G(TOK(1)),$G(STATE("del","comp")),.CMP)
 . S @ROOT@("claim",CID,"line",LN,"proc_qual")=$G(CMP(1))
 . S @ROOT@("claim",CID,"line",LN,"proc_code")=$G(CMP(2))
 . S @ROOT@("claim",CID,"line",LN,"charge")=$G(TOK(2))
 . S @ROOT@("claim",CID,"line",LN,"uom")=$G(TOK(3))
 . S @ROOT@("claim",CID,"line",LN,"qty")=$G(TOK(4))
 Q
 ;
LAST(STATE,KIND,ID,ROLE) ; remember last entity for N3/N4/REF
 S STATE("last","kind")=$G(KIND)
 S STATE("last","id")=+$G(ID)
 S STATE("last","role")=$G(ROLE)
 Q
 ;
