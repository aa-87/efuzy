EFU837XP ; efuzy 837 export profiles CSV writer
	;
	; Public:
	;   BUILDROW(PROFILE,ROOT,CID,LN,.ROW)
	;   EXPORT(PROFILE,ROOT,PATH,.RES)
	;   EXPORTPARSE(PROFILE,INPATH,OUTPATH,ROOT,.OPT,.RES)
	;
	Q
	;
BUILDROW(PROFILE,ROOT,CID,LN,ROW) ; build one ordered row for profile
	N I,N,DEF
	K ROW
	S N=$$FIELDN^EFU837XCFG(PROFILE)
	F I=1:1:N D
	. K DEF
	. S %=$$FIELD^EFU837XCFG(PROFILE,I,.DEF)
	. S ROW(I)=$$APPLY^EFU837XFORM(ROOT,+$G(CID),+$G(LN),.DEF)
	Q
	;
EXPORT(PROFILE,ROOT,PATH,RES) ; export one profile from normalized root
	N SRC,HDR,ROW,ROWS,CID,LN,OLDIO,HAS,NOK
	K RES
	S RES("ok")=0,RES("rows")=0
	I '$$HAS^EFU837XCFG(PROFILE) S RES("error")="unknown_profile" Q
	I $G(ROOT)="" S RES("error")="missing_root" Q
	I $G(PATH)="" S RES("error")="missing_path" Q
	D ENSURE(ROOT,.NOK)
	I '+$G(NOK("ok")) S RES("error")="norm_failed" M RES("norm")=NOK Q
	D HEADERS^EFU837XCFG(PROFILE,.HDR)
	S SRC=$$ROWSRC^EFU837XCFG(PROFILE)
	S OLDIO=$IO
	O PATH:(NEWVERSION:STREAM):1
	I '$T S RES("error")="open_failed" U OLDIO Q
	U PATH
	D WRROW(.HDR)
	S ROWS=0,CID=0
	I SRC="CLAIM" D  G XQ
	. F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
	. . K ROW
	. . D BUILDROW(PROFILE,ROOT,CID,0,.ROW)
	. . D WRROW(.ROW)
	. . S ROWS=ROWS+1
	I SRC="LINE" D  G XQ
	. F  S CID=$O(@ROOT@("norm","line",CID)) Q:'CID  D
	. . S LN=0
	. . F  S LN=$O(@ROOT@("norm","line",CID,LN)) Q:'LN  D
	. . . K ROW
	. . . D BUILDROW(PROFILE,ROOT,CID,LN,.ROW)
	. . . D WRROW(.ROW)
	. . . S ROWS=ROWS+1
	I SRC="COMBINED" D
	. F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
	. . S HAS=0,LN=0
	. . F  S LN=$O(@ROOT@("norm","line",CID,LN)) Q:'LN  D
	. . . K ROW
	. . . D BUILDROW(PROFILE,ROOT,CID,LN,.ROW)
	. . . D WRROW(.ROW)
	. . . S ROWS=ROWS+1,HAS=1
	. . I 'HAS D
	. . . K ROW
	. . . D BUILDROW(PROFILE,ROOT,CID,0,.ROW)
	. . . D WRROW(.ROW)
	. . . S ROWS=ROWS+1
XQ C PATH
	U OLDIO
	S RES("ok")=1,RES("rows")=ROWS,RES("profile")=PROFILE,RES("path")=PATH
	Q
	;
EXPORTPARSE(PROFILE,INPATH,OUTPATH,ROOT,OPT,RES) ; parse input then export one profile
	N PRES,ERES
	K RES
	I $G(ROOT)="" S ROOT=$NA(^TMP($J,"EFU837XP",$J))
	D PARSE^EFU837P(INPATH,ROOT,.OPT,.PRES)
	I '+$G(PRES("ok")) S RES("ok")=0,RES("error")="parse_failed" M RES("parse")=PRES Q
	D EXPORT(PROFILE,ROOT,OUTPATH,.ERES)
	M RES=ERES
	M RES("parse")=PRES
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
	;