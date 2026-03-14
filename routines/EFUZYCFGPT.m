EFUZYCFGPT ; profile and automation hardening tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYCFGPT"
 Q
 ;
ALL(FAIL)
 D T100(.FAIL)
 D T110(.FAIL)
 D T120(.FAIL)
 D T130(.FAIL)
 Q
 ;
T100(FAIL) ; selected fields and order are normalized on save
 N CONF,POST,ID,ERR,P
 D RESET^EFUZYTESTU("")
 S POST("name")="Normalized Custom"
 S POST("exportMode")="custom"
 S POST("selectedFields")="claim_id,total_charge,claim_id,bad_field,patient_last"
 S POST("fieldOrder")="patient_last,claim_id"
 S POST("rowSource")="claim"
 D EQ(.FAIL,"[T100][save ok]",$$SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR),1)
 D EQ(.FAIL,"[T100][get ok]",$$GET^EFUZYCFG(.CONF,ID,.P),1)
 D EQ(.FAIL,"[T100][selected normalized]",$G(P("selectedFields")),"claim_id,total_charge,patient_last")
 D EQ(.FAIL,"[T100][order completed]",$G(P("fieldOrder")),"patient_last,claim_id,total_charge")
 Q
 ;
T110(FAIL) ; delimiter, quote mode, row source, and naming rule normalize
 N CONF,POST,ID,ERR,P
 D RESET^EFUZYTESTU("")
 S POST("name")="Line Tab Export"
 S POST("exportMode")="custom"
 S POST("selectedFields")="claim_id,line_number,procedure_code"
 S POST("fieldOrder")="line_number,claim_id,procedure_code"
 S POST("delimiter")="tab"
 S POST("quoteMode")="ALL"
 S POST("rowSource")="line"
 S POST("outputNamingRule")=""
 D EQ(.FAIL,"[T110][save ok]",$$SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR),1)
 D EQ(.FAIL,"[T110][get ok]",$$GET^EFUZYCFG(.CONF,ID,.P),1)
 D EQ(.FAIL,"[T110][delimiter tab]",$G(P("delimiter")),$C(9))
 D EQ(.FAIL,"[T110][quote mode]",$G(P("quoteMode")),"all")
 D EQ(.FAIL,"[T110][row source]",$G(P("rowSource")),"line")
 D EQ(.FAIL,"[T110][naming default]",$G(P("outputNamingRule")),"{{source_base}}-custom.csv")
 Q
 ;
T120(FAIL) ; load profile preserves token order and timestamps
 N CONF,POST,ID,ERR,TCTX
 D RESET^EFUZYTESTU("")
 S POST("name")="Token Order"
 S POST("exportMode")="custom"
 S POST("selectedFields")="claim_id,total_charge,patient_last"
 S POST("fieldOrder")="patient_last,claim_id,total_charge"
 D EQ(.FAIL,"[T120][save ok]",$$SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR),1)
 D LOADPROF^EFUZYCFG(.CONF,ID,.TCTX)
 D EQ(.FAIL,"[T120][tok1]",$G(TCTX("profile","fieldOrder",1,"name")),"patient_last")
 D EQ(.FAIL,"[T120][tok2]",$G(TCTX("profile","fieldOrder",2,"name")),"claim_id")
 D EQ(.FAIL,"[T120][tok3]",$G(TCTX("profile","fieldOrder",3,"name")),"total_charge")
 D EQ(.FAIL,"[T120][created]",$G(TCTX("profile","createdAt"))'="",1)
 D EQ(.FAIL,"[T120][updated]",$G(TCTX("profile","updatedAt"))'="",1)
 Q
 ;
T130(FAIL) ; automation save preserves selected profile and naming rule
 N CONF,POST,ID,ERR,TCTX
 D RESET^EFUZYTESTU("")
 S POST("name")="Night Job"
 S POST("workflowType")="837_to_csv"
 S POST("inputFolder")="/in"
 S POST("outputFolder")="/out"
 S POST("selectedProfile")=77
 S POST("enabled")=1
 S POST("namingRule")="{{source_base}}-{{job_id}}.csv"
 D EQ(.FAIL,"[T130][save ok]",$$SAVEAUTO^EFUZYCFG(.CONF,.POST,.ID,.ERR),1)
 D LOADAUTOS^EFUZYCFG(.CONF,.TCTX)
 D EQ(.FAIL,"[T130][name]",$G(TCTX("automation",1,"name")),"Night Job")
 D EQ(.FAIL,"[T130][profile]",+$G(TCTX("automation",1,"selectedProfile")),77)
 D EQ(.FAIL,"[T130][enabled]",+$G(TCTX("automation",1,"enabled")),1)
 D EQ(.FAIL,"[T130][naming]",$G(^MIO("EFUZY","cfg","auto",ID,"namingRule")),"{{source_base}}-{{job_id}}.csv")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
