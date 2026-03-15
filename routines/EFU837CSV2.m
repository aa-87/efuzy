EFU837CSV ; profile-aware CSV export builder
 ;
 Q
 ;
MAKE(CONF,JOBID,PROFILEID,OUTPATH,ERR)
 N P,MODE,FIELDS,DELIM,ROWSRC,QMODE,HDRON,OLDIO
 K ERR
 D PROFILE(.CONF,+$G(PROFILEID),JOBID,.P)
 S MODE=$G(P("exportMode")) I MODE="" S MODE="claim_summary"
 S FIELDS=$G(P("fieldOrder")) I FIELDS="" S FIELDS=$G(P("selectedFields"))
 S DELIM=$G(P("delimiter")) I DELIM="" S DELIM="," 
 S ROWSRC=$G(P("rowSource")) I ROWSRC="" S ROWSRC=$$ROWSRC(MODE,"")
 S QMODE=$G(P("quoteMode")) I QMODE="" S QMODE="minimal"
 S HDRON=+$G(P("header"),1)
 S OUTPATH=$$OUTFILE(.CONF,JOBID,.P)
 I '$$ENSDIR($P(OUTPATH,"/",1,$L(OUTPATH,"/")-1),.ERR) Q 0
 O OUTPATH:(newversion:stream:nowrap:writeonly):1 E  S ERR("error")="export_open_failed" Q 0
 S OLDIO=$IO U OUTPATH
 I HDRON W $$HDR(FIELDS,DELIM,QMODE)_$$EOL()
 I ROWSRC="line" D WRLINES(JOBID,FIELDS,DELIM,QMODE)
 E  D WRCLAIMS(JOBID,FIELDS,DELIM,QMODE)
 C OUTPATH U OLDIO
 D META(JOBID,PROFILEID,.P,OUTPATH)
 Q 1
 ;
PROFILE(CONF,PROFILEID,JOBID,P)
 K P
 I +$G(PROFILEID)>0,$$GET^EFUZYCFG(.CONF,+$G(PROFILEID),.P,+$G(^MIO("EFUZY","job",+$G(JOBID),"ownerId"))) Q
 S P("id")=""
 S P("name")="Default Claim Summary"
 S P("workflowType")="837_to_csv"
 S P("exportMode")="claim_summary"
 S P("selectedFields")=$$DFLIST^EFU837EXPMP("claim_summary")
 S P("fieldOrder")=P("selectedFields")
 S P("delimiter")="," S P("header")=1 S P("quoteMode")="minimal"
 S P("rowSource")="claim"
 S P("outputNamingRule")="{{source_base}}-claim-summary.csv"
 Q
 ;
META(JOBID,PROFILEID,P,OUTPATH)
 N NAME
 S NAME=$P(OUTPATH,"/",$L(OUTPATH,"/"))
 S ^MIO("EFUZY","job",JOBID,"profileId")=+$G(PROFILEID)
 S ^MIO("EFUZY","job",JOBID,"profileName")=$G(P("name"))
 S ^MIO("EFUZY","job",JOBID,"exportMode")=$G(P("exportMode"))
 S ^MIO("EFUZY","job",JOBID,"outputPath")=OUTPATH
 S ^MIO("EFUZY","job",JOBID,"outputName")=NAME
 S ^MIO("EFUZY","job",JOBID,"plannedOutputName")=NAME
 S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","path")=OUTPATH
 S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","name")=NAME
 S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","type")="csv"
 S ^MIO("EFUZY","job",JOBID,"artifact","profile_export","profileId")=+$G(PROFILEID)
 Q
 ;
OUTFILE(CONF,JOBID,P)
 N BASE,SRC,NAME
 S BASE=$$EXPORTDIR^EFUZYFS(.CONF,+$G(^MIO("EFUZY","job",+$G(JOBID),"ownerId")))
 S SRC=$$GETNAME^EFUZYFS($G(^MIO("EFUZY","job",JOBID,"fileId")),+$G(^MIO("EFUZY","job",+$G(JOBID),"ownerId")))
 S NAME=$$PLANNAME(SRC,JOBID,$G(P("outputNamingRule")),$G(P("exportMode")))
 Q BASE_"/"_NAME
 ;
PLANNAME(SRC,JOBID,RULE,MODE)
 N NAME,BASE
 S BASE=$$SAFEBASE($G(SRC))
 S NAME=$G(RULE)
 I NAME="" S NAME="{{source_base}}-"_$S($G(MODE)'="":$G(MODE),1:"claim_summary")_".csv"
 S NAME=$$SUBX(NAME,"{{source_base}}",BASE)
 S NAME=$$SUBX(NAME,"{{mode}}",$S($G(MODE)'="":$G(MODE),1:"claim_summary"))
 S NAME=$$SUBX(NAME,"{{job_id}}",$G(JOBID))
 S NAME=$$SUBX(NAME,"{{timestamp}}",$$STAMP())
 I NAME["{{" S NAME=BASE_"-"_$G(JOBID)_".csv"
 Q NAME
 ;
STAMP()
 N X
 S X=$TR($$NOWISO^MIOUTIL(),"-:TZ","")
 I X="" S X=$TR($H,",","-")
 Q X
 ;
SAFEBASE(NAME)
 N X
 S X=$G(NAME)
 I X["/" S X=$P(X,"/",$L(X,"/"))
 I X["\" S X=$P(X,"\",$L(X,"\"))
 I X["." S X=$P(X,".",1,$L(X,".")-1)
 I X="" S X="export"
 Q $$SAFE^EFUZYFS(X)
 ;
SUBX(TXT,OLD,NEW)
 N OUT,POS,START,LEN
 S OUT="",START=1,LEN=$L($G(OLD))
 I LEN=0 Q $G(TXT)
 F  S POS=$F($G(TXT),$G(OLD),START) Q:'POS  D
 . S OUT=OUT_$E($G(TXT),START,POS-LEN-1)_$G(NEW)
 . S START=POS
 S OUT=OUT_$E($G(TXT),START,$L($G(TXT)))
 Q OUT
 ;
HDR(FIELDS,DELIM,QMODE)
 N I,O,NM,DLM,QM
 S DLM=$S($G(DELIM)'="":$G(DELIM),1:",")
 S QM=$S($D(QMODE):$G(QMODE),1:"minimal")
 S O=""
 F I=1:1:$L($G(FIELDS),",") S NM=$$TRIM^MIOUTIL($P($G(FIELDS),",",I)) I NM'="" D
 . I O'="" S O=O_DLM
 . S O=O_$$CSV(NM,DLM,QM)
 Q O
 ;
WRCLAIMS(JOBID,FIELDS,DELIM,QMODE)
 N I
 S I=0
 F  S I=$O(^MIO("EFUZY","job",JOBID,"wrk","claim",I)) Q:'I  W $$ROW("claim",JOBID,I,FIELDS,DELIM,QMODE)_$$EOL()
 Q
 ;
WRLINES(JOBID,FIELDS,DELIM,QMODE)
 N I
 S I=0
 F  S I=$O(^MIO("EFUZY","job",JOBID,"wrk","line",I)) Q:'I  W $$ROW("line",JOBID,I,FIELDS,DELIM,QMODE)_$$EOL()
 Q
 ;
ROW(SRC,JOBID,IDX,FIELDS,DELIM,QMODE)
 N I,NM,O,DLM,QM
 S DLM=$S($G(DELIM)'="":$G(DELIM),1:",")
 S QM=$S($D(QMODE):$G(QMODE),1:"minimal")
 S O=""
 F I=1:1:$L($G(FIELDS),",") S NM=$$TRIM^MIOUTIL($P($G(FIELDS),",",I)) I NM'="" D
 . I O'="" S O=O_DLM
 . S O=O_$$CSV($$VAL(SRC,JOBID,IDX,NM),DLM,QM)
 Q O
 ;
VAL(SRC,JOBID,IDX,FIELD)
 N V,CIDX
 I SRC="claim" Q $G(^MIO("EFUZY","job",JOBID,"wrk","claim",IDX,FIELD))
 S V=$G(^MIO("EFUZY","job",JOBID,"wrk","line",IDX,FIELD))
 I V'="" Q V
 S CIDX=+$G(^MIO("EFUZY","job",JOBID,"wrk","line",IDX,"claim_index"))
 I 'CIDX Q ""
 Q $G(^MIO("EFUZY","job",JOBID,"wrk","claim",CIDX,FIELD))
 ;
CSV(V,DELIM,QMODE)
 N X,Q,DLM,QM
 S X=$G(V),Q=$C(34)
 S DLM=$S($G(DELIM)'="":$G(DELIM),1:",")
 S QM=$S($D(QMODE):$G(QMODE),1:"minimal")
 S X=$TR(X,$C(13,10),"  ")
 I QM="none" Q X
 I QM="all" Q $$QCSV(X)
 I X[DLM Q $$QCSV(X)
 I $F(X,Q)>0 Q $$QCSV(X)
 Q X
 ;
QCSV(X)
 N Q S Q=$C(34)
 Q Q_$$SUB(X,Q,Q_Q)_Q
 ;
SUB(S,F,R)
 N POS,START,OUT,FL
 I $G(F)="" Q $G(S)
 S OUT="",START=1,FL=$L(F)
 F  S POS=$F($G(S),$G(F),START) Q:'POS  D
 . S OUT=OUT_$E($G(S),START,POS-FL-1)_$G(R)
 . S START=POS
 S OUT=OUT_$E($G(S),START,$L($G(S)))
 Q OUT
 ;
ENSDIR(PATH,ERR)
 N CMD,PROBE
 K ERR
 I $G(PATH)="" Q 1
 S CMD="mkdir -p '"_$TR($G(PATH),"'","''")_"'"
 ZSY CMD
 S PROBE=$G(PATH)_"/.efuzzy_probe"
 O PROBE:(newversion:stream:nowrap:writeonly):1 E  D  Q 0
 . S ERR("error")="mkdir_failed"
 U PROBE W "ok" C PROBE
 ZSY "rm -f '"_$TR(PROBE,"'","''")_"'"
 Q 1
 ;
EOL() Q $C(13,10)
 ;
ROWSRC(MODE,PRSRC)
 I $G(PRSRC)'="" Q $G(PRSRC)
 I $G(MODE)="service_line" Q "line"
 Q "claim"
 ;
