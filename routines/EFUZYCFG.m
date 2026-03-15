EFUZYCFG ; efuzy profiles and automation config
	;
	Q
	;
SEED() ; ensure legacy shared seed profiles exist
	I $G(^MIO("EFUZY","cfg","seeded"))=1 Q
	S ^MIO("EFUZY","cfg","seeded")=1
	N P,ID,ERR
	K P
	S P("name")="Claim Summary"
	S P("workflowType")="837_to_csv"
	S P("exportMode")="claim_summary"
	S P("selectedFields")=$$DFLIST^EFU837EXPMP("claim_summary")
	S P("fieldOrder")=P("selectedFields")
	S P("delimiter")="," S P("header")=1 S P("quoteMode")="minimal"
	S P("rowSource")="claim"
	S P("outputNamingRule")="{{source_base}}-claim-summary.csv"
	D SAVEONE(.P,.ID,.ERR)
	K P
	S P("name")="Service Line"
	S P("workflowType")="837_to_csv"
	S P("exportMode")="service_line"
	S P("selectedFields")=$$DFLIST^EFU837EXPMP("service_line")
	S P("fieldOrder")=P("selectedFields")
	S P("delimiter")="," S P("header")=1 S P("quoteMode")="minimal"
	S P("rowSource")="line"
	S P("outputNamingRule")="{{source_base}}-service-lines.csv"
	D SAVEONE(.P,.ID,.ERR)
	Q
	;
SEEDUSER(USERID)
	N P,ID,ERR
	I +$G(USERID)<1 Q
	I $G(^MIO("EFUZY","cfg","ownerSeeded",+USERID))=1 Q
	S ^MIO("EFUZY","cfg","ownerSeeded",+USERID)=1
	K P
	S P("name")="Claim Summary"
	S P("workflowType")="837_to_csv"
	S P("exportMode")="claim_summary"
	S P("selectedFields")=$$DFLIST^EFU837EXPMP("claim_summary")
	S P("fieldOrder")=P("selectedFields")
	S P("delimiter")="," S P("header")=1 S P("quoteMode")="minimal"
	S P("rowSource")="claim"
	S P("outputNamingRule")="{{source_base}}-claim-summary.csv"
	D SAVEONE(.P,.ID,.ERR,+$G(USERID))
	K P
	S P("name")="Service Line"
	S P("workflowType")="837_to_csv"
	S P("exportMode")="service_line"
	S P("selectedFields")=$$DFLIST^EFU837EXPMP("service_line")
	S P("fieldOrder")=P("selectedFields")
	S P("delimiter")="," S P("header")=1 S P("quoteMode")="minimal"
	S P("rowSource")="line"
	S P("outputNamingRule")="{{source_base}}-service-lines.csv"
	D SAVEONE(.P,.ID,.ERR,+$G(USERID))
	Q
	;
NEXTPROF()
	N ID
	L +^MIO("EFUZY","SEQ","PROFILE"):2 E  Q 0
	S ID=$I(^MIO("EFUZY","SEQ","PROFILE"))
	L -^MIO("EFUZY","SEQ","PROFILE")
	Q ID
	;
NEXTAUTO()
	N ID
	L +^MIO("EFUZY","SEQ","AUTO"):2 E  Q 0
	S ID=$I(^MIO("EFUZY","SEQ","AUTO"))
	L -^MIO("EFUZY","SEQ","AUTO")
	Q ID
	;
SAVE(CONF,POST,ID,ERR,USERID)
	D SEEDCHK(+$G(USERID))
	Q:$Q $$SAVEONE(.POST,.ID,.ERR,+$G(USERID))
	D SAVEONE(.POST,.ID,.ERR,+$G(USERID))
	Q
	;
SAVEONE(POST,ID,ERR,USERID)
	N MODE,SEL,ORD,DELIM,QMODE,ROWSRC,NAMING,WF,NOW,OLDNM,NEWNM,OLDOWN
	K ERR
	S ID=+$G(POST("id"))
	I ID,+$G(USERID)>0,'$$OWNSPROF^EFUZYAUTH(+USERID,ID) S ERR("error")="profile_not_found" Q:$QUIT 0 Q
	I 'ID S ID=$$NEXTPROF()
	I 'ID S ERR("error")="profile_seq_busy" Q:$QUIT 0 Q
	S MODE=$$MODE($G(POST("exportMode")))
	S SEL=$$NORMSEL(MODE,$G(POST("selectedFields")))
	I SEL="" S SEL=$$DFLIST^EFU837EXPMP(MODE)
	S ORD=$$NORMORD(SEL,$G(POST("fieldOrder")))
	S DELIM=$$DELIM($G(POST("delimiter")))
	S QMODE=$$QMODE($G(POST("quoteMode")))
	S ROWSRC=$$ROWSRC(MODE,$G(POST("rowSource")))
	S NAMING=$$NAMERULE($G(POST("outputNamingRule")),MODE)
	S WF=$S($G(POST("workflowType"))'="":$G(POST("workflowType")),1:"837_to_csv")
	S NOW=$$NOWISO^MIOUTIL()
	S OLDNM=$ZCONVERT($G(^MIO("EFUZY","cfg","profile",ID,"name")),"L")
	I OLDNM'="" K ^MIO("EFUZY","idx","profile","name",OLDNM,ID)
	S ^MIO("EFUZY","cfg","profile",ID,"id")=ID
	S ^MIO("EFUZY","cfg","profile",ID,"name")=$$REQ($G(POST("name")),"profile_name_required",.ERR) I $D(ERR) Q:$QUIT 0 Q
	S ^MIO("EFUZY","cfg","profile",ID,"workflowType")=WF
	S ^MIO("EFUZY","cfg","profile",ID,"exportMode")=MODE
	S ^MIO("EFUZY","cfg","profile",ID,"selectedFields")=SEL
	S ^MIO("EFUZY","cfg","profile",ID,"fieldOrder")=ORD
	S ^MIO("EFUZY","cfg","profile",ID,"delimiter")=DELIM
	S ^MIO("EFUZY","cfg","profile",ID,"header")=$S($G(POST("header"))'="":+$G(POST("header")),1:1)
	S ^MIO("EFUZY","cfg","profile",ID,"quoteMode")=QMODE
	S ^MIO("EFUZY","cfg","profile",ID,"rowSource")=ROWSRC
	S ^MIO("EFUZY","cfg","profile",ID,"outputNamingRule")=NAMING
	S ^MIO("EFUZY","cfg","profile",ID,"updatedAt")=NOW
	I '$D(^MIO("EFUZY","cfg","profile",ID,"createdAt")) S ^MIO("EFUZY","cfg","profile",ID,"createdAt")=NOW
	S OLDOWN=+$G(^MIO("EFUZY","cfg","profile",ID,"ownerId"))
	I +$G(USERID)>0 D
	. I OLDOWN>0,OLDOWN'=+USERID D UNSTAMP^EFUZYAUTH("profile",OLDOWN,ID)
	. D STAMPPROF^EFUZYAUTH(ID,+$G(USERID))
	S NEWNM=$ZCONVERT($G(^MIO("EFUZY","cfg","profile",ID,"name")),"L")
	I NEWNM'="" S ^MIO("EFUZY","idx","profile","name",NEWNM,ID)=""
	Q:$QUIT 1 Q
	;
GET(CONF,ID,OUT,USERID)
	D SEEDCHK(+$G(USERID))
	K OUT
	I ID="" D  Q $S(+$G(ID)>0:1,1:0)
	. I +$G(USERID)>0 S ID=$O(^MIO("EFUZY","idx","owner","profile",+USERID,0)) Q
	. S ID=$O(^MIO("EFUZY","cfg","profile",0))
	I +$G(ID)<1 Q 0
	I '$D(^MIO("EFUZY","cfg","profile",ID)) Q 0
	I +$G(USERID)>0,'$$OWNSPROF^EFUZYAUTH(+USERID,+ID) Q 0
	M OUT=^MIO("EFUZY","cfg","profile",ID)
	Q 1
	;
LOADPROFL(CONF,TCTX,USERID)
	D SEEDCHK(+$G(USERID))
	N ID,N
	S (ID,N)=0
	I +$G(USERID)>0 D  Q
	. F  S ID=$O(^MIO("EFUZY","idx","owner","profile",+USERID,ID)) Q:'ID  D
	. . S N=N+1
	. . D PROFCTX(ID,.TCTX,N)
	. I 'N S TCTX("profilesEmpty")=1
	F  S ID=$O(^MIO("EFUZY","cfg","profile",ID)) Q:'ID  D
	. S N=N+1
	. D PROFCTX(ID,.TCTX,N)
	I 'N S TCTX("profilesEmpty")=1
	Q
	;
LOADPROF(CONF,ID,TCTX,USERID)
	N P
	K TCTX("profile")
	D SEEDCHK(+$G(USERID))
	I $G(ID)="new" D  Q
	. D DEFAULTP(.TCTX)
	. D FIELDTOKS("selectedFields",.TCTX)
	. D FIELDTOKS("fieldOrder",.TCTX)
	I '$$GET(.CONF,$G(ID),.P,+$G(USERID)) S TCTX("profileMissing")=1 Q
	M TCTX("profile")=P
	S TCTX("profile","selectedFieldsText")=$G(P("selectedFields"))
	S TCTX("profile","fieldOrderText")=$G(P("fieldOrder"))
	D FIELDTOKS("selectedFields",.TCTX)
	D FIELDTOKS("fieldOrder",.TCTX)
	Q
	;
DEFAULTP(TCTX)
	S TCTX("profile","id")=""
	S TCTX("profile","name")=""
	S TCTX("profile","workflowType")="837_to_csv"
	S TCTX("profile","exportMode")="claim_summary"
	S TCTX("profile","selectedFieldsText")=$$DFLIST^EFU837EXPMP("claim_summary")
	S TCTX("profile","fieldOrderText")=TCTX("profile","selectedFieldsText")
	S TCTX("profile","delimiter")="," S TCTX("profile","header")=1
	S TCTX("profile","quoteMode")="minimal"
	S TCTX("profile","rowSource")="claim"
	S TCTX("profile","outputNamingRule")="{{source_base}}-claim-summary.csv"
	Q
	;
PROFCTX(ID,TCTX,N)
	S TCTX("profiles",N,"id")=ID
	S TCTX("profiles",N,"name")=$G(^MIO("EFUZY","cfg","profile",ID,"name"))
	S TCTX("profiles",N,"workflowType")=$G(^MIO("EFUZY","cfg","profile",ID,"workflowType"))
	S TCTX("profiles",N,"exportMode")=$G(^MIO("EFUZY","cfg","profile",ID,"exportMode"))
	S TCTX("profiles",N,"selectedFields")=$G(^MIO("EFUZY","cfg","profile",ID,"selectedFields"))
	S TCTX("profiles",N,"fieldOrder")=$G(^MIO("EFUZY","cfg","profile",ID,"fieldOrder"))
	S TCTX("profiles",N,"delimiter")=$G(^MIO("EFUZY","cfg","profile",ID,"delimiter"))
	S TCTX("profiles",N,"header")=$G(^MIO("EFUZY","cfg","profile",ID,"header"))
	S TCTX("profiles",N,"quoteMode")=$G(^MIO("EFUZY","cfg","profile",ID,"quoteMode"))
	S TCTX("profiles",N,"rowSource")=$G(^MIO("EFUZY","cfg","profile",ID,"rowSource"))
	S TCTX("profiles",N,"outputNamingRule")=$G(^MIO("EFUZY","cfg","profile",ID,"outputNamingRule"))
	S TCTX("profiles",N,"href")="/efuzy/profiles/"_ID
	Q
	;
DELPROF(CONF,ID,ERR,USERID)
	N NM,OWN
	K ERR
	I +$G(ID)<1 S ERR("error")="profile_id_required" Q:$QUIT 0 Q
	S OWN=+$G(^MIO("EFUZY","cfg","profile",ID,"ownerId"))
	I +$G(USERID)>0,OWN'=+USERID S ERR("error")="profile_not_found" Q:$QUIT 0 Q
	S NM=$ZCONVERT($G(^MIO("EFUZY","cfg","profile",ID,"name")),"L")
	I NM'="" K ^MIO("EFUZY","idx","profile","name",NM,ID)
	I OWN>0 D UNSTAMP^EFUZYAUTH("profile",OWN,ID)
	K ^MIO("EFUZY","cfg","profile",ID)
	Q:$QUIT 1 Q
	;
SAVEAUTO(CONF,POST,ID,ERR,USERID)
	N NOW,OLDOWN
	K ERR
	S ID=+$G(POST("id"))
	I ID,+$G(USERID)>0,'$$OWNSAUTO^EFUZYAUTH(+USERID,ID) S ERR("error")="automation_not_found" Q:$QUIT 0 Q
	I 'ID S ID=$$NEXTAUTO()
	I 'ID S ERR("error")="automation_seq_busy" Q:$QUIT 0 Q
	S NOW=$$NOWISO^MIOUTIL()
	S ^MIO("EFUZY","cfg","auto",ID,"id")=ID
	S ^MIO("EFUZY","cfg","auto",ID,"name")=$S($G(POST("name"))'="":$G(POST("name")),1:"Automation "_ID)
	S ^MIO("EFUZY","cfg","auto",ID,"workflowType")=$S($G(POST("workflowType"))'="":$G(POST("workflowType")),1:"837_to_csv")
	S ^MIO("EFUZY","cfg","auto",ID,"inputFolder")=$G(POST("inputFolder"))
	S ^MIO("EFUZY","cfg","auto",ID,"outputFolder")=$G(POST("outputFolder"))
	S ^MIO("EFUZY","cfg","auto",ID,"archiveFolder")=$G(POST("archiveFolder"))
	S ^MIO("EFUZY","cfg","auto",ID,"errorFolder")=$G(POST("errorFolder"))
	S ^MIO("EFUZY","cfg","auto",ID,"selectedProfile")=$G(POST("selectedProfile"))
	S ^MIO("EFUZY","cfg","auto",ID,"enabled")=+$G(POST("enabled"))
	S ^MIO("EFUZY","cfg","auto",ID,"onSuccess")=$S($G(POST("onSuccess"))'="":$G(POST("onSuccess")),1:"archive")
	S ^MIO("EFUZY","cfg","auto",ID,"onFailure")=$S($G(POST("onFailure"))'="":$G(POST("onFailure")),1:"error")
	S ^MIO("EFUZY","cfg","auto",ID,"overwriteMode")=$S($G(POST("overwriteMode"))'="":$G(POST("overwriteMode")),1:"skip")
	S ^MIO("EFUZY","cfg","auto",ID,"namingRule")=$S($G(POST("namingRule"))'="":$G(POST("namingRule")),1:"{{source_base}}-{{timestamp}}.csv")
	S ^MIO("EFUZY","cfg","auto",ID,"updatedAt")=NOW
	I '$D(^MIO("EFUZY","cfg","auto",ID,"createdAt")) S ^MIO("EFUZY","cfg","auto",ID,"createdAt")=NOW
	S OLDOWN=+$G(^MIO("EFUZY","cfg","auto",ID,"ownerId"))
	I +$G(USERID)>0 D
	. I OLDOWN>0,OLDOWN'=+USERID D UNSTAMP^EFUZYAUTH("auto",OLDOWN,ID)
	. D STAMPAUTO^EFUZYAUTH(ID,+$G(USERID))
	Q:$QUIT 1 Q
	;
LOADAUTOS(CONF,TCTX,USERID)
	N ID,N
	S (ID,N)=0
	I +$G(USERID)>0 D  Q
	. F  S ID=$O(^MIO("EFUZY","idx","owner","auto",+USERID,ID)) Q:'ID  D
	. . I '$D(^MIO("EFUZY","cfg","auto",ID)) Q
	. . S N=N+1
	. . D AUTOCTX(ID,.TCTX,N)
	. I 'N S TCTX("automationEmpty")=1
	F  S ID=$O(^MIO("EFUZY","cfg","auto",ID)) Q:'ID  D
	. S N=N+1
	. D AUTOCTX(ID,.TCTX,N)
	I 'N S TCTX("automationEmpty")=1
	Q
	;
AUTOCTX(ID,TCTX,N)
	S TCTX("automation",N,"id")=ID
	S TCTX("automation",N,"name")=$G(^MIO("EFUZY","cfg","auto",ID,"name"))
	S TCTX("automation",N,"workflowType")=$G(^MIO("EFUZY","cfg","auto",ID,"workflowType"))
	S TCTX("automation",N,"inputFolder")=$G(^MIO("EFUZY","cfg","auto",ID,"inputFolder"))
	S TCTX("automation",N,"outputFolder")=$G(^MIO("EFUZY","cfg","auto",ID,"outputFolder"))
	S TCTX("automation",N,"selectedProfile")=$G(^MIO("EFUZY","cfg","auto",ID,"selectedProfile"))
	S TCTX("automation",N,"enabled")=$S(+$G(^MIO("EFUZY","cfg","auto",ID,"enabled")):1,1:0)
	Q
	;
DELAUTO(CONF,ID,ERR,USERID)
	N OWN
	K ERR
	I +$G(ID)<1 S ERR("error")="automation_id_required" Q:$QUIT 0 Q
	S OWN=+$G(^MIO("EFUZY","cfg","auto",ID,"ownerId"))
	I +$G(USERID)>0,OWN'=+USERID S ERR("error")="automation_not_found" Q:$QUIT 0 Q
	I OWN>0 D UNSTAMP^EFUZYAUTH("auto",OWN,ID)
	K ^MIO("EFUZY","cfg","auto",ID)
	Q:$QUIT 1 Q
	;
FIELDTOKS(KEY,TCTX)
	N TXT,I,N,P
	S TXT=$G(TCTX("profile",KEY_"Text"))
	S N=0
	F I=1:1:$L(TXT,",") S P=$$TRIM^MIOUTIL($P(TXT,",",I)) I P'="" D
	. S N=N+1
	. S TCTX("profile",KEY,N,"name")=P
	Q
	;
REQ(VAL,ERRCODE,ERR)
	I $G(VAL)="" S ERR("error")=ERRCODE Q ""
	Q VAL
	;
SEEDCHK(USERID)
	I +$G(USERID)>0 D SEEDUSER(+$G(USERID)) Q
	I '$G(^MIO("EFUZY","cfg","seeded")) D SEED
	Q
	;
MODE(X)
	N M S M=$ZCONVERT($G(X),"L")
	I M="service_line"!(M="subscriber_patient")!(M="provider_context")!(M="custom") Q M
	Q "claim_summary"
	;
NORMSEL(MODE,TXT)
	N TMP,VALID,OUT,SEEN,I,P
	D LOADVALID(.VALID,MODE)
	S (OUT,P)=""
	F I=1:1:$L($G(TXT),",") D
	. S P=$ZCONVERT($$TRIM^MIOUTIL($P($G(TXT),",",I)),"L")
	. I P="" Q
	. I '$D(VALID(P)) Q
	. I $D(SEEN(P)) Q
	. S SEEN(P)=1
	. S OUT=$S(OUT'="":OUT_",",1:"")_P
	Q OUT
	;
NORMORD(SEL,TXT)
	N OUT,SEEN,I,P
	S OUT=""
	F I=1:1:$L($G(TXT),",") D
	. S P=$ZCONVERT($$TRIM^MIOUTIL($P($G(TXT),",",I)),"L")
	. I P="" Q
	. I '$$INCSV(SEL,P) Q
	. I $D(SEEN(P)) Q
	. S SEEN(P)=1
	. S OUT=$S(OUT'="":OUT_",",1:"")_P
	F I=1:1:$L($G(SEL),",") D
	. S P=$$TRIM^MIOUTIL($P($G(SEL),",",I))
	. I P="" Q
	. I $D(SEEN(P)) Q
	. S SEEN(P)=1
	. S OUT=$S(OUT'="":OUT_",",1:"")_P
	Q OUT
	;
LOADVALID(VALID,MODE)
	N T,M,N,NM
	K VALID
	D LOADMAPS^EFU837EXPMP(.T)
	I $G(MODE)'="custom" D  I $D(VALID) Q
	. S N=0 F  S N=$O(T("maps","fields",MODE,N)) Q:'N  D
	. . S NM=$G(T("maps","fields",MODE,N,"name")) I NM'="" S VALID(NM)=1
	S M="" F  S M=$O(T("maps","fields",M)) Q:M=""  D
	. S N=0 F  S N=$O(T("maps","fields",M,N)) Q:'N  D
	. . S NM=$G(T("maps","fields",M,N,"name")) I NM'="" S VALID(NM)=1
	Q
	;
DELIM(X)
	N Y S Y=$ZCONVERT($$TRIM^MIOUTIL($G(X)),"L")
	I Y="tab"!(Y="\\t") Q $C(9)
	I Y=$C(9) Q $C(9)
	I Y="" Q ","
	Q $E(Y,1)
	;
QMODE(X)
	N Y S Y=$ZCONVERT($$TRIM^MIOUTIL($G(X)),"L")
	I Y="all"!(Y="none") Q Y
	Q "minimal"
	;
ROWSRC(MODE,VAL)
	N Y S Y=$ZCONVERT($$TRIM^MIOUTIL($G(VAL)),"L")
	I Y="claim"!(Y="line") Q Y
	Q $$ROWSRC^EFU837EXPMP($G(MODE))
	;
NAMERULE(RULE,MODE)
	N X S X=$$TRIM^MIOUTIL($G(RULE))
	I X="" Q "{{source_base}}-"_$G(MODE)_".csv"
	Q X
	;
INCSV(TXT,VAL)
	Q $S((","_$G(TXT)_",")[(","_$G(VAL)_","):1,1:0)
	;
	;