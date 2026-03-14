EFU837CAN ; efuzy 837 canonical package helpers v2
	;
	; Public:
	;   EXPORT(ROOT,OUTBASE,.RES)
	;   LOAD(INBASE,ROOT,.RES)
	;   CLAIMHDR(.ROW)
	;   LINEHDR(.ROW)
	;
	; Notes:
	;   - controlled internal round-trip schema
	;   - one claims file + one lines file + one manifest file
	;   - bounded row shape, file-size independent
	;   - manifest is additive and backward compatible
	;   - legacy packages without manifest still load
	;
	Q
	;
EXPORT(ROOT,OUTBASE,RES) ; export canonical claims + lines CSV files + manifest
	N NOK,CPATH,LPATH,MPATH,RC,RL,CID,LN,OLDIO,MRES
	K RES
	S RES("ok")=0
	I $G(ROOT)="" S RES("error")="missing_root" Q
	I $G(OUTBASE)="" S RES("error")="missing_outbase" Q
	D ENSURE(ROOT,.NOK)
	I '+$G(NOK("ok")) S RES("error")="norm_failed" M RES("norm")=NOK Q
	S CPATH=OUTBASE_"-claims.csv",LPATH=OUTBASE_"-lines.csv",MPATH=OUTBASE_"-manifest.txt"
	S OLDIO=$IO
	O CPATH:(NEWVERSION:STREAM:NOWRAP:WRITEONLY):1
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
	O LPATH:(NEWVERSION:STREAM:NOWRAP:WRITEONLY):1
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
	D WRMAN(ROOT,OUTBASE,MPATH,.MRES)
	I '+$G(MRES("ok")) S RES("error")="write_manifest_failed" M RES("manifest")=MRES Q
	S RES("ok")=1
	S RES("claims_path")=CPATH
	S RES("lines_path")=LPATH
	S RES("manifest_path")=MPATH
	S RES("schema_name")=$$SCHEMA()
	S RES("schema_version")=$$SCHEMAV()
	S RES("schema_semver")=$$SCHEMASV()
	S RES("claims")=+$G(MRES("claims"))
	S RES("lines")=+$G(MRES("lines"))
	M RES("manifest")=MRES
	Q
	;
LOAD(INBASE,ROOT,RES) ; load canonical package into ROOT("canon")
	N CPATH,LPATH,MPATH,ERR,MRES
	K RES
	S RES("ok")=0
	I $G(INBASE)="" S RES("error")="missing_inbase" Q
	I $G(ROOT)="" S ROOT=$NA(^TMP($J,"EFU837CAN"))
	K @ROOT@("canon")
	S CPATH=INBASE_"-claims.csv",LPATH=INBASE_"-lines.csv",MPATH=INBASE_"-manifest.txt"
	D RDMAN(MPATH,.MRES)
	D APPLYM(ROOT,.MRES)
	I +$G(MRES("present")) D
	. I $G(MRES("schema_name"))'="",$G(MRES("schema_name"))'=$$SCHEMA() S RES("error")="unsupported_schema_name" M RES("manifest")=MRES Q
	. I +$G(MRES("schema_version"))'=$$SCHEMAV() S RES("error")="unsupported_schema_version" M RES("manifest")=MRES Q
	. I $G(MRES("claims_path"))'="" S CPATH=$G(MRES("claims_path"))
	. I $G(MRES("lines_path"))'="" S LPATH=$G(MRES("lines_path"))
	I $G(RES("error"))'="" Q
	D LOADCLA(CPATH,ROOT,.ERR)
	I +$G(ERR) S RES("error")="load_claims_failed" M RES("manifest")=MRES Q
	D LOADLIN(LPATH,ROOT,.ERR)
	I +$G(ERR) S RES("error")="load_lines_failed" M RES("manifest")=MRES Q
	S RES("ok")=1
	S RES("claims")=+$G(@ROOT@("canon","claims"))
	S RES("lines")=+$G(@ROOT@("canon","lines"))
	S RES("claims_path")=CPATH
	S RES("lines_path")=LPATH
	S RES("manifest_path")=MPATH
	M RES("manifest")=MRES
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
WRMAN(ROOT,OUTBASE,PATH,RES) ; write additive manifest package file
	N DEV,OLDIO,CNTCLM,CNTLIN,TXS,GDS
	K RES
	S RES("ok")=0,DEV=PATH,OLDIO=$IO
	D COUNTS(ROOT,.CNTCLM,.CNTLIN,.TXS,.GDS)
	O DEV:(NEWVERSION:STREAM:NOWRAP:WRITEONLY):1
	I '$T S RES("error")="open_manifest_failed" Q
	U DEV
	D WKV("schema_name",$$SCHEMA())
	D WKV("schema_version",$$SCHEMAV())
	D WKV("schema_semver",$$SCHEMASV())
	D WKV("package_kind","canonical_csv")
	D WKV("claims_path",OUTBASE_"-claims.csv")
	D WKV("lines_path",OUTBASE_"-lines.csv")
	D WKV("claims",CNTCLM)
	D WKV("lines",CNTLIN)
	D WKV("tx_kinds",TXS)
	D WKV("guides",GDS)
	D WKV("source_path",$G(@ROOT@("meta","file","path")))
	D WKV("engine",$G(@ROOT@("meta","engine"),"EFU837"))
	D WKV("version",$G(@ROOT@("meta","version")))
	D WKV("created_h",$H)
	C DEV U OLDIO
	S RES("ok")=1
	S RES("present")=1
	S RES("schema_name")=$$SCHEMA()
	S RES("schema_version")=$$SCHEMAV()
	S RES("schema_semver")=$$SCHEMASV()
	S RES("claims")=CNTCLM
	S RES("lines")=CNTLIN
	S RES("claims_path")=OUTBASE_"-claims.csv"
	S RES("lines_path")=OUTBASE_"-lines.csv"
	S RES("manifest_path")=PATH
	S RES("tx_kinds")=TXS
	S RES("guides")=GDS
	Q
	;
RDMAN(PATH,RES) ; read manifest if present, otherwise mark legacy package
	N DEV,OLDIO,LINE,DONE,ERR,KEY,VAL,OPENOK
	K RES
	S RES("ok")=1,RES("present")=0,RES("schema_name")=$$SCHEMA(),RES("schema_version")=$$SCHEMAV(),RES("schema_semver")=$$SCHEMASV(),RES("legacy")=1
	S DEV=PATH,OLDIO=$IO,DONE=0,ERR=0,OPENOK=0
	I '$$EXISTS(PATH) Q
	D OPENR(.DEV,.OPENOK)
	I 'OPENOK U OLDIO Q
	U DEV
	F  Q:DONE!(ERR)  D
	. D READROW(.LINE,.DONE,.ERR)
	. I DONE!(ERR) Q
	. I LINE="" Q
	. D PARSEKV(LINE,.KEY,.VAL)
	. I KEY="" Q
	. S RES("present")=1,RES("legacy")=0
	. S RES(KEY)=VAL
	C DEV U OLDIO
	I ERR S RES("ok")=0,RES("error")="read_manifest_failed" Q
	I +$G(RES("present")),+$G(RES("schema_version"))'>0 S RES("schema_version")=+$$SCHEMAV()
	Q
	;
OPENR(DEV,OK) ; safe readonly stream open helper
	N $ETRAP,$ESTACK
	S OK=0
	S $ETRAP="S OK=0,$ECODE="""" Q"
	O DEV:(READONLY:STREAM):1
	S $ETRAP=""
	I $T S OK=1
	Q
	;
EXISTS(PATH) ; file exists helper
	Q $S($ZSEARCH(PATH)'="":1,1:0)
	;
APPLYM(ROOT,MAN) ; apply manifest metadata into canon meta subtree
	K @ROOT@("canon","meta")
	S @ROOT@("canon","meta","schema_name")=$G(MAN("schema_name"),$$SCHEMA())
	S @ROOT@("canon","meta","schema_version")=$G(MAN("schema_version"),$$SCHEMAV())
	S @ROOT@("canon","meta","schema_semver")=$G(MAN("schema_semver"),$$SCHEMASV())
	S @ROOT@("canon","meta","manifest_present")=+$G(MAN("present"))
	S @ROOT@("canon","meta","legacy_package")=+$G(MAN("legacy"))
	S:$G(MAN("tx_kinds"))'="" @ROOT@("canon","meta","tx_kinds")=$G(MAN("tx_kinds"))
	S:$G(MAN("guides"))'="" @ROOT@("canon","meta","guides")=$G(MAN("guides"))
	Q
	;
COUNTS(ROOT,CLAIMS,LINES,TXS,GDS) ; package counts and guide mix
	N CID,LN,TX,G
	S (CLAIMS,LINES)=0,TXS="",GDS=""
	S CID=0
	F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
	. S CLAIMS=CLAIMS+1
	. S TX=$G(@ROOT@("norm","claim",CID,"tx_kind")) I TX'="" S TXS=$$ADDSET(TXS,TX)
	. S G=$G(@ROOT@("norm","claim",CID,"guide")) I G'="" S GDS=$$ADDSET(GDS,G)
	. S LN=0 F  S LN=$O(@ROOT@("norm","line",CID,LN)) Q:'LN  S LINES=LINES+1
	Q
	;
ADDSET(LST,VAL) ; append unique pipe-delimited set value
	I $G(VAL)="" Q $G(LST)
	I ("|"_$G(LST)_"|")["|"_$G(VAL)_"|" Q $G(LST)
	I $G(LST)="" Q $G(VAL)
	Q $G(LST)_"|"_$G(VAL)
	;
WKV(KEY,VAL) ; write key=value manifest line to current device
	W $G(KEY),"=",$G(VAL),$$NL()
	Q
	;
PARSEKV(LINE,KEY,VAL) ; parse simple manifest key=value line
	N P
	S KEY="",VAL=""
	S P=$F($G(LINE),"=")
	I P'>1 Q
	S KEY=$E(LINE,1,P-2)
	S VAL=$E(LINE,P,$L(LINE))
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
	N DEV,OLDIO,DONE,LINE,HDR,MAP,ROW,CID,LN,CLM
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
READROW(LINE,DONE,ERR) ; EOF-safe CSV/manifest line reader for stream files
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
WRROW(ROW) ; write one CSV row to current device
	N I,MAX,OUT
	S OUT="",MAX=0
	S I=0 F  S I=$O(ROW(I)) Q:'I  S:I>MAX MAX=I
	F I=1:1:MAX D
	. I I>1 S OUT=OUT_","
	. S OUT=OUT_$$CSVESC^EFU837U($G(ROW(I)))
	W OUT,$$NL()
	Q
	;
NL() ; explicit line terminator for stream writes
	Q $C(13,10)
	;
SCHEMA() Q "EFU837_CANONICAL"
SCHEMAV() Q 1
SCHEMASV() Q "1.0.0"
	;
	;