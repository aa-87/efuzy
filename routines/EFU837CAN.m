EFU837CAN ; efuzy 837 canonical CSV package helpers
 ;
 ; Public:
 ;   EXPORT(ROOT,OUTBASE,.RES)
 ;   LOAD(INBASE,ROOT,.RES)
 ;   CLAIMHDR(.ROW)
 ;   LINEHDR(.ROW)
 ;
 ; Notes:
 ;   - controlled internal round-trip schema
 ;   - one claims file + one lines file
 ;   - bounded row shape, file-size independent
 ;   - not a user-custom export profile surface
 ;
 Q
 ;
EXPORT(ROOT,OUTBASE,RES) ; export canonical claims + lines CSV files
 N NOK,CPATH,LPATH,RC,RL,CID,LN,OLDIO
 K RES
 S RES("ok")=0
 I $G(ROOT)="" S RES("error")="missing_root" Q
 I $G(OUTBASE)="" S RES("error")="missing_outbase" Q
 D ENSURE(ROOT,.NOK)
 I '+$G(NOK("ok")) S RES("error")="norm_failed" M RES("norm")=NOK Q
 S CPATH=OUTBASE_"-claims.csv",LPATH=OUTBASE_"-lines.csv"
 S OLDIO=$IO
 O CPATH:(NEWVERSION:STREAM):1
 I '$T S RES("error")="open_claims_failed" U OLDIO Q
 U CPATH
 D CLAIMHDR(.RC)
 D WRROW(.RC)
 S CID=0
 F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
 . D CLAIMROW(ROOT,CID,.RC)
 . D WRROW(.RC)
 C CPATH
 U OLDIO
 O LPATH:(NEWVERSION:STREAM):1
 I '$T S RES("error")="open_lines_failed" U OLDIO Q
 U LPATH
 D LINEHDR(.RL)
 D WRROW(.RL)
 S CID=0
 F  S CID=$O(@ROOT@("norm","line",CID)) Q:'CID  D
 . S LN=0
 . F  S LN=$O(@ROOT@("norm","line",CID,LN)) Q:'LN  D
 . . D LINEROW(ROOT,CID,LN,.RL)
 . . D WRROW(.RL)
 C LPATH
 U OLDIO
 S RES("ok")=1
 S RES("claims_path")=CPATH
 S RES("lines_path")=LPATH
 Q
 ;
LOAD(INBASE,ROOT,RES) ; load canonical CSV package into ROOT("canon")
 N CPATH,LPATH,MAP,ERR
 K RES
 S RES("ok")=0
 I $G(INBASE)="" S RES("error")="missing_inbase" Q
 I $G(ROOT)="" S ROOT=$NA(^TMP($J,"EFU837CAN"))
 K @ROOT@("canon")
 S CPATH=INBASE_"-claims.csv",LPATH=INBASE_"-lines.csv"
 I '$$FEX(CPATH) S RES("error")="claims_file_missing",RES("claims_path")=CPATH Q
 I '$$FEX(LPATH) S RES("error")="lines_file_missing",RES("lines_path")=LPATH Q
 D LOADCLA(CPATH,ROOT,.ERR)
 I +$G(ERR) S RES("error")="load_claims_failed",RES("claims_path")=CPATH Q
 D LOADLIN(LPATH,ROOT,.ERR)
 I +$G(ERR) S RES("error")="load_lines_failed",RES("lines_path")=LPATH Q
 S RES("ok")=1
 S RES("claims")=+$G(@ROOT@("canon","claims"))
 S RES("lines")=+$G(@ROOT@("canon","lines"))
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
CLAIMHDR(ROW) ; canonical claims header row
 K ROW
 S ROW(1)="claim_id"
 S ROW(2)="tx_kind"
 S ROW(3)="guide"
 S ROW(4)="tx_control"
 S ROW(5)="total_charge"
 S ROW(6)="from_date"
 S ROW(7)="thru_date"
 S ROW(8)="facility_code"
 S ROW(9)="claim_freq"
 S ROW(10)="claim_type"
 S ROW(11)="subscriber_name"
 S ROW(12)="subscriber_member_id"
 S ROW(13)="subscriber_dob"
 S ROW(14)="subscriber_sex"
 S ROW(15)="patient_name"
 S ROW(16)="patient_member_id"
 S ROW(17)="patient_dob"
 S ROW(18)="patient_sex"
 S ROW(19)="primary_payer_name"
 S ROW(20)="billing_provider_name"
 S ROW(21)="billing_provider_npi"
 S ROW(22)="attending_provider_name"
 S ROW(23)="attending_provider_id"
 S ROW(24)="diag_codes"
 Q
 ;
LINEHDR(ROW) ; canonical service line header row
 K ROW
 S ROW(1)="claim_id"
 S ROW(2)="line_no"
 S ROW(3)="service_kind"
 S ROW(4)="revenue_code"
 S ROW(5)="procedure_qual"
 S ROW(6)="procedure_code"
 S ROW(7)="charge"
 S ROW(8)="uom"
 S ROW(9)="qty"
 S ROW(10)="svc_date"
 Q
 ;
CLAIMROW(ROOT,CID,ROW) ; one canonical claim row from normalized root
 K ROW
 S ROW(1)=$G(@ROOT@("norm","claim",CID,"claim_id"))
 S ROW(2)=$G(@ROOT@("norm","claim",CID,"tx_kind"))
 S ROW(3)=$G(@ROOT@("norm","claim",CID,"guide"))
 S ROW(4)=$G(@ROOT@("norm","claim",CID,"tx_control"))
 S ROW(5)=$G(@ROOT@("norm","claim",CID,"total_charge"))
 S ROW(6)=$G(@ROOT@("norm","claim",CID,"from_date"))
 S ROW(7)=$G(@ROOT@("norm","claim",CID,"thru_date"))
 S ROW(8)=$G(@ROOT@("norm","claim",CID,"facility_code"))
 S ROW(9)=$G(@ROOT@("norm","claim",CID,"claim_freq"))
 S ROW(10)=$G(@ROOT@("norm","claim",CID,"claim_type"))
 S ROW(11)=$G(@ROOT@("norm","claim",CID,"subscriber_name"))
 S ROW(12)=$G(@ROOT@("norm","claim",CID,"subscriber_member_id"))
 S ROW(13)=$G(@ROOT@("norm","party","subscriber",CID,"dob"))
 S ROW(14)=$G(@ROOT@("norm","party","subscriber",CID,"sex"))
 S ROW(15)=$G(@ROOT@("norm","claim",CID,"patient_name"))
 S ROW(16)=$G(@ROOT@("norm","claim",CID,"patient_member_id"))
 S ROW(17)=$G(@ROOT@("norm","party","patient",CID,"dob"))
 S ROW(18)=$G(@ROOT@("norm","party","patient",CID,"sex"))
 S ROW(19)=$G(@ROOT@("norm","claim",CID,"primary_payer_name"))
 S ROW(20)=$G(@ROOT@("norm","claim",CID,"billing_provider_name"))
 S ROW(21)=$G(@ROOT@("norm","claim",CID,"billing_provider_npi"))
 S ROW(22)=$G(@ROOT@("norm","claim",CID,"attending_provider_name"))
 S ROW(23)=$G(@ROOT@("norm","claim",CID,"attending_provider_id"))
 S ROW(24)=$G(@ROOT@("norm","claim",CID,"diag_codes"))
 Q
 ;
LINEROW(ROOT,CID,LN,ROW) ; one canonical service line row from normalized root
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
LOADCLA(PATH,ROOT,ERR) ; load claims file
 N DEV,OLDIO,DONE,LINE,HDR,MAP,ROW,CID,VAL
 S ERR=0,DEV=PATH,OLDIO=$IO,DONE=0
 O DEV:(READONLY:STREAM):1
 I '$T S ERR=1 Q
 U DEV
 D READROW(.LINE,.DONE,.ERR)
 I ERR C DEV U OLDIO Q
 I DONE C DEV U OLDIO S ERR=1 Q
 D PARSECSV(LINE,.HDR)
 D MAPHDR(.HDR,.MAP)
 F  Q:DONE!(ERR)  D
 . D READROW(.LINE,.DONE,.ERR)
 . I ERR Q
 . I DONE Q
 . I LINE="" Q
 . D PARSECSV(LINE,.ROW)
 . S CID=+$G(@ROOT@("canon","claims"))+1
 . S @ROOT@("canon","claims")=CID
 . D CSET(ROOT,CID,.MAP,.ROW)
 . S VAL=$G(@ROOT@("canon","claim",CID,"claim_id"))
 . I VAL'="" S @ROOT@("canon","idx","claim_id",VAL)=CID
 C DEV
 U OLDIO
 Q
 ;
LOADLIN(PATH,ROOT,ERR) ; load lines file
 N DEV,OLDIO,DONE,LINE,HDR,MAP,ROW,CID,VAL,LN,CLM
 S ERR=0,DEV=PATH,OLDIO=$IO,DONE=0
 O DEV:(READONLY:STREAM):1
 I '$T S ERR=1 Q
 U DEV
 D READROW(.LINE,.DONE,.ERR)
 I ERR C DEV U OLDIO Q
 I DONE C DEV U OLDIO S ERR=1 Q
 D PARSECSV(LINE,.HDR)
 D MAPHDR(.HDR,.MAP)
 F  Q:DONE!(ERR)  D
 . D READROW(.LINE,.DONE,.ERR)
 . I ERR Q
 . I DONE Q
 . I LINE="" Q
 . D PARSECSV(LINE,.ROW)
 . S CLM=$$VAL(.MAP,.ROW,"claim_id")
 . S CID=+$G(@ROOT@("canon","idx","claim_id",CLM))
 . I CID'>0 S ERR=1 Q
 . S LN=+$G(@ROOT@("canon","claim",CID,"line_last"))+1
 . S @ROOT@("canon","claim",CID,"line_last")=LN
 . S @ROOT@("canon","canon_lines")=+$G(@ROOT@("canon","canon_lines"))+1
 . D LSET(ROOT,CID,LN,.MAP,.ROW)
 C DEV
 U OLDIO
 S @ROOT@("canon","lines")=+$G(@ROOT@("canon","canon_lines"))
 Q
 ;
CSET(ROOT,CID,MAP,ROW) ; claim row assign
 N K
 F K="claim_id","tx_kind","guide","tx_control","total_charge","from_date","thru_date","facility_code","claim_freq","claim_type","subscriber_name","subscriber_member_id","subscriber_dob","subscriber_sex","patient_name","patient_member_id","patient_dob","patient_sex","primary_payer_name","billing_provider_name","billing_provider_npi","attending_provider_name","attending_provider_id","diag_codes" D
 . S @ROOT@("canon","claim",CID,K)=$$VAL(.MAP,.ROW,K)
 Q
 ;
LSET(ROOT,CID,LN,MAP,ROW) ; line row assign
 N K
 F K="claim_id","line_no","service_kind","revenue_code","procedure_qual","procedure_code","charge","uom","qty","svc_date" D
 . S @ROOT@("canon","claim",CID,"line",LN,K)=$$VAL(.MAP,.ROW,K)
 Q
 ;
VAL(MAP,ROW,KEY) ; field by header name
 N P
 S P=+$G(MAP($G(KEY)))
 I P'>0 Q ""
 Q $G(ROW(P))
 ;
MAPHDR(HDR,MAP) ; header map
 N I
 K MAP
 S I=0
 F  S I=$O(HDR(I)) Q:'I  S MAP($G(HDR(I)))=I
 Q
 ;
PARSECSV(LINE,OUT) ; parse a single CSV row with doubled-quote support
 N I,C,INQ,VAL,NXT
 K OUT
 S VAL="",INQ=0
 F I=1:1:$L($G(LINE)) D
 . S C=$E(LINE,I)
 . I C="," D  Q
 . . I 'INQ D PUSH(.OUT,.VAL) Q
 . . S VAL=VAL_C
 . I C'="""" S VAL=VAL_C Q
 . S NXT=$E(LINE,I+1)
 . I 'INQ S INQ=1 Q
 . I NXT="""" S VAL=VAL_"""",I=I+1 Q
 . S INQ=0
 D PUSH(.OUT,.VAL)
 Q
 ;
PUSH(OUT,VAL) ; append parsed csv field
 N N
 S N=+$O(OUT(""),-1)+1
 S OUT(N)=$G(VAL)
 S VAL=""
 Q
 ;
FEX(PATH) ; file exists helper
 Q $S($ZSEARCH($G(PATH))'="":1,1:0)
 ;
READROW(LINE,DONE,ERR) ; EOF-safe CSV line reader for stream files
 N $ETRAP,$ESTACK
 S LINE=""
 S $ETRAP="D RDERR^EFU837CAN"
 R LINE:1
 S $ETRAP=""
 I '$T D  Q
 . I $ZEOF S DONE=1 Q
 . S ERR=1
 I $ZEOF,LINE="" S DONE=1 Q
 I $E(LINE,$L(LINE))=$C(13) S LINE=$E(LINE,1,$L(LINE)-1)
 Q
 ;
RDERR ; read error trap helper for READROW
 I $ZSTATUS["IOEOF" S DONE=1,$ECODE="" Q
 S ERR=1,$ECODE="" Q
 ;
WRROW(ROW) ; write one CSV row to current device
 N I,MAX,OUT
 S OUT="",MAX=0
 S I=0 F  S I=$O(ROW(I)) Q:'I  S:I>MAX MAX=I
 F I=1:1:MAX D
 . I I>1 S OUT=OUT_"," 
 . S OUT=OUT_$$CSVESC^EFU837U($G(ROW(I)))
 W OUT,!
 Q
 ;
