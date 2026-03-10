EFUZYCFGT ; tests for EFUZYCFG
 ;
 ; Run:
 ;   YDB>D START^EFUZYCFGT
 ;
 Q
 ;
START
 D T001
 D T002
 D T003
 D T004
 D T005
 Q
 ;
T001 ; seed creates default profiles
 N CONF,CNT,ID
 D RESET^EFUZYTESTU("")
 D SEED^EFUZYCFG
 D EQ^MIOTASSERT($G(^MIO("EFUZY","cfg","seeded")),1,"[T001][seed flag]")
 S CNT=0,ID=0
 F  S ID=$O(^MIO("EFUZY","cfg","profile",ID)) Q:'ID  S CNT=CNT+1
 D EQ^MIOTASSERT(CNT,2,"[T001][profile count]")
 D OK^MIOTASSERT($D(^MIO("EFUZY","idx","profile","name","claim summary")),"[T001][claim summary index]")
 D OK^MIOTASSERT($D(^MIO("EFUZY","idx","profile","name","service line")),"[T001][service line index]")
 Q
 ;
T002 ; save and get profile
 N CONF,POST,ID,ERR,P
 D RESET^EFUZYTESTU("")
 S POST("name")="Custom Claims"
 S POST("exportMode")="custom"
 S POST("selectedFields")="claim_id,total_charge"
 S POST("fieldOrder")="total_charge,claim_id"
 S POST("delimiter")="|"
 S POST("header")=0
 S POST("quoteMode")="all"
 S POST("rowSource")="claim"
 S POST("outputNamingRule")="{{source_base}}-custom.csv"
 D OK^MIOTASSERT($$SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR),"[T002][save ok]")
 D OK^MIOTASSERT(ID>0,"[T002][id assigned]")
 D OK^MIOTASSERT($$GET^EFUZYCFG(.CONF,ID,.P),"[T002][get ok]")
 D EQ^MIOTASSERT($G(P("name")),"Custom Claims","[T002][name]")
 D EQ^MIOTASSERT($G(P("workflowType")),"837_to_csv","[T002][workflow default]")
 D EQ^MIOTASSERT($G(P("exportMode")),"custom","[T002][mode]")
 D EQ^MIOTASSERT($G(P("fieldOrder")),"total_charge,claim_id","[T002][field order]")
 D EQ^MIOTASSERT($G(P("delimiter")),"|","[T002][delimiter]")
 D EQ^MIOTASSERT($G(P("header")),0,"[T002][header]")
 Q
 ;
T003 ; delete profile
 N CONF,POST,ID,ERR
 D RESET^EFUZYTESTU("")
 S POST("name")="Delete Me"
 D OK^MIOTASSERT($$SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR),"[T003][save ok]")
 D OK^MIOTASSERT($D(^MIO("EFUZY","cfg","profile",ID)),"[T003][profile exists]")
 D OK^MIOTASSERT($$DELPROF^EFUZYCFG(.CONF,ID,.ERR),"[T003][delete ok]")
 D OK^MIOTASSERT('$D(^MIO("EFUZY","cfg","profile",ID)),"[T003][profile deleted]")
 Q
 ;
T004 ; save and load automation config
 N CONF,POST,ID,ERR,TCTX
 D RESET^EFUZYTESTU("")
 S POST("name")="Night Run"
 S POST("workflowType")="837_to_csv"
 S POST("inputFolder")="/in"
 S POST("outputFolder")="/out"
 S POST("archiveFolder")="/arc"
 S POST("errorFolder")="/err"
 S POST("selectedProfile")=12
 S POST("enabled")=1
 S POST("onSuccess")="archive"
 S POST("onFailure")="error"
 S POST("overwriteMode")="overwrite"
 S POST("namingRule")="{{source_base}}-{{job_id}}.csv"
 D OK^MIOTASSERT($$SAVEAUTO^EFUZYCFG(.CONF,.POST,.ID,.ERR),"[T004][save auto ok]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","cfg","auto",ID,"name")),"Night Run","[T004][name]")
 D EQ^MIOTASSERT($G(^MIO("EFUZY","cfg","auto",ID,"selectedProfile")),12,"[T004][selected profile]")
 D LOADAUTOS^EFUZYCFG(.CONF,.TCTX)
 D EQ^MIOTASSERT($G(TCTX("automation",1,"name")),"Night Run","[T004][load name]")
 D EQ^MIOTASSERT($G(TCTX("automation",1,"enabled")),1,"[T004][enabled]")
 Q
 ;
T005 ; load new profile defaults and field tokens
 N CONF,TCTX,ERR
 D RESET^EFUZYTESTU("")
 D LOADPROF^EFUZYCFG(.CONF,"new",.TCTX)
 D EQ^MIOTASSERT($G(TCTX("profile","workflowType")),"837_to_csv","[T005][workflow]")
 D EQ^MIOTASSERT($G(TCTX("profile","exportMode")),"claim_summary","[T005][mode]")
 D EQ^MIOTASSERT($G(TCTX("profile","selectedFields",1,"name")),"claim_id","[T005][selected field token]")
 D EQ^MIOTASSERT($G(TCTX("profile","fieldOrder",1,"name")),"claim_id","[T005][field order token]")
 Q
 ;
