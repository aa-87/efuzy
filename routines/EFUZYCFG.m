EFUZYCFG ; efuzy profiles and automation config
	;
	Q
	;
SEED()
	I $G(^MIO("EFUZY","cfg","seeded"))=1 Q
	S ^MIO("EFUZY","cfg","seeded")=1
	N P,ID,ERR
	K P
	S P("name")="Claim Summary"
	S P("workflowType")="837_to_csv"
	S P("exportMode")="claim_summary"
	S P("selectedFields")=$$DFLIST^EFU837EXPMP("claim_summary")
	S P("fieldOrder")=P("selectedFields")
	S P("delimiter")=","
	S P("header")=1
	S P("quoteMode")="minimal"
	S P("rowSource")="claim"
	S P("outputNamingRule")="{{source_base}}-claim-summary.csv"
	D SAVEONE(.P,.ID,.ERR)
	K P
	S P("name")="Service Line"
	S P("workflowType")="837_to_csv"
	S P("exportMode")="service_line"
	S P("selectedFields")=$$DFLIST^EFU837EXPMP("service_line")
	S P("fieldOrder")=P("selectedFields")
	S P("delimiter")=","
	S P("header")=1
	S P("quoteMode")="minimal"
	S P("rowSource")="line"
	S P("outputNamingRule")="{{source_base}}-service-lines.csv"
	D SAVEONE(.P,.ID,.ERR)
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
SAVE(CONF,POST,ID,ERR)
	N OK
	D SEEDCHK
	S OK=$$SAVEONE(.POST,.ID,.ERR)
	Q:$QUIT OK Q
	;
SAVEONE(POST,ID,ERR)
	N MODE
	K ERR
	S ID=$G(POST("id"))
	I ID="" S ID=$$NEXTPROF()
	I 'ID S ERR("error")="profile_seq_busy" Q:$QUIT 0 Q
	S MODE=$S($G(POST("exportMode"))'="":POST("exportMode"),1:"claim_summary")
	S ^MIO("EFUZY","cfg","profile",ID,"id")=ID
	S ^MIO("EFUZY","cfg","profile",ID,"name")=$$REQ($G(POST("name")),"profile_name_required",.ERR) I $D(ERR) Q:$QUIT 0 Q
	S ^MIO("EFUZY","cfg","profile",ID,"workflowType")=$S($G(POST("workflowType"))'="":POST("workflowType"),1:"837_to_csv")
	S ^MIO("EFUZY","cfg","profile",ID,"exportMode")=MODE
	S ^MIO("EFUZY","cfg","profile",ID,"selectedFields")=$S($G(POST("selectedFields"))'="":POST("selectedFields"),1:$$DFLIST^EFU837EXPMP(MODE))
	S ^MIO("EFUZY","cfg","profile",ID,"fieldOrder")=$S($G(POST("fieldOrder"))'="":POST("fieldOrder"),1:^MIO("EFUZY","cfg","profile",ID,"selectedFields"))
	S ^MIO("EFUZY","cfg","profile",ID,"delimiter")=$S($G(POST("delimiter"))'="":POST("delimiter"),1:",")
	S ^MIO("EFUZY","cfg","profile",ID,"header")=$S($G(POST("header"))'="":+POST("header"),1:1)
	S ^MIO("EFUZY","cfg","profile",ID,"quoteMode")=$S($G(POST("quoteMode"))'="":POST("quoteMode"),1:"minimal")
	S ^MIO("EFUZY","cfg","profile",ID,"rowSource")=$S($G(POST("rowSource"))'="":POST("rowSource"),1:$$ROWSRC^EFU837EXPMP(MODE))
	S ^MIO("EFUZY","cfg","profile",ID,"outputNamingRule")=$S($G(POST("outputNamingRule"))'="":POST("outputNamingRule"),1:"{{source_base}}-"_MODE_".csv")
	S ^MIO("EFUZY","cfg","profile",ID,"updatedAt")=$$NOWISO^MIOUTIL()
	I '$D(^MIO("EFUZY","cfg","profile",ID,"createdAt")) S ^MIO("EFUZY","cfg","profile",ID,"createdAt")=^MIO("EFUZY","cfg","profile",ID,"updatedAt")
	S ^MIO("EFUZY","idx","profile","name",$ZCONVERT(^MIO("EFUZY","cfg","profile",ID,"name"),"L"),ID)=""
	Q:$QUIT 1 Q
	;
GET(CONF,ID,OUT)
	D SEEDCHK
	K OUT
	I ID="" S ID=$O(^MIO("EFUZY","cfg","profile",0))
	I +$G(ID)<1 Q 0
	I '$D(^MIO("EFUZY","cfg","profile",ID)) Q 0
	M OUT=^MIO("EFUZY","cfg","profile",ID)
	Q 1
	;
LOADPROFL(CONF,TCTX)
	D SEEDCHK
	N ID,N
	S (ID,N)=0
	F  S ID=$O(^MIO("EFUZY","cfg","profile",ID)) Q:'ID  D
	. S N=N+1
	. D PROFCTX(ID,.TCTX,N)
	I 'N S TCTX("profilesEmpty")=1
	Q
	;
LOADPROF(CONF,ID,TCTX)
	N P
	K TCTX("profile")
	I $G(ID)="new" D  Q
	. S TCTX("profile","id")=""
	. S TCTX("profile","name")=""
	. S TCTX("profile","workflowType")="837_to_csv"
	. S TCTX("profile","exportMode")="claim_summary"
	. S TCTX("profile","selectedFieldsText")=$$DFLIST^EFU837EXPMP("claim_summary")
	. S TCTX("profile","fieldOrderText")=TCTX("profile","selectedFieldsText")
	. S TCTX("profile","delimiter")=","
	. S TCTX("profile","quoteMode")="minimal"
	. S TCTX("profile","outputNamingRule")="{{source_base}}-claim-summary.csv"
	. D FIELDTOKS("selectedFields",.TCTX)
	. D FIELDTOKS("fieldOrder",.TCTX)
	I '$$GET(.CONF,$G(ID),.P) S TCTX("profileMissing")=1 Q
	M TCTX("profile")=P
	S TCTX("profile","selectedFieldsText")=$G(P("selectedFields"))
	S TCTX("profile","fieldOrderText")=$G(P("fieldOrder"))
	D FIELDTOKS("selectedFields",.TCTX)
	D FIELDTOKS("fieldOrder",.TCTX)
	Q
	;
PROFCTX(ID,TCTX,N)
	S TCTX("profiles",N,"id")=ID
	S TCTX("profiles",N,"name")=$G(^MIO("EFUZY","cfg","profile",ID,"name"))
	S TCTX("profiles",N,"workflowType")=$G(^MIO("EFUZY","cfg","profile",ID,"workflowType"))
	S TCTX("profiles",N,"exportMode")=$G(^MIO("EFUZY","cfg","profile",ID,"exportMode"))
	S TCTX("profiles",N,"selectedFields")=$G(^MIO("EFUZY","cfg","profile",ID,"selectedFields"))
	S TCTX("profiles",N,"delimiter")=$G(^MIO("EFUZY","cfg","profile",ID,"delimiter"))
	S TCTX("profiles",N,"quoteMode")=$G(^MIO("EFUZY","cfg","profile",ID,"quoteMode"))
	S TCTX("profiles",N,"href")="/efuzy/profiles/"_ID
	Q
	;
DELPROF(CONF,ID,ERR)
	K ERR
	I +$G(ID)<1 S ERR("error")="profile_id_required" Q:$QUIT 0 Q
	K ^MIO("EFUZY","cfg","profile",ID)
	Q:$QUIT 1 Q
	;
SAVEAUTO(CONF,POST,ID,ERR)
	K ERR
	S ID=$G(POST("id"))
	I ID="" S ID=$$NEXTAUTO()
	I 'ID S ERR("error")="automation_seq_busy" Q:$QUIT 0 Q
	S ^MIO("EFUZY","cfg","auto",ID,"id")=ID
	S ^MIO("EFUZY","cfg","auto",ID,"name")=$S($G(POST("name"))'="":POST("name"),1:"Automation "_ID)
	S ^MIO("EFUZY","cfg","auto",ID,"workflowType")=$S($G(POST("workflowType"))'="":POST("workflowType"),1:"837_to_csv")
	S ^MIO("EFUZY","cfg","auto",ID,"inputFolder")=$G(POST("inputFolder"))
	S ^MIO("EFUZY","cfg","auto",ID,"outputFolder")=$G(POST("outputFolder"))
	S ^MIO("EFUZY","cfg","auto",ID,"archiveFolder")=$G(POST("archiveFolder"))
	S ^MIO("EFUZY","cfg","auto",ID,"errorFolder")=$G(POST("errorFolder"))
	S ^MIO("EFUZY","cfg","auto",ID,"selectedProfile")=$G(POST("selectedProfile"))
	S ^MIO("EFUZY","cfg","auto",ID,"enabled")=+$G(POST("enabled"))
	S ^MIO("EFUZY","cfg","auto",ID,"onSuccess")=$S($G(POST("onSuccess"))'="":POST("onSuccess"),1:"archive")
	S ^MIO("EFUZY","cfg","auto",ID,"onFailure")=$S($G(POST("onFailure"))'="":POST("onFailure"),1:"error")
	S ^MIO("EFUZY","cfg","auto",ID,"overwriteMode")=$S($G(POST("overwriteMode"))'="":POST("overwriteMode"),1:"skip")
	S ^MIO("EFUZY","cfg","auto",ID,"namingRule")=$S($G(POST("namingRule"))'="":POST("namingRule"),1:"{{source_base}}-{{timestamp}}.csv")
	S ^MIO("EFUZY","cfg","auto",ID,"updatedAt")=$$NOWISO^MIOUTIL()
	I '$D(^MIO("EFUZY","cfg","auto",ID,"createdAt")) S ^MIO("EFUZY","cfg","auto",ID,"createdAt")=^MIO("EFUZY","cfg","auto",ID,"updatedAt")
	Q:$QUIT 1 Q
	;
LOADAUTOS(CONF,TCTX)
	N ID,N
	S (ID,N)=0
	F  S ID=$O(^MIO("EFUZY","cfg","auto",ID)) Q:'ID  D
	. S N=N+1
	. S TCTX("automation",N,"id")=ID
	. S TCTX("automation",N,"name")=$G(^MIO("EFUZY","cfg","auto",ID,"name"))
	. S TCTX("automation",N,"workflowType")=$G(^MIO("EFUZY","cfg","auto",ID,"workflowType"))
	. S TCTX("automation",N,"inputFolder")=$G(^MIO("EFUZY","cfg","auto",ID,"inputFolder"))
	. S TCTX("automation",N,"outputFolder")=$G(^MIO("EFUZY","cfg","auto",ID,"outputFolder"))
	. S TCTX("automation",N,"selectedProfile")=$G(^MIO("EFUZY","cfg","auto",ID,"selectedProfile"))
	. S TCTX("automation",N,"enabled")=$S(+$G(^MIO("EFUZY","cfg","auto",ID,"enabled")):1,1:0)
	I 'N S TCTX("automationEmpty")=1
	Q
	;
DELAUTO(CONF,ID,ERR)
	K ERR
	I +$G(ID)<1 S ERR("error")="automation_id_required" Q:$QUIT 0 Q
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
SEEDCHK
	I '$G(^MIO("EFUZY","cfg","seeded")) D SEED
	Q
	;
	;