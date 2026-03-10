EFU837CSV ; efuzy X12 837 CSV export helpers
 ;
 ; Public:
 ;   EXPORT(PATH,OUTBASE,ROOT,.OPT,.RES)
 ;   EXPORTDIR(INDIR,OUTDIR,WORKROOT,.OPT,.RES)
 ;
 ; Output files:
 ;   <outbase>.csv            combined claim + line rows
 ;   <outbase>-Claims.csv     one row per claim
 ;   <outbase>-Lines.csv      one row per service line
 ;   <outbase>-Subscribers.csv
 ;   <outbase>-Providers.csv
 ;
 Q
 ;
EXPORT(PATH,OUTBASE,ROOT,OPT,RES) ; parse one file and write CSV outputs
 N PRES,W1,W2,W3,W4,W5,OLDIO
 K RES
 I $G(PATH)="" S RES("ok")=0,RES("error")="missing_path" Q
 I $G(OUTBASE)="" S OUTBASE=$$NOEXT^EFU837U(PATH)
 I $G(ROOT)="" S ROOT=$NA(^TMP($J,"EFU837CSV",$J))
 S OLDIO=$IO
 D PARSE^EFU837P(PATH,ROOT,.OPT,.PRES)
 U OLDIO
 I '+$G(PRES("ok")) S RES("ok")=0,RES("error")="parse_failed" M RES("parse")=PRES Q
 D WRITE("COMBINED",ROOT,OUTBASE_".csv",.W1)
 D WRITE("CLAIM",ROOT,OUTBASE_"-Claims.csv",.W2)
 D WRITE("LINE",ROOT,OUTBASE_"-Lines.csv",.W3)
 D WRITE("SUBSCRIBER",ROOT,OUTBASE_"-Subscribers.csv",.W4)
 D WRITE("PROVIDER",ROOT,OUTBASE_"-Providers.csv",.W5)
 S RES("ok")=$S((+$G(W1("ok"))&+$G(W2("ok"))&+$G(W3("ok"))&+$G(W4("ok"))&+$G(W5("ok"))):1,1:0)
 S RES("claims")=+$G(@ROOT@("stats","claims"))
 S RES("lines")=+$G(@ROOT@("stats","lines"))
 S RES("combined_rows")=+$G(W1("rows"))
 S RES("claim_rows")=+$G(W2("rows"))
 S RES("line_rows")=+$G(W3("rows"))
 S RES("subscriber_rows")=+$G(W4("rows"))
 S RES("provider_rows")=+$G(W5("rows"))
 S RES("path","combined")=OUTBASE_".csv"
 S RES("path","claims")=OUTBASE_"-Claims.csv"
 S RES("path","lines")=OUTBASE_"-Lines.csv"
 S RES("path","subscribers")=OUTBASE_"-Subscribers.csv"
 S RES("path","providers")=OUTBASE_"-Providers.csv"
 M RES("parse")=PRES
 Q
 ;
EXPORTDIR(INDIR,OUTDIR,WORKROOT,OPT,RES) ; batch export *.dat and *.edi files
 N IDX,FILE,PAT,OUTBASE,FROOT,ERES,FAIL
 K RES
 S RES("ok")=1,RES("files")=0,FAIL=0
 I $G(INDIR)=""!($G(OUTDIR)="") S RES("ok")=0,RES("error")="missing_dir" Q
 I $G(WORKROOT)="" S WORKROOT=$NA(^TMP($J,"EFU837CSV","BATCH"))
 F PAT="*.dat","*.edi" D
 . S FILE=$ZSEARCH(INDIR_"/"_PAT)
 . F  Q:FILE=""  D
 . . S IDX=+$G(RES("files"))+1
 . . S RES("files")=IDX
 . . S OUTBASE=OUTDIR_"/"_$$NOEXT^EFU837U($$BASENAME^EFU837U(FILE))
 . . S FROOT=$NA(@WORKROOT@(IDX))
 . . D EXPORT(FILE,OUTBASE,FROOT,.OPT,.ERES)
 . . M RES("file",IDX)=ERES
 . . S RES("file",IDX,"input")=FILE
 . . I '+$G(ERES("ok")) S FAIL=1
 . . S FILE=$ZSEARCH("")
 I FAIL S RES("ok")=0
 Q
 ;
WRITE(TYPE,ROOT,PATH,RES) ; write one CSV file type
 N DEV,HDR,ROW,ROWS,CID,LN,HAS,OLDIO
 K RES
 S RES("ok")=0,RES("rows")=0
 D HEADERS^EFU837MAP(TYPE,.HDR)
 S DEV=PATH,OLDIO=$IO
 O DEV:(NEWVERSION:STREAM):1
 I '$T S RES("error")="open_failed" U OLDIO Q
 U DEV
 D WRROW(.HDR)
 S ROWS=0,CID=0
 I $$UC^EFU837U(TYPE)="CLAIM" D  G WQ
 . F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
 . . K ROW
 . . D ROWCLAIM^EFU837MAP(ROOT,CID,.ROW)
 . . D WRROW(.ROW)
 . . S ROWS=ROWS+1
 I $$UC^EFU837U(TYPE)="LINE" D  G WQ
 . F  S CID=$O(@ROOT@("norm","line",CID)) Q:'CID  D
 . . S LN=0
 . . F  S LN=$O(@ROOT@("norm","line",CID,LN)) Q:'LN  D
 . . . K ROW
 . . . D ROWLINE^EFU837MAP(ROOT,CID,LN,.ROW)
 . . . D WRROW(.ROW)
 . . . S ROWS=ROWS+1
 I $$UC^EFU837U(TYPE)="SUBSCRIBER" D  G WQ
 . F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
 . . K ROW
 . . D ROWSUB^EFU837MAP(ROOT,CID,.ROW)
 . . D WRROW(.ROW)
 . . S ROWS=ROWS+1
 I $$UC^EFU837U(TYPE)="PROVIDER" D  G WQ
 . F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
 . . K ROW
 . . D ROWPROV^EFU837MAP(ROOT,CID,.ROW)
 . . D WRROW(.ROW)
 . . S ROWS=ROWS+1
 I $$UC^EFU837U(TYPE)="COMBINED" D
 . F  S CID=$O(@ROOT@("norm","claim",CID)) Q:'CID  D
 . . S HAS=0,LN=0
 . . F  S LN=$O(@ROOT@("norm","line",CID,LN)) Q:'LN  D
 . . . K ROW
 . . . D ROWCOMB^EFU837MAP(ROOT,CID,LN,.ROW)
 . . . D WRROW(.ROW)
 . . . S ROWS=ROWS+1,HAS=1
 . . I 'HAS D
 . . . K ROW
 . . . D ROWCOMB^EFU837MAP(ROOT,CID,0,.ROW)
 . . . D WRROW(.ROW)
 . . . S ROWS=ROWS+1
WQ C DEV
 U OLDIO
 S RES("ok")=1,RES("rows")=ROWS
 Q
 ;
WRROW(ROW) ; write one CSV row to current device from numeric subscripts
 N I,MAX,OUT
 S OUT="",MAX=0
 S I=0 F  S I=$O(ROW(I)) Q:'I  S:I>MAX MAX=I
 F I=1:1:MAX D
 . I I>1 S OUT=OUT_"," 
 . S OUT=OUT_$$CSVESC^EFU837U($G(ROW(I)))
 W OUT,!
 Q
 ;

