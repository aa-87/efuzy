EFUZYCFGPT2 ; additional efuzy config/profile tests
 ; Quiet on success.
 ;
 D START Q
 ;
START ; default entry
 N FAIL
 S FAIL=0
 D ALL(.FAIL)
 I 'FAIL W !,"OK - EFUZYCFGPT2"
 Q
 ;
ALL(FAIL)
 D T600(.FAIL)
 D T610(.FAIL)
 D T620(.FAIL)
 D T630(.FAIL)
 Q
 ;
T600(FAIL) ; sparse profile save gets sane defaults by mode
 N CONF,POST,ID,ERR,P
 D RESET^EFUZYTESTU("")
 K POST,ERR,P
 S POST("name")="Sparse Service Line"
 S POST("exportMode")="service_line"
 D SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR)
 D EQ(.FAIL,"[T600][saved]",+$G(ID)>0,1)
 D EQ(.FAIL,"[T600][get]",$$GET^EFUZYCFG(.CONF,ID,.P),1)
 D EQ(.FAIL,"[T600][mode]",$G(P("exportMode")),"service_line")
 D EQ(.FAIL,"[T600][selected default]",$L($G(P("selectedFields")),",")>3,1)
 D EQ(.FAIL,"[T600][field order default]",$G(P("fieldOrder"))=$G(P("selectedFields")),1)
 D EQ(.FAIL,"[T600][delimiter default]",$G(P("delimiter")),",")
 D EQ(.FAIL,"[T600][header default]",+$G(P("header")),1)
 D EQ(.FAIL,"[T600][quote default]",$G(P("quoteMode")),"minimal")
 D EQ(.FAIL,"[T600][rowsrc default]",$G(P("rowSource")),"line")
 D EQ(.FAIL,"[T600][naming default]",$G(P("outputNamingRule"))["service_line",1)
 Q
 ;
T610(FAIL) ; delete profile removes it cleanly
 N CONF,POST,ID,ERR,P
 D RESET^EFUZYTESTU("")
 K POST,ERR,P
 S POST("name")="Delete Me"
 D SAVE^EFUZYCFG(.CONF,.POST,.ID,.ERR)
 D EQ(.FAIL,"[T610][saved]",+$G(ID)>0,1)
 D EQ(.FAIL,"[T610][delete ok]",$$DELPROF^EFUZYCFG(.CONF,ID,.ERR),1)
 D EQ(.FAIL,"[T610][gone]",$$GET^EFUZYCFG(.CONF,ID,.P),0)
 Q
 ;
T620(FAIL) ; automation defaults are stable
 N CONF,POST,ID,ERR
 D RESET^EFUZYTESTU("")
 K POST,ERR
 S POST("name")="Watcher One"
 S POST("inputFolder")="tmp/in"
 D SAVEAUTO^EFUZYCFG(.CONF,.POST,.ID,.ERR)
 D EQ(.FAIL,"[T620][saved]",+$G(ID)>0,1)
 D EQ(.FAIL,"[T620][name]",$G(^MIO("EFUZY","cfg","auto",ID,"name")),"Watcher One")
 D EQ(.FAIL,"[T620][workflow default]",$G(^MIO("EFUZY","cfg","auto",ID,"workflowType")),"837_to_csv")
 D EQ(.FAIL,"[T620][enabled default]",+$G(^MIO("EFUZY","cfg","auto",ID,"enabled")),0)
 D EQ(.FAIL,"[T620][success default]",$G(^MIO("EFUZY","cfg","auto",ID,"onSuccess")),"archive")
 D EQ(.FAIL,"[T620][failure default]",$G(^MIO("EFUZY","cfg","auto",ID,"onFailure")),"error")
 D EQ(.FAIL,"[T620][overwrite default]",$G(^MIO("EFUZY","cfg","auto",ID,"overwriteMode")),"skip")
 D EQ(.FAIL,"[T620][rule default]",$G(^MIO("EFUZY","cfg","auto",ID,"namingRule")),"{{source_base}}-{{timestamp}}.csv")
 Q
 ;
T630(FAIL) ; delete paths validate ids
 N CONF,ERR
 D RESET^EFUZYTESTU("")
 D EQ(.FAIL,"[T630][bad prof]",$$DELPROF^EFUZYCFG(.CONF,"",.ERR),0)
 D EQ(.FAIL,"[T630][bad prof err]",$G(ERR("error")),"profile_id_required")
 K ERR
 D EQ(.FAIL,"[T630][bad auto]",$$DELAUTO^EFUZYCFG(.CONF,"",.ERR),0)
 D EQ(.FAIL,"[T630][bad auto err]",$G(ERR("error")),"automation_id_required")
 Q
 ;
EQ(FAIL,LABEL,GOT,EXP)
 I $G(GOT)=$G(EXP) Q
 S FAIL=1
 W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
 Q
 ;
