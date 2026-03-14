EFU837CSV2 ; CSV export builder
 ;
 Q
 ;
MAKE(CONF,JOBID,PROFILEID,OUTPATH,ERR)
 N P,MODE,FIELDS,DELIM,RSRC,OLDIO,QMODE,ONAME
 K ERR
 I '$$GET^EFUZYCFG(.CONF,$G(PROFILEID),.P) D
 . S P("id")=""
 . S P("name")="Default Claim Summary"
 . S P("exportMode")="claim_summary"
 . S P("selectedFields")=$$DFLIST^EFU837EXPMP("claim_summary")
 . S P("fieldOrder")=P("selectedFields")
 . S P("delimiter")="," 
 . S P("header")=1
 . S P("quoteMode")="minimal"
 . S P("rowSource")="claim"
 . S P("outputNamingRule")="{{source_base}}-claim-summary.csv"
 S MODE=$G(P("exportMode")) I MODE="" S MODE="claim_summary"
 S FIELDS=$$ORDERFLD^EFUZYCFG(MODE,$G(P("selectedFields")),$G(P("fieldOrder")))
 I FIELDS="" S FIELDS=$$DFLIST^EFU837EXPMP(MODE)
 S DELIM=$S($G(P("delimiter"))'="":$G(P("delimiter")),1:",")
 S RSRC=$$ROWSRC(MODE,$G(P("rowSource")))
 S QMODE=$S($G(P("quoteMode"))'="":$ZCONVERT($G(P("quoteMode")),"L"),1:"minimal")
 S OUTPATH=$$OUTFILE(.CONF,JOBID,.P)
 S ONAME=$P(OUTPATH,"/",$L(OUTPATH,"/"))
 S OLDIO=$IO
 O OUTPATH:(NEWVERSION:STREAM:NOWRAP:WRITEONLY):1 E  S ERR("error")="export_open_failed" Q 0
 U OUTPATH
 I +$G(P("header")) W $$HDR(FIELDS,DELIM,QMODE),$$EOL()
 I RSRC="line" D WRLINES(JOBID,FIELDS,DELIM,QMODE)
 E  D WRCLAIMS(JOBID,FIELDS,DELIM,QMODE)
 C OUTPATH
 U OLDIO
 S ^MIO("EFUZY","job",JOBID,"profileId")=$G(PROFILEID)
 S ^MIO("EFUZY","job",JOBID,"profileName")=$G(P("name"))
 S ^MIO("EFUZY","job",JOBID,"exportMode")=MODE
 S ^MIO("EFUZY","job",JOBID,"rowSource")=RSRC
 S ^MIO("EFUZY","job",JOBID,"selectedFields")=$G(P("selectedFields"))
 S ^MIO("EFUZY","job",JOBID,"fieldOrder")=FIELDS
 S ^MIO("EFUZY","job",JOBID,"delimiter")=DELIM
 S ^MIO("EFUZY","job",JOBID,"quoteMode")=QMODE
 S ^MIO("EFUZY","job",JOBID,"outputNamingRule")=$G(P("outputNamingRule"))
 S ^MIO("EFUZY","job",JOBID,"plannedOutputName")=ONAME
 Q 1
 ;
ROWSRC(MODE,PRSRC)
 I $G(MODE)="service_line" Q "line"
 I $G(MODE)="custom",$G(PRSRC)'="" Q $G(PRSRC)
 I $G(MODE)="custom" Q "claim"
 Q "claim"
 ;
OUTFILE(CONF,JOBID,P)
 N BASE,NAME,SRC
 S BASE=$$EXPORTDIR^EFUZYFS(.CONF)
 S SRC=$$SAFE^EFUZYFS($$GETNAME^EFUZYFS($G(^MIO("EFUZY","job",JOBID,"fileId"))))
 S NAME=$G(P("outputNamingRule"))
 I NAME="" S NAME="{{source_base}}-"_$G(P("exportMode"))_".csv"
 S NAME=$TR(NAME,"{","")
 S NAME=$TR(NAME,"}","")
 S NAME=$$REPL(NAME,"source_base",$P(SRC,".",1))
 S NAME=$$REPL(NAME,"mode",$G(P("exportMode")))
 S NAME=$$REPL(NAME,"job_id",JOBID)
 S NAME=$$REPL(NAME,"timestamp",$TR($H,",","-"))
 I NAME["source_base" S NAME="job-"_JOBID_".csv"
 Q BASE_"/"_NAME
 ;
REPL(S,KEY,VAL)
 Q $$SUB($G(S),$G(KEY),$G(VAL))
 ;
SUB(S,F,R)
 N POS,START,OUT,FL
 I $G(F)="" Q $G(S)
 S OUT="",START=1,FL=$L(F)
 F  S POS=$F(S,F,START) Q:'POS  D
 . S OUT=OUT_$E(S,START,POS-FL-1)_R
 . S START=POS
 S OUT=OUT_$E(S,START,$L(S))
 Q OUT
 ;
HDR(FIELDS,DELIM,QMODE)
 N I,O,NM
 S O=""
 F I=1:1:$L(FIELDS,",") S NM=$$TRIM^MIOUTIL($P(FIELDS,",",I)) I NM'="" D
 . I O'="" S O=O_DELIM
 . S O=O_$$CSV(NM,$G(QMODE),$G(DELIM))
 Q O
 ;
WRCLAIMS(JOBID,FIELDS,DELIM,QMODE)
 N I
 S I=0
 F  S I=$O(^MIO("EFUZY","job",JOBID,"wrk","claim",I)) Q:'I  W $$ROW("claim",JOBID,I,FIELDS,DELIM,QMODE),$$EOL()
 Q
 ;
WRLINES(JOBID,FIELDS,DELIM,QMODE)
 N I
 S I=0
 F  S I=$O(^MIO("EFUZY","job",JOBID,"wrk","line",I)) Q:'I  W $$ROW("line",JOBID,I,FIELDS,DELIM,QMODE),$$EOL()
 Q
 ;
ROW(SRC,JOBID,IDX,FIELDS,DELIM,QMODE)
 N I,NM,O
 S O=""
 F I=1:1:$L(FIELDS,",") S NM=$$TRIM^MIOUTIL($P(FIELDS,",",I)) I NM'="" D
 . I O'="" S O=O_DELIM
 . S O=O_$$CSV($$VAL(SRC,JOBID,IDX,NM),$G(QMODE),$G(DELIM))
 Q O
 ;
VAL(SRC,JOBID,IDX,FIELD)
 N V,CIDX
 I $G(SRC)="claim" Q $G(^MIO("EFUZY","job",JOBID,"wrk","claim",IDX,FIELD))
 S V=$G(^MIO("EFUZY","job",JOBID,"wrk","line",IDX,FIELD))
 I V'="" Q V
 S CIDX=$G(^MIO("EFUZY","job",JOBID,"wrk","line",IDX,"claim_index"))
 I CIDX="" Q ""
 Q $G(^MIO("EFUZY","job",JOBID,"wrk","claim",CIDX,FIELD))
 ;
CSV(V,QMODE,DELIM)
 N X,QM,Q
 S X=$G(V),QM=$ZCONVERT($G(QMODE),"L"),Q=$C(34)
 S X=$TR(X,$C(13,10),"  ")
 I QM="none" Q X
 I QM="all" D  Q X
 . S X=$$SUB(X,Q,Q_Q)
 . S X=Q_X_Q
 I $G(DELIM)="" S DELIM="," 
 I (X[DELIM)!($F(X,Q)>0)!(X[$C(10))!(X[$C(13)) D
 . S X=$$SUB(X,Q,Q_Q)
 . S X=Q_X_Q
 Q X
 ;
EOL()
 Q $C(13,10)
