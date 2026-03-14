EFUZYCFGPT ; profile configuration production tests
 D START Q
 ;
START
 N FAIL S FAIL=0
 D T100(.FAIL)
 D T110(.FAIL)
 D T120(.FAIL)
 I 'FAIL W !,"OK - EFUZYCFGPT"
 Q
 ;
T100(FAIL)
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
T110(FAIL)
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
T120(FAIL)
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
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
