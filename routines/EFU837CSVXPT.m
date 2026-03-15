EFU837CSVXPT ; additional CSV/export compatibility tests
	; Quiet on success.;
	;
	D START Q
	;
START ; default entry
	N FAIL
	S FAIL=0
	D ALL(.FAIL)
	I 'FAIL W !,"OK - EFU837CSVXPT"
	Q
	;
ALL(FAIL)
	D T900(.FAIL)
	D T910(.FAIL)
	D T920(.FAIL)
	D T930(.FAIL)
	Q
	;
T900(FAIL) ; export missing path fails cleanly
	N ROOT,OPT,RES
	S ROOT=$NA(^TMP($J,"EFU837CSVXPT",900))
	D EXPORT^EFU837CSV("","",ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T900][ok]",+$G(RES("ok")),0)
	D EQ(.FAIL,"[T900][error]",$G(RES("error")),"missing_path")
	K @ROOT Q
	;
T910(FAIL) ; export sample file creates claim and line csv outputs
	N ROOTPATH,OUTBASE,ROOT,OPT,RES,OK
	D RESET^EFUZYTESTU("")
	S ROOTPATH=$$TMPROOT^EFUZYTESTU("csvxpt-910")
	D MKDIR^EFUZYTESTU(ROOTPATH)
	D SAMPLE837^EFUZYTESTU(ROOTPATH_"/demo.837",.OK)
	D MKDIR^EFUZYTESTU(ROOTPATH_"/out")
	S OUTBASE=ROOTPATH_"/out/demo"
	S ROOT=$NA(^TMP($J,"EFU837CSVXPT",910))
	D EXPORT^EFU837CSV(ROOTPATH_"/demo.837",OUTBASE,ROOT,.OPT,.RES)
	D EQ(.FAIL,"[T910][ok]",+$G(RES("ok")),1)
	D EQ(.FAIL,"[T910][claims path]",$$EXISTS^EFUZYTESTU($G(RES("path","claims"))),1)
	D EQ(.FAIL,"[T910][lines path]",$$EXISTS^EFUZYTESTU($G(RES("path","lines"))),1)
	D EQ(.FAIL,"[T910][claim rows]",+$G(RES("claim_rows"))>0,1)
	D EQ(.FAIL,"[T910][line rows]",+$G(RES("line_rows"))>0,1)
	D RMDIR^EFUZYTESTU(ROOTPATH)
	K @ROOT Q
	;
T920(FAIL) ; outfilename token replacement and fallback name are stable
	N CONF,P,PATH,ROOT
	D RESET^EFUZYTESTU("")
	S ROOT=$$TMPROOT^EFUZYTESTU("csvxpt-920")
	D SETCONF^EFUZYTESTU(.CONF,ROOT)
	S ^MIO("EFUZY","job",920,"fileId")=1
	S ^MIO("EFUZY","file",1,"name")="demo 837.x12"
	S P("exportMode")="service_line"
	S P("outputNamingRule")="{{source_base}}-{{mode}}-{{job_id}}.csv"
	S PATH=$$OUTFILE^EFU837CSV(.CONF,920,.P)
	D EQ(.FAIL,"[T920][pattern]",PATH["demo_837-service_line-920.csv",1)
	K P
	S P("exportMode")="claim_summary"
	S P("outputNamingRule")=""
	S PATH=$$OUTFILE^EFU837CSV(.CONF,920,.P)
	D EQ(.FAIL,"[T920][fallback]",PATH["claim_summary",1)
	Q
	;
T930(FAIL) ; val falls back from line row to owning claim row
	D RESET^EFUZYTESTU("")
	S ^MIO("EFUZY","job",930,"wrk","claim",1,"subscriber_id")="SUB123"
	S ^MIO("EFUZY","job",930,"wrk","line",1,"claim_index")=1
	D EQ(.FAIL,"[T930][fallback subscriber]",$$VAL^EFU837CSV("line",930,1,"subscriber_id"),"SUB123")
	D EQ(.FAIL,"[T930][missing blank]",$$VAL^EFU837CSV("line",930,1,"payer_name"),"")
	Q
	;
EQ(FAIL,LABEL,GOT,EXP)
	I $G(GOT)=$G(EXP) Q
	S FAIL=1
	W !,"FAIL: ",LABEL,": got=",$G(GOT)," expected=",$G(EXP)
	Q
	;
	;