EFU837CSV ; CSV export builder
 ;
 Q
 ;
MAKE(CONF,JOBID,PROFILEID,OUTPATH,ERR)
 N P,MODE,FIELDS,DELIM,ROWSRC
 K ERR
 I '$$GET^EFUZYCFG(.CONF,$G(PROFILEID),.P) D
 . S P("id")=""
 . S P("name")="Default Claim Summary"
 . S P("exportMode")="claim_summary"
 . S P("selectedFields")=$$DFLIST^EFU837MAP("claim_summary")
 . S P("fieldOrder")=P("selectedFields")
 . S P("delimiter")=","
 . S P("header")=1
 . S P("quoteMode")="minimal"
 . S P("rowSource")="claim"
 . S P("outputNamingRule")="{{source_base}}-claim-summary.csv"
 S MODE=$G(P("exportMode")) I MODE="" S MODE="claim_summary"
 S FIELDS=$S($G(P("fieldOrder"))'="":P("fieldOrder"),1:$G(P("selectedFields")))
 S DELIM=$S($G(P("delimiter"))'="":P("delimiter"),1:",")
 S ROWSRC=$S($G(P("rowSource"))'="":P("rowSource"),1:$$ROWSRC^EFU837MAP(MODE))
 S OUTPATH=$$OUTFILE(.CONF,JOBID,.P)
 O OUTPATH:(newversion:stream:nowrap):1 E  S ERR("error")="export_open_failed" Q 0
 U OUTPATH
 I +$G(P("header")) W $$HDR(FIELDS,DELIM),!
 I ROWSRC="line" D WRLINES(JOBID,FIELDS,DELIM)
 E  D WRCLAIMS(JOBID,FIELDS,DELIM)
 C OUTPATH
 S ^MIO("EFUZY","job",JOBID,"profileName")=$G(P("name"))
 S ^MIO("EFUZY","job",JOBID,"exportMode")=MODE
 Q 1
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
 Q $$SUB($G(S),KEY,$G(VAL))
 ;
SUB(S,F,R)
 N P
 S P=$F(S,F)
 F  Q:'P  D
 . S S=$E(S,1,P-$L(F)-1)_R_$E(S,P,$L(S))
 . S P=$F(S,F)
 Q S
 ;
HDR(FIELDS,DELIM)
 N I,O,NM
 S O=""
 F I=1:1:$L(FIELDS,",") S NM=$$TRIM^MIOUTIL($P(FIELDS,",",I)) I NM'="" D
 . I O'="" S O=O_DELIM
 . S O=O_$$CSV(NM)
 Q O
 ;
WRCLAIMS(JOBID,FIELDS,DELIM)
 N I
 S I=0
 F  S I=$O(^MIO("EFUZY","job",JOBID,"wrk","claim",I)) Q:'I  W $$ROW("claim",JOBID,I,FIELDS,DELIM),!
 Q
 ;
WRLINES(JOBID,FIELDS,DELIM)
 N I
 S I=0
 F  S I=$O(^MIO("EFUZY","job",JOBID,"wrk","line",I)) Q:'I  W $$ROW("line",JOBID,I,FIELDS,DELIM),!
 Q
 ;
ROW(SRC,JOBID,IDX,FIELDS,DELIM)
 N I,NM,O
 S O=""
 F I=1:1:$L(FIELDS,",") S NM=$$TRIM^MIOUTIL($P(FIELDS,",",I)) I NM'="" D
 . I O'="" S O=O_DELIM
 . S O=O_$$CSV($$VAL(SRC,JOBID,IDX,NM))
 Q O
 ;
VAL(SRC,JOBID,IDX,FIELD)
 N V,CIDX
 I SRC="claim" Q $G(^MIO("EFUZY","job",JOBID,"wrk","claim",IDX,FIELD))
 S V=$G(^MIO("EFUZY","job",JOBID,"wrk","line",IDX,FIELD))
 I V'="" Q V
 S CIDX=$G(^MIO("EFUZY","job",JOBID,"wrk","line",IDX,"claim_index"))
 I CIDX="" Q ""
 Q $G(^MIO("EFUZY","job",JOBID,"wrk","claim",CIDX,FIELD))
 ;
CSV(V)
 N X
 S X=$G(V)
 S X=$TR(X,$C(13,10),"  ")
 I X[","!(X["""")!(X[$C(10))!(X[$C(13)) D
 . S X=$$SUB(X,"""","""""")
 . S X=""""_X_""""
 Q X
 ;
