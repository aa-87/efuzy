EFUX12WEB ; efuzy x12 web/workflow integration helpers
 ;
 ; Public:
 ;   ROUTEDEF(.OUT)
 ;   ROUTES(.CONF)
 ;   PREVIEW837(INPATH,WORKBASE,WEBROOT,.OPT,.RES)
 ;   EXPORT837(INPATH,WORKBASE,WEBROOT,.OPT,.RES)
 ;   DETAIL(JOBREF,WEBROOT,.OPT,.RES)
 ;   HISTORY(WEBROOT,.OPT,.RES)
 ;
 ; Notes:
 ;   - additive service/controller layer for existing MUMPS.IO web stack
 ;   - reuses EFUX12JOB artifact packaging instead of duplicating parser logic
 ;   - returns route-friendly payload trees for preview, export, detail, history
 ;   - keeps parser reusable outside any web context
 ;
 Q
 ;
ROUTEDEF(OUT) ; route definitions for controller wiring
 K OUT
 S OUT(1,"method")="POST"
 S OUT(1,"path")="/x12/837/preview"
 S OUT(1,"target")="PREVIEWH^EFUX12WEB"
 S OUT(2,"method")="POST"
 S OUT(2,"path")="/x12/837/export"
 S OUT(2,"target")="EXPORTH^EFUX12WEB"
 S OUT(3,"method")="GET"
 S OUT(3,"path")="/x12/jobs"
 S OUT(3,"target")="HISTORYH^EFUX12WEB"
 S OUT(4,"method")="GET"
 S OUT(4,"path")="/x12/jobs/:id"
 S OUT(4,"target")="DETAILH^EFUX12WEB"
 Q
 ;
ROUTES(CONF) ; optional MIOROUTE registration if available
 N DEF,I,CNT
 S CNT=0
 D ROUTEDEF(.DEF)
 I $T(ADD^MIOROUTE)="" Q CNT
 S I=0 F  S I=$O(DEF(I)) Q:'I  D
 . D ADD^MIOROUTE($G(DEF(I,"method")),$G(DEF(I,"path")),$G(DEF(I,"target")))
 . S CNT=CNT+1
 Q CNT
 ;
PREVIEW837(INPATH,WORKBASE,WEBROOT,OPT,RES) ; build preview payload from input file
 N JROOT,JOPT,JRES
 K RES
 D INIT(WEBROOT,"preview")
 S JROOT=$NA(@WEBROOT@("job"))
 M JOPT=OPT
 S JOPT("build_rebuilt")=0
 S JOPT("roundtrip")=0
 D RUN837^EFUX12JOB(INPATH,WORKBASE,JROOT,.JOPT,.JRES)
 D BLDLIVE(JROOT,WEBROOT,"preview",.JOPT,.RES)
 Q
 ;
EXPORT837(INPATH,WORKBASE,WEBROOT,OPT,RES) ; build export/download payload from input file
 N JROOT,JOPT,JRES
 K RES
 D INIT(WEBROOT,"export")
 S JROOT=$NA(@WEBROOT@("job"))
 M JOPT=OPT
 I '$D(JOPT("build_rebuilt")) S JOPT("build_rebuilt")=1
 I '$D(JOPT("roundtrip")) S JOPT("roundtrip")=0
 D RUN837^EFUX12JOB(INPATH,WORKBASE,JROOT,.JOPT,.JRES)
 D BLDLIVE(JROOT,WEBROOT,"export",.JOPT,.RES)
 Q
 ;
DETAIL(JOBREF,WEBROOT,OPT,RES) ; build detail payload from live job root or published job id
 N JID,JROOT
 K RES
 D INIT(WEBROOT,"detail")
 S JID=+$G(JOBREF)
 I JID>0,$D(^MIO("EFUZY","job",JID)) D  Q
 . D BLDPUB(JID,WEBROOT,.OPT,.RES)
 S JROOT=$G(JOBREF)
 I JROOT?1"^".E,$D(@JROOT) D  Q
 . D BLDLIVE(JROOT,WEBROOT,"detail",.OPT,.RES)
 D FAILRESP(WEBROOT,404,"not_found","Job reference not found")
 M RES=@WEBROOT@("response")
 S RES("http_status")=+$G(@WEBROOT@("http","status"))
 Q
 ;
HISTORY(WEBROOT,OPT,RES) ; published job history payload from ^MIO("EFUZY","job")
 N LIM,WF,ST,JID,CNT,N,START
 K RES
 D INIT(WEBROOT,"history")
 S LIM=+$G(OPT("limit")) I LIM<1 S LIM=25
 S WF=$G(OPT("workflow"))
 S ST=$G(OPT("status"))
 S START=+$G(OPT("start_after"))
 S JID=$S(START>0:START,1:$O(^MIO("EFUZY","job",""),-1))
 S CNT=0,N=0
 F  Q:JID=""!(CNT>=LIM)  D  S JID=$O(^MIO("EFUZY","job",JID),-1)
 . I '$D(^MIO("EFUZY","job",JID)) Q
 . I WF'="",$G(^MIO("EFUZY","job",JID,"workflowType"))'=WF Q
 . I ST'="",$G(^MIO("EFUZY","job",JID,"status"))'=ST Q
 . S CNT=CNT+1,N=N+1
 . D ADDPUB(JID,WEBROOT,N)
 S @WEBROOT@("response","ok")=1
 S @WEBROOT@("response","jobs")=CNT
 S @WEBROOT@("response","limit")=LIM
 S @WEBROOT@("response","mode")="history"
 S @WEBROOT@("response","summary","returned")=CNT
 S @WEBROOT@("http","status")=200
 M RES=@WEBROOT@("response")
 S RES("http_status")=200
 Q
 ;
PREVIEWH(DEV,CONF,REQ,CTX) ; thin route/controller wrapper
 N ROOT,OPT,RES,INPATH,WORKBASE
 S ROOT=$NA(^TMP($J,"EFUX12WEB","preview",$H))
 S INPATH=$$RQVAL("input_path",.REQ)
 S WORKBASE=$$WORKBASE("preview",.CONF,.REQ)
 D PREVIEW837(INPATH,WORKBASE,ROOT,.OPT,.RES)
 S CTX("x12","root")=ROOT
 S CTX("status")=+$G(RES("http_status"))
 Q
 ;
EXPORTH(DEV,CONF,REQ,CTX) ; thin route/controller wrapper
 N ROOT,OPT,RES,INPATH,WORKBASE
 S ROOT=$NA(^TMP($J,"EFUX12WEB","export",$H))
 S INPATH=$$RQVAL("input_path",.REQ)
 S WORKBASE=$$WORKBASE("export",.CONF,.REQ)
 D EXPORT837(INPATH,WORKBASE,ROOT,.OPT,.RES)
 S CTX("x12","root")=ROOT
 S CTX("status")=+$G(RES("http_status"))
 Q
 ;
DETAILH(DEV,CONF,REQ,CTX) ; thin route/controller wrapper
 N ROOT,OPT,RES,JOBREF
 S ROOT=$NA(^TMP($J,"EFUX12WEB","detail",$H))
 S JOBREF=$$RQVAL("id",.REQ)
 I JOBREF="" S JOBREF=$$RQVAL("jobid",.REQ)
 D DETAIL(JOBREF,ROOT,.OPT,.RES)
 S CTX("x12","root")=ROOT
 S CTX("status")=+$G(RES("http_status"))
 Q
 ;
HISTORYH(DEV,CONF,REQ,CTX) ; thin route/controller wrapper
 N ROOT,OPT,RES
 S ROOT=$NA(^TMP($J,"EFUX12WEB","history",$H))
 S OPT("limit")=+$$RQVAL("limit",.REQ)
 S OPT("status")=$$RQVAL("status",.REQ)
 S OPT("workflow")=$$RQVAL("workflow",.REQ)
 D HISTORY(ROOT,.OPT,.RES)
 S CTX("x12","root")=ROOT
 S CTX("status")=+$G(RES("http_status"))
 Q
 ;
INIT(WEBROOT,MODE) ; initialize web payload root
 K @WEBROOT
 S @WEBROOT@("meta","mode")=$G(MODE)
 S @WEBROOT@("meta","created_h")=$H
 S @WEBROOT@("http","status")=200
 S @WEBROOT@("response","ok")=0
 S @WEBROOT@("response","mode")=$G(MODE)
 Q
 ;
BLDLIVE(JROOT,WEBROOT,MODE,OPT,RES) ; build response from live job root
 N HS
 I '$D(@JROOT) D  Q
 . D FAILRESP(WEBROOT,404,"not_found","Live job root not found")
 . M RES=@WEBROOT@("response")
 . S RES("http_status")=+$G(@WEBROOT@("http","status"))
 S HS=$S($G(@JROOT@("meta","status"))="completed":200,$G(@JROOT@("meta","status"))="failed":422,1:200)
 S @WEBROOT@("http","status")=HS
 S @WEBROOT@("response","ok")=$S(HS=200:1,1:0)
 S @WEBROOT@("response","job","status")=$G(@JROOT@("meta","status"))
 S @WEBROOT@("response","job","workflow")=$G(@JROOT@("meta","workflow"))
 S @WEBROOT@("response","job","input_path")=$G(@JROOT@("meta","input_path"))
 S @WEBROOT@("response","job","workbase")=$G(@JROOT@("meta","workbase"))
 S @WEBROOT@("response","job","compare_mode")=$G(@JROOT@("meta","compare_mode"))
 S @WEBROOT@("response","job","jobid")=+$G(OPT("jobid"))
 M @WEBROOT@("response","summary")=@JROOT@("summary")
 I MODE="preview"!(MODE="detail") M @WEBROOT@("response","preview")=@JROOT@("preview")
 D ADDDIAG(JROOT,WEBROOT,+$G(OPT("diag_limit")))
 D ADDART(JROOT,WEBROOT)
 D ADDTRC(JROOT,WEBROOT,MODE,.OPT)
 I HS'=200 D
 . S @WEBROOT@("response","error","code")=$G(@JROOT@("meta","error_code"))
 . S @WEBROOT@("response","error","message")=$G(@JROOT@("meta","error_text"))
 S @WEBROOT@("response","job","artifact_count")=+$G(@JROOT@("artifact_last"))
 M RES=@WEBROOT@("response")
 S RES("http_status")=HS
 Q
 ;
BLDPUB(JID,WEBROOT,OPT,RES) ; build response from published ^MIO job record
 N HS
 S HS=$S($G(^MIO("EFUZY","job",JID,"status"))="completed":200,$G(^MIO("EFUZY","job",JID,"status"))="failed":422,1:200)
 S @WEBROOT@("http","status")=HS
 S @WEBROOT@("response","ok")=$S(HS=200:1,1:0)
 S @WEBROOT@("response","job","jobid")=JID
 S @WEBROOT@("response","job","status")=$G(^MIO("EFUZY","job",JID,"status"))
 S @WEBROOT@("response","job","workflow")=$G(^MIO("EFUZY","job",JID,"workflowType"))
 S @WEBROOT@("response","job","input_path")=$G(^MIO("EFUZY","job",JID,"inputPath"))
 S @WEBROOT@("response","job","diag_summary")=$G(^MIO("EFUZY","job",JID,"diagSummary"))
 S @WEBROOT@("response","summary","claims")=+$G(^MIO("EFUZY","job",JID,"stats","claims"))
 S @WEBROOT@("response","summary","lines")=+$G(^MIO("EFUZY","job",JID,"stats","lines"))
 S @WEBROOT@("response","summary","transactions")=+$G(^MIO("EFUZY","job",JID,"stats","transactions"))
 S @WEBROOT@("response","summary","roundtrip_ok")=+$G(^MIO("EFUZY","job",JID,"stats","roundtripOk"))
 S @WEBROOT@("response","trace","summary","fields")=+$G(^MIO("EFUZY","job",JID,"stats","traceFields"))
 S @WEBROOT@("response","trace","summary","segments")=+$G(^MIO("EFUZY","job",JID,"stats","traceSegments"))
 D ADDPUBART(JID,WEBROOT)
 M RES=@WEBROOT@("response")
 S RES("http_status")=HS
 Q
 ;
ADDDIAG(JROOT,WEBROOT,LIM) ; copy warning/error diagnostics from parse workspace
 N DROOT,TYPE,N,OUT
 S LIM=+$G(LIM) I LIM<1 S LIM=25
 S DROOT=$NA(@JROOT@("wrk","parse","diag"))
 F TYPE="error","warning" D
 . S N=0,OUT=0
 . F  S N=$O(@DROOT@(TYPE,N)) Q:'N!(OUT>=LIM)  D
 . . S OUT=OUT+1
 . . M @WEBROOT@("response","diagnostic",TYPE,OUT)=@DROOT@(TYPE,N)
 . S @WEBROOT@("response","diagnostic",TYPE_"s")=OUT
 Q
 ;
ADDART(JROOT,WEBROOT) ; copy live artifact/download metadata
 N N,KEY,D
 K @WEBROOT@("response","artifact")
 K @WEBROOT@("response","download")
 S N=0,D=0
 F  S N=$O(@JROOT@("artifact_by_id",N)) Q:'N  D
 . S KEY=$G(@JROOT@("artifact_by_id",N)) Q:KEY=""
 . M @WEBROOT@("response","artifact",KEY)=@JROOT@("artifact",KEY)
 . S D=D+1
 . S @WEBROOT@("response","download",D,"key")=KEY
 . S @WEBROOT@("response","download",D,"name")=$G(@JROOT@("artifact",KEY,"name"))
 . S @WEBROOT@("response","download",D,"path")=$G(@JROOT@("artifact",KEY,"path"))
 . S @WEBROOT@("response","download",D,"type")=$G(@JROOT@("artifact",KEY,"type"))
 . S @WEBROOT@("response","download",D,"role")=$G(@JROOT@("artifact",KEY,"role"))
 . S @WEBROOT@("response","download",D,"exists")=+$G(@JROOT@("artifact",KEY,"exists"))
 S @WEBROOT@("response","downloads")=D
 Q
 ;
ADDTRC(JROOT,WEBROOT,MODE,OPT) ; copy trace summary and optional field traces
 N FULL
 K @WEBROOT@("response","trace")
 I $D(@JROOT@("trace","summary")) M @WEBROOT@("response","trace","summary")=@JROOT@("trace","summary")
 S FULL=0
 I $G(MODE)="detail" S FULL=1
 I +$G(OPT("include_trace")) S FULL=1
 I 'FULL Q
 I $D(@JROOT@("trace","claim")) M @WEBROOT@("response","trace","claim")=@JROOT@("trace","claim")
 I $D(@JROOT@("trace","line")) M @WEBROOT@("response","trace","line")=@JROOT@("trace","line")
 Q
 ;
ADDPUB(JID,WEBROOT,N) ; one history row from published job record
 S @WEBROOT@("response","job",N,"jobid")=JID
 S @WEBROOT@("response","job",N,"workflow")=$G(^MIO("EFUZY","job",JID,"workflowType"))
 S @WEBROOT@("response","job",N,"status")=$G(^MIO("EFUZY","job",JID,"status"))
 S @WEBROOT@("response","job",N,"input_path")=$G(^MIO("EFUZY","job",JID,"inputPath"))
 S @WEBROOT@("response","job",N,"diag_summary")=$G(^MIO("EFUZY","job",JID,"diagSummary"))
 S @WEBROOT@("response","job",N,"warning_count")=+$G(^MIO("EFUZY","job",JID,"warningCount"))
 S @WEBROOT@("response","job",N,"error_count")=+$G(^MIO("EFUZY","job",JID,"errorCount"))
 S @WEBROOT@("response","job",N,"claims")=+$G(^MIO("EFUZY","job",JID,"stats","claims"))
 S @WEBROOT@("response","job",N,"lines")=+$G(^MIO("EFUZY","job",JID,"stats","lines"))
 S @WEBROOT@("response","job",N,"transactions")=+$G(^MIO("EFUZY","job",JID,"stats","transactions"))
 S @WEBROOT@("response","job",N,"roundtrip_ok")=+$G(^MIO("EFUZY","job",JID,"stats","roundtripOk"))
 Q
 ;
ADDPUBART(JID,WEBROOT) ; artifact list from published job record
 N KEY,D
 K @WEBROOT@("response","artifact")
 K @WEBROOT@("response","download")
 S KEY="",D=0
 F  S KEY=$O(^MIO("EFUZY","job",JID,"artifact",KEY)) Q:KEY=""  D
 . S D=D+1
 . S @WEBROOT@("response","artifact",KEY,"path")=$G(^MIO("EFUZY","job",JID,"artifact",KEY,"path"))
 . S @WEBROOT@("response","artifact",KEY,"type")=$G(^MIO("EFUZY","job",JID,"artifact",KEY,"type"))
 . S @WEBROOT@("response","artifact",KEY,"name")=$G(^MIO("EFUZY","job",JID,"artifact",KEY,"name"))
 . S @WEBROOT@("response","download",D,"key")=KEY
 . S @WEBROOT@("response","download",D,"path")=$G(^MIO("EFUZY","job",JID,"artifact",KEY,"path"))
 . S @WEBROOT@("response","download",D,"type")=$G(^MIO("EFUZY","job",JID,"artifact",KEY,"type"))
 . S @WEBROOT@("response","download",D,"name")=$G(^MIO("EFUZY","job",JID,"artifact",KEY,"name"))
 S @WEBROOT@("response","downloads")=D
 Q
 ;
FAILRESP(WEBROOT,HS,CODE,MSG) ; standard error payload
 S @WEBROOT@("http","status")=+$G(HS)
 S @WEBROOT@("response","ok")=0
 S @WEBROOT@("response","error","code")=$G(CODE)
 S @WEBROOT@("response","error","message")=$G(MSG)
 Q
 ;
RQVAL(KEY,REQ) ; best-effort request value extraction helper
 I $D(REQ("param",KEY)) Q $G(REQ("param",KEY))
 I $D(REQ("route",KEY)) Q $G(REQ("route",KEY))
 I $D(REQ("query",KEY)) Q $G(REQ("query",KEY))
 I $D(REQ("body",KEY)) Q $G(REQ("body",KEY))
 Q $G(REQ(KEY))
 ;
WORKBASE(TAG,CONF,REQ) ; choose workbase for route wrapper use
 N B
 S B=$G(CONF("x12","workbase"))
 I B="" S B="tmp/efux12web-"_$J_"-"_$TR($G(TAG)," /","__")_"-"_$R(999999)
 Q B
 ;
